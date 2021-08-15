import Foundation

// TODO: refactor!! Maybe store persistent data in UserDefaults?

class ViewModel {
      
    static var currentURL:String = Config.WECHANGE_URL;
    //static var cookie:WechangeCookie? = nil;
    static var cookies:[HTTPCookie] = [];
    static var notifiedIds = [""]
}


