//
//  WechangeCookie.swift
//  wechangeapp
//
//  Created by Shadow on 2021/7/15.
//

import Foundation


class WechangeCookie {
    static var KEY_CSRF_TOKEN: String = "csrftoken"
    static var DELIMITER_SEMICOLON: String = "; "
    static var DELIMITER_EQUALS: String = "="
    
    var map = [String:String?]()
    var cookieString:String;
    
    init(inCookie: String) {
        cookieString = inCookie;
        for forKeyValuePair in inCookie.components(separatedBy: WechangeCookie.DELIMITER_SEMICOLON){
            let forCookie = forKeyValuePair.components(separatedBy: WechangeCookie.DELIMITER_EQUALS)
            map[forCookie[0]] = forCookie[1];
        }
    }
    
    func toString() -> String? {
        return cookieString
    }
    
    func getCsrfToken() -> String? {
        return map[WechangeCookie.KEY_CSRF_TOKEN] ?? "";
    }
    
}

