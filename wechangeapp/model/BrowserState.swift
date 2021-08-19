import Foundation

// TODO: refactor!! Maybe store persistent data in UserDefaults?

class BrowserState {
      
    static var currentURL:String = Config.WECHANGE_URL;
    static var cookies:[HTTPCookie] = [];
    static var notifiedIds = [""]
}


