//
//  utilities.swift
//  ServiceLines
//
//  Created by Mac on 19/06/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

extension TimeInterval {
    func timeIntervalAsString(_ format : String = "dd days, hh hours, mm minutes, ss seconds, sss ms") -> String {
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
        let s = asInt % 60
        let m = (asInt / 60) % 60
        let h = ((asInt / 3600))%24
        let d = (asInt / 86400)
        
        var value = format
        value = value.replacingOccurrences(of: "hh", with: String(format: "%0.2d", h))
        value = value.replacingOccurrences(of: "mm",  with: String(format: "%0.2d", m))
        value = value.replacingOccurrences(of: "sss", with: String(format: "%0.3d", ms))
        value = value.replacingOccurrences(of: "ss",  with: String(format: "%0.2d", s))
        value = value.replacingOccurrences(of: "dd",  with: String(format: "%d", d))
        if (ago) {
            value += " ago"
        }
        return value
    }
    
    func timeIntervalAsHours() -> Int{
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
//        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
//        let s = asInt % 60
//        let m = (asInt / 60) % 60
        let h = ((asInt / 3600))%24
//        let d = (asInt / 86400)    }
        return h
    }

    func timeIntervalAsMinutes() -> Int{
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        //        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
        //        let s = asInt % 60
        let m = (asInt / 60) % 60
        //        let h = ((asInt / 3600))%24
        //        let d = (asInt / 86400)    }
        return m
    }

    func timeIntervalAsSecond() -> Int{
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        //        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
        let s = asInt % 60
        //        let m = (asInt / 60) % 60
        //        let h = ((asInt / 3600))%24
        //        let d = (asInt / 86400)    }
        return s
    }

    func timeIntervalAsDate() -> Int{
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        //        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
        //        let s = asInt % 60
        //        let m = (asInt / 60) % 60
        //        let h = ((asInt / 3600))%24
        let days = (asInt / 86400)    
        return days
    }

}
