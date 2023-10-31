//
//  NGDevice.swift
//  NGSDK
//
//  Created by Paul on 2023/2/16.
//

import UIKit

//#import <sys/utsname.h>
//#include <sys/sysctl.h>
//
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>

extension UIDevice {
    
    class func uuid() -> String{
        
        var uuid = UserDefaults.standard.string(forKey: "NGUUIDCache") ?? ""
        if uuid.isEmpty {
            
            uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            if uuid.isEmpty {
                uuid = UUID().uuidString
            }
            UserDefaults.standard.set(uuid, forKey: "NGUUIDCache")
        }
        return uuid
    }
    
    class func platform() -> String{
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let platform = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if platform == "iPhone3,1" { return "iPhone 4 (A1332)" }
           if platform == "iPhone3,2" { return "iPhone 4 (A1332)" }
           if platform == "iPhone3,3" { return "iPhone 4 (A1349)" }
           if platform == "iPhone4,1" { return "iPhone 4s (A1387/A1431)" }
           if platform == "iPhone5,1" { return "iPhone 5 (A1428)" }
           if platform == "iPhone5,2" { return "iPhone 5 (A1429/A1442)" }
           if platform == "iPhone5,3" { return "iPhone 5c (A1456/A1532)" }
           if platform == "iPhone5,4" { return "iPhone 5c (A1507/A1516/A1526/A1529)" }
           if platform == "iPhone6,1" { return "iPhone 5s (A1453/A1533)" }
           if platform == "iPhone6,2" { return "iPhone 5s (A1457/A1518/A1528/A1530)" }
           if platform == "iPhone7,1" { return "iPhone 6 Plus (A1522/A1524)" }
           if platform == "iPhone7,2" { return "iPhone 6 (A1549/A1586)" }
           if platform == "iPhone8,1" { return "iPhone 6s" }
           if platform == "iPhone8,2" { return "iPhone 6s Plus" }
           if platform == "iPhone9,1" { return "iPhone 7 (Global)" }
           if platform == "iPhone9,3" { return "iPhone 7 (GSM)" }
           if platform == "iPhone9,2" { return "iPhone 7 Plus (Global)" }
           if platform == "iPhone9,4" { return "iPhone 7 Plus (GSM)" }
           if platform == "iPhone10,1" { return "iPhone 8 (Global)" }
           if platform == "iPhone10,4" { return "iPhone 8 (GSM)" }
           if platform == "iPhone10,2" { return "iPhone 8 Plus (Global)" }
           if platform == "iPhone10,5" { return "iPhone 8 Plus (GSM)" }
           if platform == "iPhone10,3" { return "iPhone X (Global)" }
           if platform == "iPhone10,6" { return "iPhone X (GSM)" }
           if platform == "iPhone11,2" { return "iPhone XS" }
           if platform == "iPhone11,4" { return "iPhone XS Max" }
           if platform == "iPhone11,6" { return "iPhone XS Max" }
           if platform == "iPhone11,8" { return "iPhone XR" }

           if platform == "iPhone12,1" { return "iPhone 11" }
           if platform == "iPhone12,3" { return "iPhone 11 Pro" }
           if platform == "iPhone12,5" { return "iPhone 11 Pro Max" }
           if platform == "iPhone12,8" { return "iPhone SE 2" }

           if platform == "iPhone13,1" { return "iPhone 12 mini" }
           if platform == "iPhone13,2" { return "iPhone 12" }
           if platform == "iPhone13,3" { return "iPhone 12 Pro" }
           if platform == "iPhone13,4" { return "iPhone 12 Pro Max" }

            if platform == "iPhone14,4" { return "iPhone 13 mini" }
            if platform == "iPhone14,5" { return "iPhone 13" }
            if platform == "iPhone14,2" { return "iPhone 13 Pro" }
            if platform == "iPhone14,3" { return "iPhone 13 Pro Max" }
            if platform == "iPhone14,6" { return "iPhone SE 3" }

            if platform == "iPhone14,7" { return "iPhone 14" }
            if platform == "iPhone14,8" { return "iPhone 14 Plus" }
            if platform == "iPhone15,2" { return "iPhone 14 Pro" }
            if platform == "iPhone15,3" { return "iPhone 14 Pro Max" }

           if platform == "iPod1,1"   { return "iPod Touch 1G (A1213)" }
           if platform == "iPod2,1"   { return "iPod Touch 2G (A1288)" }
           if platform == "iPod3,1"   { return "iPod Touch 3G (A1318)" }
           if platform == "iPod4,1"   { return "iPod Touch 4G (A1367)" }
           if platform == "iPod5,1"   { return "iPod Touch 5G (A1421/A1509)" }

           if platform == "iPad1,1"   { return "iPad 1G (A1219/A1337)" }

           if platform == "iPad2,1"   { return "iPad 2 (A1395)" }
           if platform == "iPad2,2"   { return "iPad 2 (A1396)" }
           if platform == "iPad2,3"   { return "iPad 2 (A1397)" }
           if platform == "iPad2,4"   { return "iPad 2 (A1395+New Chip)" }
           if platform == "iPad2,5"   { return "iPad Mini 1G (A1432)" }
           if platform == "iPad2,6"   { return "iPad Mini 1G (A1454)" }
           if platform == "iPad2,7"   { return "iPad Mini 1G (A1455)" }

           if platform == "iPad3,1"   { return "iPad 3 (A1416)" }
           if platform == "iPad3,2"   { return "iPad 3 (A1403)" }
           if platform == "iPad3,3"   { return "iPad 3 (A1430)" }
           if platform == "iPad3,4"   { return "iPad 4 (A1458)" }
           if platform == "iPad3,5"   { return "iPad 4 (A1459)" }
           if platform == "iPad3,6"   { return "iPad 4 (A1460)" }

           if platform == "iPad4,1"   { return "iPad Air (A1474)" }
           if platform == "iPad4,2"   { return "iPad Air (A1475)" }
           if platform == "iPad4,3"   { return "iPad Air (A1476)" }
           if platform == "iPad4,4"   { return "iPad Mini 2G (A1489)" }
           if platform == "iPad4,5"   { return "iPad Mini 2G (A1490)" }
           if platform == "iPad4,6"   { return "iPad Mini 2G (A1491)" }

           if platform == "iPad5,3"   { return "iPad Air 2 (A1566)" }
           if platform == "iPad5,4"   { return "iPad Air 2 (A1567)" }

           if platform == "iPad11,3"   { return "iPad Air 3 (A2152)" }
           if platform == "iPad11,4"   { return "iPad Air 3 (A2123 A2153 A2154)" }

           if platform == "iPad13,1"   { return "iPad Air 4 (A2316)" }
           if platform == "iPad13,2"   { return "iPad Air 4 (A2324 A2325 A2072)" }

           if platform == "iPad13,16"   { return "iPad Air 5 (A2588)" }
           if platform == "iPad13,17"   { return "iPad Air 5 (A2589 A2591)" }

           if platform == "i386"      { return "iPhone Simulator" }
           if platform == "x86_64"    { return "iPhone Simulator" }

           return platform
    }
    
    class func brand() -> String{
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:    return "iPhone"
            case .pad:      return "iPad"
            case .tv:       return "TV"
            case .carPlay:  return "CarPlay"
            case .mac:      return "Mac"
            default:        return "未知设备"
        }
    }
    
    class func language() -> String?{
        if Locale.preferredLanguages.isEmpty {
            return Locale.current.languageCode
        } else {
            return Locale.preferredLanguages.first
        }
    }
    
    class func systemVersion() -> String?{
        return UIDevice.current.systemVersion
    }
    
    class func systemName() -> String?{
        return UIDevice.current.systemName
    }
    
    class func name() -> String?{
        return UIDevice.current.name
    }
    
    class func bundleName() -> String?{
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    class func bundleID() -> String?{
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
    }
    
    class func appVersion() -> String?{
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    class func bundleVersion() -> String?{
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    
}
