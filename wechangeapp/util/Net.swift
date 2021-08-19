import UIKit
import Alamofire
import SwiftyJSON


// TODO: refactor to conform to modern code style
open class Net {
    
    public typealias SuccessBlock = (JSON) -> Void
    public typealias FailureBlock = (_ code: Int, _ errMsg: String) -> Void
        
    private static func doRequestWithHeader(
        url     p_url           :String,
        method  p_http_method: Alamofire.HTTPMethod,
        headers  p_headers    : HTTPHeaders,
        success p_success   : SuccessBlock?,
        failure p_failure   : FailureBlock?) {
        
        let url = p_url
        
        for cookie in ViewModel.cookies {
            var cookieProperties = [HTTPCookiePropertyKey: Any]()
            cookieProperties[.name] = cookie.name
            cookieProperties[.value] = cookie.value
            cookieProperties[.domain] = cookie.domain
            cookieProperties[.path] = cookie.path
            cookieProperties[.version] = cookie.version
            cookieProperties[.expires] = Date().addingTimeInterval(31536000)
            
            let newCookie = HTTPCookie(properties: cookieProperties)!
            AF.session.configuration.httpCookieStorage?.setCookie(newCookie)
        }
        
        AF.request(url, method: p_http_method, parameters: nil, encoding: URLEncoding.default, headers: p_headers){
            $0.timeoutInterval = 20.0
        }.responseJSON {
            res in
            switch res.result {
            case .failure(let error):
                if let w_failure = p_failure {
                    if Config.DEBUG == true {
                        print("\n\nAPICallFailed!")
                        print("URL:\(url)")
                        print("Error:\(error.localizedDescription)")
                    }
                    if let w_res_data = res.data {
                        let w_res_data_str = String(describing: w_res_data)
                        if Config.DEBUG == true { print("Response:\(w_res_data_str)") }
                    }
                    w_failure(999, "Can't connect to the server!")
                }
                return
            case .success(let json):
                if let w_success = p_success {
                    w_success(JSON(json))
                }
            }
        }
    }
    
    public static func markNotificationSeen(timestamp : Double, successHandler: SuccessBlock?, failureHandler: FailureBlock?) {
        let url = Config.MARKSEEN_URL + String(format: "%.6f",timestamp);
        if Config.DEBUG == true { print("markseen URL: " + url) }

        let headers:HTTPHeaders = [Config.HTTP_HEADER_REFERER: Config.DASHBOARD_URL];
        doRequestWithHeader(url: url, method: .post, headers: headers, success: successHandler, failure: failureHandler)
    }
    
    public static func pullNewsUpdates(
        success p_success   : SuccessBlock?,
        failure p_failure   : FailureBlock?
    )
    {
        let headers:HTTPHeaders = [];
        doRequestWithHeader(url: Config.NOTIFICATION_URL, method: .get, headers: headers, success: p_success, failure: p_failure)
    }
}
