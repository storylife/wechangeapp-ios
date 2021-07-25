//
//  ExternalAppInformation.swift
//  wechangeapp
//
//  Created by Shadow on 2021/7/15.
//

import Foundation

class ExternalAppInformation {
      
    var appPackage:String;
    var appTitleResourceKey:String;
    var instructionsResourceKey:String;
    var browserURL:String;
    
    
    init(inAppPackage: String, inAppTitleResourceKey:String, inInstructionsResourceKey:String, inBrowserURL:String) {
        self.appPackage = inAppPackage;
        self.appTitleResourceKey = inAppTitleResourceKey;
        self.instructionsResourceKey = inInstructionsResourceKey;
        self.browserURL = inBrowserURL;
    }
    
    func toString() -> Bool {
        return (self.browserURL != nil)
    }
    
}
