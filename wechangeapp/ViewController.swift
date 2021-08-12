/import UIKit
import WebKit
import SwiftyJSON
import CoreLocation
import AppTrackingTransparency
import MapKit
import UserNotifications


let RECENT_LOCATION_TIMESPAN_THRESHOLD = 10.0
let RECENT_LOCATION_SEND_THRESHOLD = 10.0


class ViewController: UIViewController, WKUIDelegate,WKNavigationDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var webView: WKWebView!
    var appsToLaunchByURL:[String:ExternalAppInformation] = [:];
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let exInfo = ExternalAppInformation(inAppPackage: Config.APP_ROCKET_CHAT, inAppTitleResourceKey: "Rocket Chat", inInstructionsResourceKey: "Zur Einrichtung von Rocket.Chat:\n\n1. Klicke auf\"Tritt einem Arbeitsbereich bei\".\n2. Gib als URL \"rocketchat.wechange.de\" ein.\n3.Melde dich anschließend mit deinen WECHANGE-Zugangsdaten an.", inBrowserURL: Config.WECHANGE_ROCKET_CHAT_URL)
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
                print("name: \(cookie.name) value: \(cookie.value)")
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
        print("CLLocationManager:didUpdateLocations called");
        var userLocation: CLLocation = CLLocation()
        var previousUpdate:TimeInterval = 0
        
        userLocation = locations.last!
        
        let howRecent = abs(userLocation.timestamp.timeIntervalSinceNow)
        let timestamp = NSDate().timeIntervalSince1970
        
        if  howRecent < RECENT_LOCATION_TIMESPAN_THRESHOLD &&
            (previousUpdate == 0 || timestamp - previousUpdate > RECENT_LOCATION_SEND_THRESHOLD) {
            previousUpdate = timestamp
            
            //Test Pull Notification
            Net.pullNotificationTask(success: { (result) in
                print("Pull Notification success")
                let w_result: JSON = result
                print (w_result);
                let newestTimestamp = w_result[Config.JSON_KEY_DATA][Config.JSON_KEY_NEWEST_TIMESTAMP].double
                if let arr = w_result[Config.JSON_KEY_DATA][Config.JSON_KEY_ITEMS].array {
                    print(arr);
                    for jobj in arr {
                        if let notify = jobj[Config.JSON_KEY_IS_EMPHASIZED].bool {
                            if notify
                            {
                                self.sendNotification(data: jobj, timestamp: newestTimestamp!)
                            }
                        }
                    }
                }
            },
            failure: { (code, errMsg) in
                print("Pull Notification error code: \(code), message: \(errMsg)")
            })
        }
    }
    
    
    func sendNotification(data p_data:JSON, timestamp p_timestamp:Double)
    {
        print("Send Notification")
        
        let nid = p_data[Config.JSON_KEY_ID].int;
        let idString = String(describing: nid)
        if ViewModel.notifiedIds.contains(idString) {
            print("Already sent")
            return;
        }
        let content = UNMutableNotificationContent()
        content.title = "Neue Aktivität in " + p_data[Config.JSON_KEY_GROUP].string!;
        
        var string = p_data[Config.JSON_KEY_TEXT].string!;
        let str = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        content.subtitle = str
        content.sound = UNNotificationSound.default
        content.userInfo["timestamp"] = p_timestamp

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: idString, content: content, trigger: trigger)
        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        ViewModel.notifiedIds.append(idString);
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor")
        let request = navigationAction.request
        print("request: ", request)

        for (key, value) in appsToLaunchByURL
        {
            if (request.url?.absoluteString.hasPrefix(key))!
            {
                print("URL found. Starting external app")
                launchExternalApp(appInfo: value);
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func launchExternalApp(appInfo p_appInfo:ExternalAppInformation) {
        if let appURL = URL(string: p_appInfo.appPackage) {
            if UIApplication.shared.canOpenURL(appURL as URL)
            {
                self.externalInstallDialog(appInfo: p_appInfo)
            }
            else
            {
                self.externalNotInstallDialog(appInfo: p_appInfo)
            }
        }
    }
    
    func externalInstallDialog(appInfo:ExternalAppInformation){
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
                UIApplication.shared.openURL(url)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    func externalNotInstallDialog(appInfo:ExternalAppInformation){
        var message = appInfo.appTitleResourceKey + " ist nicht installiert!"
        message = message + "\n\n" + "Alternativ kannst du die Anwendung auch im Browser öffnen."
        
        let alert = UIAlertController(title: "Externe App starten", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: appInfo.appTitleResourceKey + " installieren", style: .default) { action in
            
            //Open Appstore
            if let appURL = URL(string: "market://details?id=" + appInfo.appPackage){
                UIApplication.shared.openURL(appURL)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel));
        alert.addAction(UIAlertAction(title: "Im Browser öffnen", style: .default){ action in
            
            if let url = URL(string: appInfo.browserURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
//    -(void) reloadWebView: (UIRefreshControl *) sender
//    {
//        [self.webView reload];
//        [sender endRefreshing];
//    }
//    - (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation {
//        NSLog(@"%s", __PRETTY_FUNCTION__);
//        NSURL *u1 = webView.URL;  //By this time it's changed
//        NSLog(@"%@", u1);
//        if ([u1.absoluteString rangeOfString:@"logout"].location != NSNotFound)
//        {
//            [Globals clearUserInfo];
//            LoginViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
//            [self presentViewController:vc animated:YES completion:nil];
//        }
//    }
    
//
//    g_ProgressUtil.showProgress()
//           Net.getDriverDetail(
//               driverid: g_MeInfo.driver_id,
//               success: { (result) in
//                   g_ProgressUtil.hideProgress()
//                   print("getDriverDetail success")
//                   let w_result: JSON = result
//                   if w_result["retcode"].int! == 0 {
//                       let retdata = w_result["retdata"][0]
//                       let m_driver:DriverV2Info = DriverV2Info(json: retdata)
//
//                       let vc = GarageEditV2VC(nibName: "GarageEditV2VC", bundle: nil)
//                       vc.m_driver = m_driver
//                       let commonVC = vc as CommonViewController
//                       commonVC._delegate = self
//                       self.navigationController?.pushViewController(vc, animated: true)
//                   } else {
//                       print("getDriverDetail error message: \(w_result["retmsg"].string!)")
//                       self.view.makeToast(w_result["retmsg"].stringValue)
//                   }
//           },
//               failure: { (code, errMsg) in
//                   g_ProgressUtil.hideProgress()
//                   print("getDriverDetail error code: \(code), message: \(errMsg)")
//           }
//           )
//
//
//
    
}

