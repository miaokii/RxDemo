//
//  UIButtonEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

fileprivate var click_closure: Void?
public extension UIButton {
    
    typealias ClickActionClosure = (_ sender: UIButton) -> Void
    
    /// button点击回调
    /// - Parameter closure: 回调
    func setClosure(_ closure: @escaping ClickActionClosure) {
        objc_setAssociatedObject(self, &click_closure, closure, .OBJC_ASSOCIATION_RETAIN)
        self.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
    }
    
    @objc private func clickAction(_ sender: UIButton) {
        if let clickClosure = objc_getAssociatedObject(self, &click_closure) as? ClickActionClosure {
            clickClosure(sender)
        }
    }
}

// MARK: - UIBarButtonItem
public extension UIBarButtonItem {
    
    typealias ClickActionClosure = () -> Void
    
    fileprivate struct AssociatedKeys {
        static var HandlerKey = "HandlerKey"
    }
    
    /// 便利构造UIBarButtonItem，添加回调
    /// - Parameters:
    ///   - image: 图片
    ///   - style: 风格
    ///   - closure: 回调
    convenience init(image: UIImage?, style: UIBarButtonItem.Style = .done, closure: ClickActionClosure?) {
        self.init(image: image, style: style, target: nil, action: nil)
        self.target = self
        self.action = #selector(didTapedBarButton)
        objc_setAssociatedObject(self, &click_closure, closure, .OBJC_ASSOCIATION_RETAIN)
    }
    
    /// 便利构造UIBarButtonItem，添加回调
    /// - Parameters:
    ///   - title: 文字
    ///   - style: 风格
    ///   - closure: 回调
    convenience init(title: String?, style: UIBarButtonItem.Style = .done, closure: ClickActionClosure?) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.target = self
        self.action = #selector(didTapedBarButton)
        objc_setAssociatedObject(self, &click_closure, closure, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc private func didTapedBarButton() {
        if let clickClosure = objc_getAssociatedObject(self, &click_closure) as? ClickActionClosure {
            clickClosure()
        }
    }
}
