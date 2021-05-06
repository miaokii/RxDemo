
import UIKit

// MARK: - 颜色配置
public extension UIColor {
    static var theme = UIColor.table_bg
    static let black_l1 = UIColor.for(light: .init(0x000000), dark: .init(0x999999))
    /// viewcontroller背景颜色，浅色模式0xffffff，暗黑模式0x000000
    static let vc_bg = UIColor.for(light: .init(0xffffff), dark: .init(0x000000))
    /// tableview背景颜色，浅色模式0xf7f7f7，暗黑模式0x000000
    static let table_bg = UIColor.for(light: .init(0xF8F8F8), dark: .init(0x000000))
    /// 分割线颜色
    static let line_gray = UIColor.for(light: .init(0xF8F3EC), dark: .init(0x000000))
    
    /// 一级view颜色，浅色模式是白色，暗黑模式是反色
    static var view_l1: UIColor = .for(light: .white)
    /// 二级view颜色，浅色模式0xf7f7f7，暗黑模式0x000000
    static let view_l2: UIColor = UIColor.for(light: .init(0xf7f7f7), dark: .init(0x1C1C1E))
    
    /// 一级文字颜色，浅色模式黑色，暗黑模式是0x999999
    static let text_l1 = UIColor.for(light: .black, dark: .init(0x999999))
    /// 二级文字颜色，0x333333
    static let text_l2 = UIColor.init(0x333333)
    /// 三级文字颜色，0x666666
    static let text_l3 = UIColor.init(0x666666)
    /// 四级文字颜色，0x999999
    static let text_l4 = UIColor.init(0x999999)
}

public extension UIColor {
    
    convenience init(_ hex: UInt32) {
        var red, green, blue, alpha: UInt32
        if hex > 0xffffff {
            blue = hex & 0x000000ff
            green = (hex & 0x0000ff00) >> 8
            red = (hex & 0x00ff0000) >> 16
            alpha = (hex & 0xff000000) >> 24
        } else {
            blue = hex & 0x0000ff
            green = (hex & 0x00ff00) >> 8
            red = (hex & 0xff0000) >> 16
            alpha = 255
        }
        self.init(red: CGFloat(red) / (255.0), green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    /// 适配暗黑模式
    /// - Parameters:
    ///   - light: 正常模式颜色
    ///   - dark: 暗黑模式颜色
    /// - Returns: 颜色
    class func `for`(light: UIColor, dark: UIColor? = nil) -> UIColor {
        if #available(iOS 13.0, *) {
            if dark == nil {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                light.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? light : UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha) })
            } else {
                return UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? light : dark! })
            }
        } else {
            return light
        }
    }
    
    /// 随机颜色
    class var random: UIColor {
        return
            UIColor.init(red: CGFloat(arc4random_uniform(255)) / (255.0),
                         green: CGFloat(arc4random_uniform(255)) / 255.0,
                         blue: CGFloat(arc4random_uniform(255)) / 255.0,
                         alpha: 1)
    }
}

