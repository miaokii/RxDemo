//
//  StringEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//
import Foundation

// 格式化金额
public extension String {
    
    /// 格式化货币金额
    /// - Parameters:
    ///   - value: 金额值
    /// - Returns: 格式化后的值
    static func priceBy(value: Double) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.numberStyle = .currency
        amountFormatter.locale = .current
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
        
    /// 格式化货币，不显示货币符号
    /// - Parameter value: 金额值
    /// - Returns: 格式化后的值
    static func price_without_symbol(value: Double) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.maximumFractionDigits = 2
        amountFormatter.numberStyle = .decimal
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
    
    /// 转换double为string
    /// - Parameters:
    ///   - value: double值
    ///   - numberStyle: 转换格式，默认decimal
    /// - Returns: 转换后值
    static func decimal(value: Double, style: NumberFormatter.Style = .decimal) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.numberStyle = style
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
    
    static func decimal(value: Float, style: NumberFormatter.Style = .decimal) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.numberStyle = style
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
    
    subscript(offset: Int) -> Character {
        get {
            return self[index(startIndex, offsetBy: offset)]
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: offset)..<index(startIndex, offsetBy: offset + 1), with: [newValue])
        }
    }
    
    subscript(range: CountableRange<Int>) -> String {
        get {
            return String(self[index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound), with: newValue)
        }
    }
    
    subscript(location: Int, length: Int) -> String {
        get {
            return String(self[index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length), with: newValue)
        }
    }
}
