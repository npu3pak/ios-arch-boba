//
//  AppInfo.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

class AppInfo {
    static var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
