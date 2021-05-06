import Foundation

public struct MKSandBox {
    public static var homePath: String! {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
}
