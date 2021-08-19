import Alamofire
import SwiftyJSON


struct NetHelper {
    
    public typealias SuccessBlock = (JSON) -> Void
    public typealias FailureBlock = (_ code: Int, _ errMsg: String) -> Void
        
    static func doRequestWithHeader(
        url:String,
        method: Alamofire.HTTPMethod,
        headers: HTTPHeaders,
        successHandler: SuccessBlock?,
        failureHandler: FailureBlock?) {
        
        for cookie in BrowserState.cookies {
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
        
        AF.request(url, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers){
            $0.timeoutInterval = 20.0
        }.responseJSON {
            response in
            switch response.result {
            case .failure(let error):
                if let failureHandler = failureHandler {
                    if Config.DEBUG == true {
                        print("\n\nAPICallFailed!")
                        print("URL:\(url)")
                        print("Error:\(error.localizedDescription)")
                        if let responseData = response.data { print("Response:\(String(describing: responseData))")
                        }
                    }
                    failureHandler(999, "Can't connect to the server!")
                }
                return
            case .success(let json):
                if let successHandler = successHandler {
                    successHandler(JSON(json))
                }
            }
        }
    }
}
