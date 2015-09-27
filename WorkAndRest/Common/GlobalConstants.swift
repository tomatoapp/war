//
//  GlobalConstants.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class GlobalConstants {
    class var k_APPID: String { return "868078759" }
    class var APPSTORE_URL: String { return "itms-apps://itunes.apple.com/app/id868078759" }
    class var VERSION: String { return "2.2.1" }
    class var EMAIL_ADDRESS: String {return "lunars.service@yahoo.com" }
    
    class var k_HASRAN_BEFORE: String { return "HasRanBefore" } // Not the first launch
    class var kBOOL_firstLaunch: String { return "FirstLaunch" }
    class var kBOOL_hasShownMarkDoneTutorial: String { return "ShownMarkDoneTutorial" }
    class var k_FirstLauchDate: String { return "FirstLauchDate" }
    class var kBOOL_ISWORKING: String { return "isWorking" }
    class var k_FROZEN_DATE: String { return "FrozenDate" }
    class var k_SECONDS_LEFT: String { return "SecondsLeft" }
    class var kBOOL_SECOND_SOUND: String { return "SecondSound" }
    class var kBOOL_KEEP_LIGHT: String { return "KeepLight" }
    class var k_SECONDS: String { return "Seconds" }
    class var kBOOL_BADGEAPPICON: String { return "badgeAppIcon" }
    class var kBOOL_IS_DETERMINATION: String { return "isDetermination" }
    class var DEFAULT_MINUTES: Int { return 25 }
    class var DEFAULT_NUMBER: Int { return 1 }
    class var TITLE_MAXLENGTH: Int { return 50 }
    class var kBOOL_Purchased: String { return "Purchased" }
    class var kBOOL_HAS_SETUP_SAMPLE_TASK: String { return "HasSetupSampleTask" }
    class var kBOOL_HAS_SHOW_GUIDE: String { return "HasShowGuide" }
    class var kBOOL_HAS_SHOW_EDIT_TITLE_GUIDE: String { return "HasShowEditTitleGuide" }
    class var kBOOL_HAS_SHOW_SWIPE_CELL_RIGHT_GUIDE: String { return "HasShowSwipeCellRightGuide" }
    class var kBOOL_HAS_SHOW_CREATE_TASK_GUIDE: String { return "HasShowCreateTaskGuide" }
    class var kBOOL_HAS_SHOW_START_TASK_GUIDE: String { return "HasShowStartTaskGuide" }
    
    class var NOTIFICATION_FREQUENCY_IDLEWATCHER: Int { return 7 } // Days
}
