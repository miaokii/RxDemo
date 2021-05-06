import UIKit
import AudioToolbox

public struct MKDefine {
    /// 屏幕宽度
    public static let screenWidth = UIScreen.main.bounds.width
    /// 屏幕高度
    public static let screenHeight = UIScreen.main.bounds.height
    /// 导航栏高度
    public static let navBarHeight: CGFloat = 44
    /// 导航栏+状态栏高度
    public static let navAllHeight = Self.statusBarHeight + Self.navBarHeight
    /// tabbar高度
    public static let tabBarHeight: CGFloat = 49 + Self.bottomSafeAreaHeight

    /// 状态栏高度
    public static var statusBarHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return mKeyWindow?.safeAreaInsets.top ?? 20
        } else{
            return 20
        }
    }
    /// 底部安全区域高度
    public static var bottomSafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return mKeyWindow?.safeAreaInsets.bottom ?? 0
        } else{
            return 0
        }
    }

    /// keywindow
    public static var mKeyWindow: UIWindow? {
        get{
            return UIApplication.shared.windows.first
        }
    }

    public static func playShortVibration() {
        AudioServicesPlaySystemSound(1519);
    }

    public static func endEdit() {
        mKeyWindow?.endEditing(true)
    }
}

