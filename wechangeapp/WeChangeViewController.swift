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

        appsToLaunchByURL[Config.WECHANGE_MESSAGES_URL] = ExternalAppInformation.rocketChat
        self.webView.navigationDelegate = self;
        self.webView.uiDelegate = self;
        
        let currentURL = URL(string:BrowserState.currentURL)!
        let request = URLRequest(url: currentURL)
        webView.load(request)
        WeChangeAPIManager.manageCookie(forUrlSession: URLSession.shared, url: currentURL)
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
        decisionHandler(WKNavigationActionPolicy.allow) // TODO: check if it's better to pass this handler to the dialog and to not allow if external app gets started
    }
}
