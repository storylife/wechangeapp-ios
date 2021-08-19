import UIKit
import WebKit
import SwiftyJSON
import AppTrackingTransparency
import UserNotifications


class WeChangeViewController: UIViewController, WKUIDelegate,WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var appsToLaunchByURL:[String:ExternalAppInformation] = [:];
    var lastTimeCheckedForNewsUpdates = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rocketChatAppInfo = ExternalAppInformation(appStoreNameAndIDPartOfURL: Config.ROCKET_CHAT_APP_STORE_ID,
                                                       appURL: Config.WECHANGE_ROCKET_CHAT_APP_URL,
                                                       appTitle: "Rocket Chat",
                                                       installInstructionsText: Config.CHAT_INSTALL_INSTRUCTIONS_TEXT,
                                                       browserURL: Config.WECHANGE_ROCKET_CHAT_URL)
        appsToLaunchByURL[Config.WECHANGE_MESSAGES_URL] = rocketChatAppInfo;
        self.webView.navigationDelegate = self;
        self.webView.uiDelegate = self;
        
        let link = URL(string:BrowserState.currentURL)!
        let request = URLRequest(url: link)
        webView.load(request)
        
        
        let session = URLSession.shared
        let requestCookie = NSMutableURLRequest(url: NSURL(string: BrowserState.currentURL)! as URL)
        let task = session.dataTask(with: requestCookie as URLRequest) { data, response, error in
            guard
                let url = response?.url,
                let httpResponse = response as? HTTPURLResponse,
                let fields = httpResponse.allHeaderFields as? [String: String]
            else { return }

            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            BrowserState.cookies = cookies;
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
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if Config.DEBUG == true { print("decidePolicyFor") }
        let request = navigationAction.request
        if Config.DEBUG == true { print("request: ", request) }

        for (appURLScheme, externalAppInfo) in appsToLaunchByURL
        {
            if (request.url?.absoluteString.hasPrefix(appURLScheme))!
            {
                if Config.DEBUG == true { print("URL found. Trying to start external app") }
                ExternalAppManager.startExternalAppDialog(appInfo: externalAppInfo, fromViewController: self);
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}
