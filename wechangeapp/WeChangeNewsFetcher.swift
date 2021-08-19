//  

import Foundation
import SwiftyJSON

struct WeChangeNewsFetcher {
    
    static func fetchNewsUpdates(completionHandler: @escaping (JSON?) -> Void) {
        if Config.DEBUG == true { print("trying to pull notifications...") }
        WeChangeAPIManager.pullNewsUpdates(successHandler: { (result) in
            if Config.DEBUG == true { print("Pull Notification success") }
            let w_result: JSON = result
            if Config.DEBUG == true { print (w_result) }
            completionHandler(w_result)
        },
        failureHandler: { (code, errMsg) in
            if Config.DEBUG == true { print("Pull Notification error code: \(code), message: \(errMsg)") }
            completionHandler(nil)
        })
    }
    
}
