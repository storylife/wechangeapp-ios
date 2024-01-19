import UIKit
import WebKit

struct ExternalAppManager {
    
    static func startExternalAppDialog(appInfo: ExternalAppInformation, fromViewController vc: UIViewController, webViewDecisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let appLaunchURL = URL(string: appInfo.appURL) {
            if Config.DEBUG == true { print("Check if device has an app for this URL scheme: \(appLaunchURL)") }
            if UIApplication.shared.canOpenURL(appLaunchURL as URL){
                externalAppIsInstalledDialog(appInfo: appInfo, presentingViewController: vc, webViewDecisionHandler: webViewDecisionHandler)
            } else {
                if Config.DEBUG == true { print("No App found for this URL: \(appLaunchURL)") }
                externalAppIsNotInstalledDialog(appInfo: appInfo, presentingViewController: vc, webViewDecisionHandler: webViewDecisionHandler)
            }
        }
    }
    
    // TODO: maybe we should remember the user's decision and add an option 'always open the external app?'
    private static func externalAppIsInstalledDialog(appInfo: ExternalAppInformation, presentingViewController vc: UIViewController, webViewDecisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        var message = appInfo.appTitle + "ist installiert!"
        message = message + "\n\n" + appInfo.installInstructionsText
        
        let alert = UIAlertController(title: "Externe App starten", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: appInfo.appTitle + " starten", style: .default) { action in
            if let appLaunchURL = URL(string: appInfo.appURL) {
                UIApplication.shared.open(appLaunchURL)
            }
            _ = vc.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel));
        alert.addAction(UIAlertAction(title: "Im Browser öffnen", style: .default){ action in
            if let browserURL = URL(string: appInfo.browserURL), UIApplication.shared.canOpenURL(browserURL) {
                if Config.DEBUG == true { print("Trying to open URL: \(browserURL)") }
                UIApplication.shared.open(browserURL)
            }
            _ = vc.navigationController?.popViewController(animated: true)
        })
        webViewDecisionHandler(WKNavigationActionPolicy.cancel) // whatever the decision: don't try to navigate to URL in WKWebView
        vc.present(alert, animated: true)
    }
    
    private static func externalAppIsNotInstalledDialog(appInfo: ExternalAppInformation, presentingViewController vc: UIViewController, webViewDecisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        var message = appInfo.appTitle + " ist nicht installiert!"
        message = message + "\n\n" + "Alternativ kannst du die Anwendung auch im Browser öffnen."
        
        let alert = UIAlertController(title: "Externe App starten", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: appInfo.appTitle + " installieren", style: .default) { action in
            
            //Open Appstore
            if let appURL = URL(string: "https://apps.apple.com/de/app/" + appInfo.appStoreNameAndIDPartOfURL){
                UIApplication.shared.open(appURL)
            }
            _ = vc.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel));
        alert.addAction(UIAlertAction(title: "Im Browser öffnen", style: .default){ action in
            
            if let browserURL = URL(string: appInfo.browserURL), UIApplication.shared.canOpenURL(browserURL) {
                if Config.DEBUG == true { print("Trying to open URL: \(browserURL)") }
                UIApplication.shared.open(browserURL)
            }
            _ = vc.navigationController?.popViewController(animated: true)
        })
        
        webViewDecisionHandler(WKNavigationActionPolicy.cancel) // whatever the decision: don't try to navigate to URL in WKWebView
        vc.present(alert, animated: true)
    }
}
