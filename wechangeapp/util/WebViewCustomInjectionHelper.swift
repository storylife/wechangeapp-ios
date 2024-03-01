//  

import Foundation
import WebKit


struct WebViewCustomInjectionHelper {
    
    
    // thanks to https://medium.com/@mahdi.mahjoobi/injection-css-and-javascript-in-wkwebview-eabf58e5c54e
    
    static func injectJSIntoPage(webView: WKWebView, jsFileName: String) {
            let jsFile = readFileBy(name: jsFileName, type: "js")
            
            let jsStyle = """
                javascript:(function() {
                var parent = document.getElementsByTagName('head').item(0);
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.innerHTML = window.atob('\(encodeStringTo64(fromString: jsFile)!)');
                parent.appendChild(script)})()
            """

            let jsScript = WKUserScript(source: jsStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            
            webView.configuration.userContentController.addUserScript(jsScript)
        }
    
    static func injectCSSIntoPage(webView: WKWebView, cssFileName: String) {
            let cssFile = readFileBy(name: cssFileName, type: "css")
            
            let cssStyle = """
                javascript:(function() {
                var parent = document.getElementsByTagName('head').item(0);
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = window.atob('\(encodeStringTo64(fromString: cssFile)!)');
                parent.appendChild(style)})()
            """

            let cssScript = WKUserScript(source: cssStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            
            webView.configuration.userContentController.addUserScript(cssScript)
        }
    
        private static func readFileBy(name: String, type: String) -> String {
            guard let path = Bundle.main.path(forResource: name, ofType: type) else {
                if Config.DEBUG == true {print("\nCan't find ressource \name .css")}
                return "Failed to find path"
            }
            
            do {
                return try String(contentsOfFile: path, encoding: .utf8)
            } catch {
                if Config.DEBUG == true {print("\nCan't convert file to utf8 string)")}
                return "Unkown Error"
            }
        }
        
        private static func encodeStringTo64(fromString: String) -> String? {
            let plainData = fromString.data(using: .utf8)
            return plainData?.base64EncodedString(options: [])
        }
}
