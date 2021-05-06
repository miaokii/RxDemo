//
//  DateEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//
import UIKit

public extension Date {
    
    init?(string: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        guard let date = formatter.date(from: string) else {
            return nil
        }
        self.init(timeInterval:0, since: date)
    }
    
    /// 从时间戳转换日期，stamp单位为毫秒
    init?(time stamp: String?) {
        guard let timeInterval = TimeInterval(stamp ?? "") else {
            return nil
        }
        self.init(timeIntervalSince1970: timeInterval/1000)
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func fromStringToDate(_ string :String,_ format:String) ->Date{
        let dformatter = DateFormatter()
        dformatter.dateFormat = format
        let date = dformatter.date(from: string)
        return date!
    }

    
    var tomorrow: Date {
        return self.addingTimeInterval(60 * 60 * 24)
    }
    
    var yesterday: Date {
        return self.addingTimeInterval(-60 * 60 * 24)
    }
    
    /// 时间表达
    var clearDescribe: String {
        
        /// 今天凌晨的时间
        let currentDate = Date.init(string: Date().format("yyyy.MM.dd 00:00"), format: "yyyy.MM.dd 00:00")!
        /// 时间差额
        let second = Int32(currentDate.timeIntervalSince(self))
        var dateDescribe = ""
        
        // 如果是今天以内
        if self > currentDate, abs(second) < 60 * 60 * 24 {
            dateDescribe = "今天 " + self.format("HH:mm")
        }
        // 一天以内 显示 (昨天、明天) HH:mm
        else if abs(second) < 60 * 60 * 24 {
            dateDescribe = (second < 0 ? "明天 " : "昨天 ") + self.format("HH:mm")
        }
        // 两天以内 显示 (前天、后天) HH:mm
        else if abs(second) < 60 * 60 * 24 * 2 {
            dateDescribe = (second < 0 ? "后天 " : "前天 ") + self.format("HH:mm")
        } else {
            let calendar = Calendar.current
            // 同一年，且早于当前时间，显示 MM.dd HH:mm
            if calendar.component(.year, from: self) == calendar.component(.year, from: currentDate), second > 0 {
                dateDescribe = self.format("MM/dd HH:mm")
            }
            // 不同年，显示完整时间 yyyy.MM.dd HH:mm
            else {
                dateDescribe = self.format("yyyy/MM/dd HH:mm")
            }
        }
        return dateDescribe
    }
    
    func timeSpaceOfCurrent() -> String {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(self)
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        if calendar.component(.year, from: self) == calendar.component(.year, from: currentDate) {
            if timeInterval > 30 * 24 * 60 * 60 {
                dateFormatter.dateFormat = "MM月dd日"
                return dateFormatter.string(from: self)
            } else if timeInterval > 24 * 60 * 60 {
                return "\(Int(timeInterval / 24 / 60 / 60))天前"
            } else {
                var hours = Int(timeInterval / 60 / 60)
                hours = Int(timeInterval) % 360 > 0 ? hours + 1 : hours
                return "\(hours)小时前"
            }
        } else {
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            return dateFormatter.string(from: self)
        }
    }
}
