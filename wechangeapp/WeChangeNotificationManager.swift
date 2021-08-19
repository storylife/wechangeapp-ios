//  

import Foundation
import UserNotifications
import SwiftyJSON

struct WeChangeNotificationManager {
    
    static func showNotification(newsData: JSON, newsTimestamp: Double)
    {
        if Config.DEBUG == true { print("Send Notification") }
        
        let newsID = String(describing: newsData[Config.JSON_KEY_ID].int)
        if BrowserState.notifiedIds.contains(newsID) {
            if Config.DEBUG == true { print("Already sent") }
            // TODO: we need to make sure, these notifications are set to 'seen' on the server!
            return;
        }
        let content = UNMutableNotificationContent()
        content.title = "Neue Aktivität in " + newsData[Config.JSON_KEY_GROUP].string!;
        
        let string = newsData[Config.JSON_KEY_TEXT].string!;
        let str = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        content.subtitle = str
        content.sound = UNNotificationSound.default
        content.userInfo["timestamp"] = newsTimestamp

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: newsID, content: content, trigger: trigger)
        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        BrowserState.notifiedIds.append(newsID);
    }
}
