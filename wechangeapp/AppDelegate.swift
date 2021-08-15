import UIKit
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print(error) // TODO: handle error!
            }
        }
        
        // Fetch data once an hour.
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        if Config.DEBUG == true { print("\(String(describing: userInfo))") }
        guard let notificationTimestamp = userInfo["timestamp"] as? Double else {
            if Config.DEBUG == true { print("notification.userInfo has no timestamp") }
            completionHandler()
            return
        }
        Net.markNotificationSeen(timestamp: notificationTimestamp, successHandler: { jsonResponse in
            if Config.DEBUG == true { print("mark as seen – success! \(jsonResponse)")}
        }, failureHandler: { errorCode, errorMessage in
            if Config.DEBUG == true { print("mark as seen – failed!! Error: \(errorMessage) (\(errorCode))")}
        })
        completionHandler()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Config.DEBUG == true { print("Background Fetch started!!") }
        WeChangeNewsFetcher.fetchNewsUpdates { fetchResult in
            guard let newsContent = fetchResult else { completionHandler(.failed); return }
            let newestTimestamp = newsContent[Config.JSON_KEY_DATA][Config.JSON_KEY_NEWEST_TIMESTAMP].double
            if let newsItems: [JSON] = newsContent[Config.JSON_KEY_DATA][Config.JSON_KEY_ITEMS].array {
                if Config.DEBUG == true { print(newsItems) }
                for jobj in newsItems {
                    if let notify = jobj[Config.JSON_KEY_IS_EMPHASIZED].bool {
                        if notify
                        {
                            WeChangeNotificationManager.showNotification(newsData: jobj, newsTimestamp: newestTimestamp!)
                        }
                    }
                }
                completionHandler(.newData)
                return
            } else {
                completionHandler(.noData)
            }
        }
    }
}
