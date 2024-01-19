import UIKit
import WebKit

struct BigBlueButtonLaunchOptionManager {
    
    
    static func showAlertWithOpeningOptionsForVideoConference(appInfo: ExternalAppInformation, presentingViewController vc: UIViewController, meetingURL: URL, webViewDecisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        var message = "The open source video conference tool 'BigBlueButton' does not always work as expected, when embedded in an iOS app. You have the following options:"
        
        let isAppInstalled = UIApplication.shared.canOpenURL(URL(string: appInfo.appURL)! as URL)
        
        let alert = UIAlertController(title: "Join Video Conference", message: message, preferredStyle: .alert)
        
        // alert.addAction(UIAlertAction(title: appInfo.appTitle + " starten", style: .default) { action in
        // if let appLaunchURL = URL(string: appInfo.appURL) {
        //        UIApplication.shared.open(appLaunchURL)
        //    }
        //    _ = vc.navigationController?.popViewController(animated: true)
        // })
        
            
        alert.addAction(UIAlertAction(title: "Open in browser", style: .default){ action in
            if (UIApplication.shared.canOpenURL(meetingURL)) {
                if Config.DEBUG == true { print("Trying to open URL: \(meetingURL)") }
                UIApplication.shared.open(meetingURL)
                webViewDecisionHandler(WKNavigationActionPolicy.cancel)
            }
            _ = vc.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Try to open in this app", style: .default){ action in
            if (UIApplication.shared.canOpenURL(meetingURL)) {
                if Config.DEBUG == true { print("Trying to open URL in the WKWebView: \(meetingURL)") }
                webViewDecisionHandler(WKNavigationActionPolicy.allow)
            }
            _ = vc.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){ action in
            webViewDecisionHandler(WKNavigationActionPolicy.cancel)
            _ = vc.navigationController?.popViewController(animated: true)
            })
        
        vc.present(alert, animated: true)
    }

}

