import Foundation
enum Config {
    
    static let DEBUG = false
        
    // customer specific constants
    static let URL_PREFIX: String = "https://"
    static let BASE_URL_CORE: String = "meetforchange.ifa.de/"
    static let WECHANGE_URL: String = URL_PREFIX + BASE_URL_CORE + "dashboard/"
    // static let WECHANGE_URL: String = "https://skip.scientists4future.org/dashboard/"
    static let NOTIFICATION_URL: String = URL_PREFIX + BASE_URL_CORE + "/profile/api/alerts/get/"
    static let MARKSEEN_URL: String = URL_PREFIX + BASE_URL_CORE + "/profile/api/alerts/markseen/"
    static let DASHBOARD_URL: String = URL_PREFIX + BASE_URL_CORE + "dashboard/"
    static let WECHANGE_MESSAGES_URL: String = URL_PREFIX + BASE_URL_CORE +  "messages/"
    static let WECHANGE_ROCKET_CHAT_URL: String =  URL_PREFIX + "chat." + BASE_URL_CORE
    static let WECHANGE_ROCKET_CHAT_APP_URL = "rocketchat://chat." + BASE_URL_CORE
    static let WECHANGE_NEXTCLOUD_URL: String = URL_PREFIX + "cloud." + BASE_URL_CORE
    static let CHAT_INSTALL_INSTRUCTIONS_TEXT: String = "Zur Einrichtung von Rocket.Chat:\n\n1. Klicke auf\"Tritt einem Arbeitsbereich bei\".\n2. Gib als URL \"" + "chat." + BASE_URL_CORE + "\" ein.\n3.Melde dich anschließend mit deinen Zugangsdaten an."
    
    
    // generic constants
    static let ROCKET_CHAT_APP_STORE_ID: String = "rocket-chat/id1148741252"
    static let ROCKET_CHAT_UNIVERSAL_URL_PREFIX = "go.rocket.chat"
    
    static let BIG_BLUE_BUTTON_APP_STORE_ID: String = "bigbluebutton-tablet/id1641156756"
    
    static let NOTIFICATIONS_REFRESH_INTERVAL_IN_SECONDS: Double = 10
    static let CHANNEL_PLATFORM_NOTIFICATIONS_ID: String = "platform_notifications"
    static let REQUEST_TIMER_EVERY_TEN_MINUTES: Int = 1
    
    static let INTENT_KEY_URL: String = "url"
    static let INTENT_KEY_TIMESTAMP: String = "timestampToMarkAsSeen"
    
    static let JSON_KEY_DATA: String = "data"
    static let JSON_KEY_NEWEST_TIMESTAMP: String = "newest_timestamp"
    static let JSON_KEY_ITEMS: String = "items"
    static let JSON_KEY_IS_EMPHASIZED: String = "is_emphasized"
    static let JSON_KEY_TEXT: String = "text"
    static let JSON_KEY_GROUP: String = "group"
    static let JSON_KEY_ID: String = "id"
    static let JSON_KEY_URL: String = "url"
    
    static let HTTP_HEADER_COOKIE: String = "Cookie"
    static let HTTP_HEADER_CSFR_TOKEN: String = "X-CSRFToken"
    static let HTTP_HEADER_REFERER: String = "Referer"
    
    static let TAG_EXTERNAL_APP_INSTALLED: String = "external-app-installed"
    static let TAG_EXTERNAL_APP_NOT_INSTALLED: String = "external-app-not-installed"
}

// WeChange default config

//enum Config {
//
//    static let WECHANGE_URL: String = "https://wechange.de/dashboard/"
//    static let NOTIFICATION_URL: String = "https://wechange.de/profile/api/alerts/get/"
//    static let MARKSEEN_URL: String = "https://wechange.de/profile/api/alerts/markseen/"
//    static let DASHBOARD_URL: String = "https://wechange.de/dashboard/"
//    static let WECHANGE_MESSAGES_URL: String = "https://wechange.de/messages/"
//    static let WECHANGE_ROCKET_CHAT_URL: String = "https://rocketchat.wechange.de"
//
//    static let APP_ROCKET_CHAT: String = "chat.rocket.android"
//
//    static let NOTIFICATIONS_REFRESH_INTERVAL: Double = 10 * 60 * 1000
//    static let CHANNEL_PLATFORM_NOTIFICATIONS_ID: String = "platform_notifications"
//    static let REQUEST_TIMER_EVERY_TEN_MINUTES: Int = 1
//
//    static let INTENT_KEY_URL: String = "url"
//    static let INTENT_KEY_TIMESTAMP: String = "timestampToMarkAsSeen"
//
//    static let JSON_KEY_DATA: String = "data"
//    static let JSON_KEY_NEWEST_TIMESTAMP: String = "newest_timestamp"
//    static let JSON_KEY_ITEMS: String = "items"
//    static let JSON_KEY_IS_EMPHASIZED: String = "is_emphasized"
//    static let JSON_KEY_TEXT: String = "text"
//    static let JSON_KEY_GROUP: String = "group"
//    static let JSON_KEY_ID: String = "id"
//    static let JSON_KEY_URL: String = "url"
//
//    static let HTTP_HEADER_COOKIE: String = "Cookie"
//    static let HTTP_HEADER_CSFR_TOKEN: String = "X-CSRFToken"
//    static let HTTP_HEADER_REFERER: String = "Referer"
//
//    static let TAG_EXTERNAL_APP_INSTALLED: String = "external-app-installed"
//    static let TAG_EXTERNAL_APP_NOT_INSTALLED: String = "external-app-not-installed"
//}
    
