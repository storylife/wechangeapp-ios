import UIKit
import WebKit
import SwiftyJSON
import AppTrackingTransparency
import UserNotifications


class WeChangeViewController: UIViewController, WKUIDelegate,WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    var appsToLaunchByURL:[String:ExternalAppInformation] = [:];
    var lastTimeCheckedForNewsUpdates = Date()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        appsToLaunchByURL[Config.WECHANGE_MESSAGES_URL] = ExternalAppInformation.rocketChat
        self.webView.navigationDelegate = self;
        self.webView.uiDelegate = self;
        self.webView.scrollView.showsHorizontalScrollIndicator = false

        let currentURL = URL(string:BrowserState.currentURL)!
        let request = URLRequest(url: currentURL)
        webView.load(request)
        WeChangeAPIManager.manageCookie(forUrlSession: URLSession.shared, url: currentURL)
        
        setupWebNavigationButtons()
    }
    
    private func setupWebNavigationButtons() {
        backButton.setTitle("", for: .normal)
        backButton.isEnabled = false;
        forwardButton.setTitle("", for: .normal)
        forwardButton.isEnabled = false;
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if Config.DEBUG == true { print("decidePolicyFor") }
        let request = navigationAction.request
        if Config.DEBUG == true { print("request: ", request) }
        
        var isDecisionHandlerCalledElsewhere = false

        for (appURLScheme, externalAppInfo) in appsToLaunchByURL
        {
            if (request.url?.absoluteString.hasPrefix(appURLScheme))!
            {
                if Config.DEBUG == true { print("URL found. Trying to start external app") }
                isDecisionHandlerCalledElsewhere = true
                ExternalAppManager.startExternalAppDialog(appInfo: externalAppInfo, fromViewController: self, webViewDecisionHandler: decisionHandler);
            }
        }
        if (doesNavigationRequestWantToStartBBBMeeting(request: request)) {
            print("Trying to start BBB meeting!")
            // TODO: check permissions for camera and microphone access and if necessary ask the user
            // but this shouldn't have any impact on BBB to work: it's possible to join a meeting
            // just as a consumer, without sharing video and/or audio
            isDecisionHandlerCalledElsewhere = true
            decisionHandler(WKNavigationActionPolicy.allow)
        }
        
        if (!isDecisionHandlerCalledElsewhere) {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    func doesNavigationRequestWantToStartBBBMeeting(request: URLRequest) -> Bool {
        return request.url != nil ? request.url!.absoluteString.hasSuffix("/meeting/") : false
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            backButton.isEnabled = webView.canGoBack ? true : false
            forwardButton.isEnabled = webView.canGoForward ? true : false
    }
    
    @IBAction func backButtonTapped() {
        if(webView.canGoBack) {
            webView.goBack()
        }
    }
    
    @IBAction func forwardButtonTapped() {
        if(webView.canGoForward) {
            webView.goForward()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
    
    
}
