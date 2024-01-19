//  

import Foundation

extension ExternalAppInformation {
    
    static var rocketChat : ExternalAppInformation {
        return ExternalAppInformation(appStoreNameAndIDPartOfURL: Config.ROCKET_CHAT_APP_STORE_ID,
            appURL: Config.WECHANGE_ROCKET_CHAT_APP_URL,
            appTitle: "Rocket Chat",
            installInstructionsText: Config.CHAT_INSTALL_INSTRUCTIONS_TEXT,
            browserURL: Config.WECHANGE_ROCKET_CHAT_URL)
    }
    
    static var BigBlueButton : ExternalAppInformation {
        return ExternalAppInformation(appStoreNameAndIDPartOfURL: Config.BIG_BLUE_BUTTON_APP_STORE_ID,
            appURL: "XYZ not used",
            appTitle: "Big Blue Button Tablet",
            installInstructionsText: "XYZ not used",
            browserURL: "XYZ not used")
    }
}
