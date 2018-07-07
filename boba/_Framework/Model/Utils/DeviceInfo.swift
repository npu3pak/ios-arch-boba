//
//  DeviceInfo.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

enum DisplayType: Int {
    case unknown = 0
    case iphone4 = 1
    case iphone5 = 2
    case iphone6 = 3
    case iphone6plus = 4
    case iphoneX = 5
    case iPadNonRetina = 6
    case iPad = 7
    case iPadProBig = 8
    static let iphone7 = iphone6
    static let iphone7plus = iphone6plus
    static let iphone8 = iphone6
    static let iphone8plus = iphone6plus
}

class DeviceInfo {
    class var width: CGFloat { return UIScreen.main.bounds.size.width }
    class var height: CGFloat { return UIScreen.main.bounds.size.height }
    class var maxLength: CGFloat { return max(width, height) }
    class var minLength: CGFloat { return min(width, height) }
    class var zoomed: Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    class var retina: Bool { return UIScreen.main.scale >= 2.0 }
    class var phone: Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    class var pad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    class var carplay: Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
    class var tv: Bool { return UIDevice.current.userInterfaceIdiom == .tv }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
     class var typeIsLike: DisplayType {
        let phone = self.phone
        let pad = self.pad
        let maxLength = self.maxLength
        let retina = self.retina
        
        if phone && maxLength < 568 {
            return .iphone4
        } else if phone && maxLength == 568 {
            return .iphone5
        } else if phone && maxLength == 667 {
            return .iphone6
        } else if phone && maxLength == 736 {
            return .iphone6plus
        } else if phone && maxLength == 812 {
            return .iphoneX
        } else if pad && !retina {
            return .iPadNonRetina
        } else if pad && retina && maxLength == 1024 {
            return .iPad
        } else if pad && maxLength == 1366 {
            return .iPadProBig
        }
        return .unknown
    }
    
    class var deviceModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:
            if identifier.hasPrefix("iPhone") {
                return "Unknown iPhone"
            }
            if identifier.hasPrefix("iPad") {
                return "Unknown iPad"
            }
            if identifier.hasPrefix("iPod") {
                return "Unknown iPod"
            } else {
                return "Unknown iOS device"
            }
        }
    }
}
