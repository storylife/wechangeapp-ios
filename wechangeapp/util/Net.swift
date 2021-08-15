//
//  Net.swift
//  Clover
//
//  Created by Dragon C. on 8/8/16.
//  Copyright © 2016 Dragon C. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

open class Net {
    
    //
    // MARK: API response structure
    //
    public typealias SuccessBlock = (JSON) -> Void
    public typealias FailureBlock = (_ code: Int, _ errMsg: String) -> Void
   
    open class ResponseResult {
        
    }
        
    fileprivate static func doRequestWithHeader(
        url     p_url           :String,
        method  p_http_method: Alamofire.HTTPMethod,
        headers  p_headers    : HTTPHeaders,
        success p_success   : SuccessBlock?,
        failure p_failure   : FailureBlock?
        )
    {
        let timestamp = NSDate().timeIntervalSince1970
        let url = p_url
        if (ViewModel.cookies == nil)
        {
            return;
        }
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
        
        let dataRequest = AF.request(url, method: p_http_method, parameters: nil, encoding: URLEncoding.default, headers: p_headers){
            $0.timeoutInterval = 20.0
        }.responseJSON {
            res in
            switch res.result {
            case .failure(let error):
                if let w_failure = p_failure {
            //        print("\n\nAPICallFailed!")
            //        print("URL:\(url)")
             //       print("Error:\(error.localizedDescription)")
                    if let w_res_data = res.data {
                        let w_res_data_str = String(describing: w_res_data)
                        print("Response:\(w_res_data_str)")
                    }
                    w_failure(999, "Can't connect to the server!")
                }
                return
            case .success(let json):
          //      print("result = \(json)")
                if let w_success = p_success {
                    w_success(JSON(json))
                }
            }
        }
    }
    
//    fileprivate static func doRequestV2(
//        url     p_url           :String,
//        method  p_http_method: Alamofire.HTTPMethod,
//        params  p_params    : [String: AnyObject]?,
//        success p_success   : SuccessBlock?,
//        failure p_failure   : FailureBlock?
//        )
//    {
//        let url = SERVER_URL_V2 + p_api_id.rawValue
//      //  print("params = \(url)\n\(p_params)")
//
//        let headers:HTTPHeaders = ["Content-type":"application/x-www-form-urlencoded",
//                                  "Accept":"application/json",
//                                  "Auth-Token": "1094e11c-86ae-11e8-95bc-0201dccf9ce0"];
//
//        AF.request(url, method: p_http_method, parameters: p_params, encoding: URLEncoding.default, headers: headers){
//            $0.timeoutInterval = 20.0
//        }
//            .responseJSON {
//                res in
//                switch res.result {
//                case .failure(let error):
//                    if let w_failure = p_failure {
//                //        print("\n\nAPICallFailed!")
//                //        print("URL:\(url)")
//                 //       print("Error:\(error.localizedDescription)")
//                        if let w_res_data = res.data {
//                            let w_res_data_str = String(describing: w_res_data)
//                            print("Response:\(w_res_data_str)")
//                        }
//                        w_failure(999, "Can't connect to the server!")
//                    }
//                    return
//                case .success(let json):
//              //      print("result = \(json)")
//                    if let w_success = p_success {
//                        w_success(JSON(json))
//                    }
//                }
//        }
//    }
    
    public static func markNotificationSeenTask(
        timestamp   p_timestamp         : Double
    )
    {
        let url = Config.MARKSEEN_URL + String(format: "%.6f",p_timestamp);
        print("markseen URL: " + url)
//        
        let headers:HTTPHeaders = [Config.HTTP_HEADER_REFERER: Config.DASHBOARD_URL];
        doRequestWithHeader(url: url, method: .post, headers: headers, success: nil, failure: nil)
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
