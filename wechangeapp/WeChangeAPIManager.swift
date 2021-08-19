import UIKit
import Alamofire // TODO: refactor, so that we don't specifically need Alamofire here

struct WeChangeAPIManager {
    
    static func manageCookie(forUrlSession session: URLSession, url: URL) {
        
        let cookieRequest = NSMutableURLRequest(url: url)
        let task = session.dataTask(with: cookieRequest as URLRequest) { data, response, error in
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
    
    static func markNotificationSeen(timestamp : Double, successHandler: NetHelper.SuccessBlock?, failureHandler: NetHelper.FailureBlock?) {
        let url = Config.MARKSEEN_URL + String(format: "%.6f",timestamp);
        if Config.DEBUG == true { print("markseen URL: " + url) }

        let headers:HTTPHeaders = [Config.HTTP_HEADER_REFERER: Config.DASHBOARD_URL];
        NetHelper.doRequestWithHeader(url: url, method: .post, headers: headers, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    static func pullNewsUpdates(successHandler: NetHelper.SuccessBlock?, failureHandler: NetHelper.FailureBlock?) {
        let headers:HTTPHeaders = [];
        NetHelper.doRequestWithHeader(url: Config.NOTIFICATION_URL, method: .get, headers: headers, successHandler: successHandler, failureHandler: failureHandler)
    }
}
