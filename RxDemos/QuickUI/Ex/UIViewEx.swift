//
//  UIImageEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

// MARK: - round
public extension UIView {
    /// 切圆角，确定frame后调用
    /// - Parameters:
    ///   - corners: 要切的角
    ///   - radius: 圆角值
    func round(corners: UIRectCorner = UIRectCorner.allCorners, radius: CGFloat = -1) {
        let r = radius == -1 ? min(frame.width, frame.height) / 2 : radius
        round(corners: corners, size: CGSize.init(width: r, height: r))
    }
    
    /// 切圆角，确定frame后调用
    /// - Parameters:
    ///   - corners: 要切的角
    ///   - size: 圆角值
    func round(corners: UIRectCorner = UIRectCorner.allCorners, size: CGSize) {
        layer.mask = nil
        let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: size)
        defer {
            bezierPath.close()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        layer.mask = shapeLayer
        return
    }
}

public extension UIView {
    
    var height:CGFloat {
        get {
            return frame.height
        }
        set(newValue){
            var tempFrame = self.frame
            tempFrame.size.height = newValue
            self.frame = tempFrame
        }
    }
    
    var width:CGFloat {
        get{
            return frame.width
        }
        
        set(newValue){
            var tempFrame = frame
            tempFrame.size.width = newValue
            frame = tempFrame
        }
    }
    
    var x:CGFloat {
        get{
            return frame.origin.x
        }
        set(newValue){
            var tempFrame = frame
            tempFrame.origin.x = newValue
            frame = tempFrame
        }
    }
    
    var centerX:CGFloat {
        get{
            return center.x
        }
        set(newValue){
            var tempCenter = center
            tempCenter.x = newValue
            center = tempCenter
        }
    }
    
    var centerY:CGFloat {
        get{
            return center.y
        }
        set(newValue){
            var tempCenter = center
            tempCenter.y = newValue
            center = tempCenter
        }
    }
    
    var y:CGFloat {
        get{
            return frame.origin.y
        }
        set(newValue){
            var tempFrame = frame
            tempFrame.origin.y = newValue
            frame = tempFrame
        }
    }
    
    /// left值
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var tempFrame = frame
            tempFrame.origin.x = newValue
            frame = tempFrame
        }
    }
    
    /// top值
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var tempFrame = frame
            tempFrame.origin.y = newValue
            frame = tempFrame
        }
    }
    
    /// right值
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var tempFrame = frame
            tempFrame.origin.x = newValue - frame.size.width
            frame = tempFrame
        }
    }
    
    /// bottom值
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var tempFrame = frame
            tempFrame.origin.y = newValue - frame.size.height
            frame = tempFrame
        }
    }
    
    /// size值
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            var tempFrame = frame
            tempFrame.size = newValue
            frame = tempFrame
        }
    }
    
    /// origin值
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var tempFrame = frame
            tempFrame.origin = newValue
            frame = tempFrame
        }
    }
}
