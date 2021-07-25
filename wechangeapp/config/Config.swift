//
//  Config.swift
//  wechangeapp
//
//  Created by Shadow on 2021/7/15.
//

import Foundation
class Config {
    static var WECHANGE_URL: String = "https://wechange.de/dashboard/"
    static var NOTIFICATION_URL: String = "https://wechange.de/profile/api/alerts/get/"
    static var MARKSEEN_URL: String = "https://wechange.de/profile/api/alerts/markseen/"
    static var DASHBOARD_URL: String = "https://wechange.de/dashboard/"
    static var WECHANGE_MESSAGES_URL: String = "https://wechange.de/messages/"
    static var WECHANGE_ROCKET_CHAT_URL: String = "https://rocketchat.wechange.de"
    
    static var APP_ROCKET_CHAT: String = "chat.rocket.android"
    
    static var NOTIFICATIONS_REFRESH_INTERVAL: Double = 10 * 60 * 1000
    static var CHANNEL_PLATFORM_NOTIFICATIONS_ID: String = "platform_notifications"
    static var REQUEST_TIMER_EVERY_TEN_MINUTES: Int = 1
    
    static var INTENT_KEY_URL: String = "url"
    static var INTENT_KEY_TIMESTAMP: String = "timestampToMarkAsSeen"
    
    static var JSON_KEY_DATA: String = "data"
    static var JSON_KEY_NEWEST_TIMESTAMP: String = "newest_timestamp"
    static var JSON_KEY_ITEMS: String = "items"
    static var JSON_KEY_IS_EMPHASIZED: String = "is_emphasized"
    static var JSON_KEY_TEXT: String = "text"
    static var JSON_KEY_GROUP: String = "group"
    static var JSON_KEY_ID: String = "id"
    static var JSON_KEY_URL: String = "url"
    
    static var HTTP_HEADER_COOKIE: String = "Cookie"
    static var HTTP_HEADER_CSFR_TOKEN: String = "X-CSRFToken"
    static var HTTP_HEADER_REFERER: String = "Referer"
    
    static var TAG_EXTERNAL_APP_INSTALLED: String = "external-app-installed"
    static var TAG_EXTERNAL_APP_NOT_INSTALLED: String = "external-app-not-installed"
}
