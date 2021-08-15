import UIKit
import WebKit
import SwiftyJSON
import CoreLocation
import AppTrackingTransparency
import MapKit
import UserNotifications


let RECENT_LOCATION_TIMESPAN_THRESHOLD = 10.0
let RECENT_LOCATION_SEND_THRESHOLD = 10.0


class WeChangeViewController: UIViewController, WKUIDelegate,WKNavigationDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var webView: WKWebView!
    var appsToLaunchByURL:[String:ExternalAppInformation] = [:];
    var locationManager = CLLocationManager()
    var lastTimeCheckedForNotifications = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let exInfo = ExternalAppInformation(inAppPackage: Config.APP_ROCKET_CHAT, inAppTitleResourceKey: "Rocket Chat", inInstructionsResourceKey: Config.CHAT_INSTALL_INSTRUCTIONS_TEXT, inBrowserURL: Config.WECHANGE_ROCKET_CHAT_URL)
        appsToLaunchByURL[Config.WECHANGE_MESSAGES_URL] = exInfo;
        self.webView.navigationDelegate = self;
        self.webView.uiDelegate = self;
        //self.webView.lo
        let link = URL(string:ViewModel.currentURL)!
        let request = URLRequest(url: link)
        webView.load(request)
        
        
        let session = URLSession.shared
        let requestCookie = NSMutableURLRequest(url: NSURL(string: ViewModel.currentURL)! as URL)
        let task = session.dataTask(with: requestCookie as URLRequest) { data, response, error in
            guard
                let url = response?.url,
                let httpResponse = response as? HTTPURLResponse,
                let fields = httpResponse.allHeaderFields as? [String: String]
            else { return }

            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            ViewModel.cookies = cookies;
            HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey: Any]()
                cookieProperties[.name] = cookie.name
                cookieProperties[.value] = cookie.value
                cookieProperties[.domain] = cookie.domain
                cookieProperties[.path] = cookie.path
                cookieProperties[.version] = cookie.version
                cookieProperties[.expires] = Date().addingTimeInterval(31536000)

                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
                if Config.DEBUG == true { print("name: \(cookie.name) value: \(cookie.value)") }
            }
        }
        task.resume()
          
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { trackingAuthorizationStatus in
                switch trackingAuthorizationStatus {
                case .authorized:
                    
                    print(trackingAuthorizationStatus)
                case .denied:
                    print(trackingAuthorizationStatus)
                case .notDetermined:
                    print(trackingAuthorizationStatus)
                case .restricted:
                    print(trackingAuthorizationStatus)
                @unknown default:
                    break
                }
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
            }
        } else {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if Config.DEBUG == true { print("CLLocationManager:didUpdateLocations called") }
        // var userLocation: CLLocation = CLLocation()
        // var previousUpdate:TimeInterval = 0 // TODO: fix! should not be reset on each call...
        // userLocation = locations.last!
        // let howRecent = abs(userLocation.timestamp.timeIntervalSinceNow)
        
        if shouldPullNotifications() {
            if Config.DEBUG == true { print("trying to pull notifications...") }
            self.lastTimeCheckedForNotifications = Date()
            Net.pullNotificationTask(success: { (result) in
                if Config.DEBUG == true { print("Pull Notification success") }
                let w_result: JSON = result
                if Config.DEBUG == true { print (w_result) }
                let newestTimestamp = w_result[Config.JSON_KEY_DATA][Config.JSON_KEY_NEWEST_TIMESTAMP].double
                if let arr = w_result[Config.JSON_KEY_DATA][Config.JSON_KEY_ITEMS].array {
                    if Config.DEBUG == true { print(arr) }
                    for jobj in arr {
                        if let notify = jobj[Config.JSON_KEY_IS_EMPHASIZED].bool {
                            if notify
                            {
                                self.sendNotification(newsData: jobj, newsTimestamp: newestTimestamp!)
                            }
                        }
                    }
                }
            },
            failure: { (code, errMsg) in
                if Config.DEBUG == true { print("Pull Notification error code: \(code), message: \(errMsg)") }
            })
        }
    }
    
    private func shouldPullNotifications() -> Bool {
        return abs(lastTimeCheckedForNotifications.timeIntervalSinceNow) > Config.NOTIFICATIONS_REFRESH_INTERVAL_IN_SECONDS
    }
    
    private func sendNotification(newsData: JSON, newsTimestamp: Double)
    {
        if Config.DEBUG == true { print("Send Notification") }
        
        let newsID = String(describing: newsData[Config.JSON_KEY_ID].int)
        if ViewModel.notifiedIds.contains(newsID) {
            if Config.DEBUG == true { print("Already sent") }
            // TODO: we need to make sure, these notifications are set to 'seen' on the server!
            return;
        }
        let content = UNMutableNotificationContent()
        content.title = "Neue Aktivität in " + newsData[Config.JSON_KEY_GROUP].string!;
        
        let string = newsData[Config.JSON_KEY_TEXT].string!;
        let str = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        content.subtitle = str
        content.sound = UNNotificationSound.default
        content.userInfo["timestamp"] = newsTimestamp

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: newsID, content: content, trigger: trigger)
        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        ViewModel.notifiedIds.append(newsID);
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if Config.DEBUG == true { print("decidePolicyFor") }
        let request = navigationAction.request
        if Config.DEBUG == true { print("request: ", request) }

        for (key, value) in appsToLaunchByURL
        {
            if (request.url?.absoluteString.hasPrefix(key))!
            {
                if Config.DEBUG == true { print("URL found. Starting external app") }
                launchExternalApp(appInfo: value);
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func launchExternalApp(appInfo: ExternalAppInformation) {
        if let appURL = URL(string: appInfo.appPackage) {
            if UIApplication.shared.canOpenURL(appURL as URL)
            {
                externalAppIsInstalledDialog(appInfo: appInfo)
            }
            else
            {
                externalAppIsNotInstalledDialog(appInfo: appInfo)
            }
        }
    }
    
    func externalAppIsInstalledDialog(appInfo: ExternalAppInformation){
        var message = appInfo.appTitleResourceKey + "ist installiert!"
        message = message + "\n\n" + appInfo.instructionsResourceKey
        
        let alert = UIAlertController(title: "Externe App starten", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: appInfo.appTitleResourceKey + " starten", style: .default) { action in
            if let appURL = URL(string: appInfo.appPackage){
                UIApplication.shared.open(appURL)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel));
        alert.addAction(UIAlertAction(title: "Im Browser öffnen", style: .default){ action in
            
            if let url = URL(string: appInfo.browserURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    func externalAppIsNotInstalledDialog(appInfo: ExternalAppInformation){
        var message = appInfo.appTitleResourceKey + " ist nicht installiert!"
        message = message + "\n\n" + "Alternativ kannst du die Anwendung auch im Browser öffnen."
        
        let alert = UIAlertController(title: "Externe App starten", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: appInfo.appTitleResourceKey + " installieren", style: .default) { action in
            
            //Open Appstore
            if let appURL = URL(string: "https://apps.apple.com/de/app/" + appInfo.appPackage){
                UIApplication.shared.open(appURL)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel));
        alert.addAction(UIAlertAction(title: "Im Browser öffnen", style: .default){ action in
            
            if let url = URL(string: appInfo.browserURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
}

