import UIKit
import Alamofire // TODO: refactor HTTPHeaders usage, so that we don't specifically need Alamofire here

struct WeChangeAPIManager {
    
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
