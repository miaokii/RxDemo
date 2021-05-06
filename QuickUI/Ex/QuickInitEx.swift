//
//  QuickInitEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

public extension UILabel {
    convenience init(super view: UIView?,
                     text: String = "",
                     textColor: UIColor = .text_l1,
                     font: UIFont = .systemFont(ofSize: 14),
                     aligment: NSTextAlignment = .left,
                     numLines: Int = 0) {
        self.init()
        self.textColor = textColor
        self.font = font
        self.font = font
        self.textAlignment = aligment
        self.numberOfLines = numLines
        self.text = text
        
        if let sview = view {
            sview.addSubview(self)
        }
    }
}

public extension UIButton {
    convenience init(super view: UIView?,
                     title: String = "",
                     titleColor: UIColor = .text_l1,
                     normalImage: UIImage? = nil,
                     selectedImage: UIImage? = nil,
                     backgroundImage: UIImage? = nil,
                     highlightBackgroundImage: UIImage? = nil,
                     backgroundColor: UIColor? = nil,
                     font: UIFont = .systemFont(ofSize: 17),
                     borderWidth: CGFloat = 0,
                     borderColor: UIColor? = nil,
                     cornerRadius: CGFloat = 0,
                     clipsToBounds: Bool = false,
                     target_selector: (Any, Selector)? = nil) {
        self.init()
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.setImage(normalImage, for: .normal)
        self.setImage(selectedImage, for: .selected)
        self.setBackgroundImage(backgroundImage, for: .normal)
        self.setBackgroundImage(highlightBackgroundImage, for: .highlighted)
        self.backgroundColor = backgroundColor
        
        if let (target, selector) = target_selector {
            self.addTarget(target, action: selector, for: .touchUpInside)
        }
        
        if borderWidth > 0 {
            self.layer.borderWidth = borderWidth
        }
        
        if let bcolor = borderColor {
            self.layer.borderColor = bcolor.cgColor
        }
        
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        self.clipsToBounds = clipsToBounds
        
        if let sview = view {
            sview.addSubview(self)
        }
    }
    
    static func themeBtn(super view: UIView?,
                         title: String,
                         titleColor: UIColor = .white,
                         backgroundImage: UIImage = .themeImage,
                         font: UIFont = .systemFont(ofSize: 16),
                         cornerRadius: CGFloat = 5,
                         target_selector: (Any, Selector)? = nil) -> UIButton {
        let btn = UIButton.init(super: view,
                                title: title,
                                titleColor: titleColor,
                                backgroundImage: backgroundImage,
                                font: font,
                                cornerRadius: cornerRadius,
                                clipsToBounds: true,
                                target_selector: target_selector)
        return btn
    }
    
    static func themeBorderBtn(super view: UIView?,
                               title: String,
                               font: UIFont = .systemFont(ofSize: 16),
                               borderWidth: CGFloat = 1,
                               borderColor: UIColor = .theme,
                               cornerRadius: CGFloat = 5,
                               target_selector: (Any, Selector)? = nil) -> UIButton {
        let btn = UIButton.init(super: view,
                                title: title,
                                titleColor: .theme,
                                font: font,
                                borderWidth: borderWidth,
                                borderColor: borderColor,
                                cornerRadius: cornerRadius,
                                target_selector: target_selector)
        return btn
    }
}

public extension UIImageView {
    convenience init(super view: UIView?,
                     image: UIImage? = nil,
                     backgroundColor: UIColor  = .view_l1,
                     contentMode: ContentMode = .scaleAspectFit,
                     cornerRadius: CGFloat = 0) {
        self.init(image: image)
        self.backgroundColor = backgroundColor
        self.contentMode = contentMode
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
        
        if let sview = view {
            sview.addSubview(self)
        }
    }
}

public extension UIView {
    
    convenience init(super view: UIView?,
                     backgroundColor: UIColor? = .view_l1,
                     cornerRadius: CGFloat = 0) {
        self.init()
        self.backgroundColor = backgroundColor
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        
        if let sview = view {
            sview.addSubview(self)
        }
    }
    
    var controller: UIViewController? {
        get {
            var nextResponder: UIResponder?
            nextResponder = next
            repeat {
                if nextResponder is UIViewController {
                    return (nextResponder as! UIViewController)
                } else {
                    nextResponder = nextResponder?.next
                }
            } while nextResponder != nil
            return nil
        }
    }
    
    /// 设置阴影
    /// - Parameters:
    ///   - color: 阴影的颜色，默认灰色
    ///   - radius: 阴影的模糊度，默认为5。当它的值是0的时候，阴影就和视图一样有一个非常确定的边界线。
    ///   当值越来越大的时候，边界线看上去就会越来越模糊和自然
    ///   - offset: 阴影的方向和距离，CGSize值，宽度控制阴影横向位移，高度控制阴影纵向位移，默认(4，4)
    ///   即横向阴影向右，宽度为4，纵向阴影向下，高度为4
    ///   - opacity: 透明度 0-1，默认0.2
    func setShadow(color: UIColor = .gray,
                   radius: CGFloat = 5,
                   offset: CGSize = .init(width: 4, height: 4),
                   opacity: Float = 0.2) {
        
        guard frame.size != .zero else {
            return
        }
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity

        // 防止离屏渲染
        layer.shadowPath = UIBezierPath.init(roundedRect: bounds, cornerRadius: radius).cgPath
    }
}

public extension UITextField {
    
    var isEmpty: Bool {
        return (self.text ?? "").isEmpty
    }
    
    convenience init(super view: UIView?,
                     text: String = "",
                     textColor: UIColor = .text_l1,
                     placeHolder: String = "",
                     attributedText: NSAttributedString? = nil,
                     attributedPlaceholder: NSAttributedString? = nil,
                     font: UIFont = .systemFont(ofSize: 14),
                     aligment: NSTextAlignment = .left,
                     tintColor: UIColor = .blue,
                     backgroundColor: UIColor? = .view_l1,
                     delegate: UITextFieldDelegate? = nil,
                     keyboardType: UIKeyboardType = .default,
                     borderStyle: BorderStyle = .none,
                     borderWidth: CGFloat = 0,
                     borderColor: UIColor? = nil,
                     cornerRadius: CGFloat = 0,
                     clipsToBounds: Bool = false) {
        self.init()
        self.text = text
        self.textColor = textColor
        self.placeholder = placeHolder
        self.font = font
        self.textAlignment = aligment
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.delegate = delegate
        self.keyboardType = keyboardType
        self.borderStyle = borderStyle
        
        if let attrText = attributedText {
            self.attributedText = attrText
        }
        
        if let placeAttr = attributedPlaceholder {
            self.attributedPlaceholder = placeAttr
        }
        
        if borderWidth > 0 {
            self.layer.borderWidth = borderWidth
        }
        
        if let bcolor = borderColor {
            self.layer.borderColor = bcolor.cgColor
        }
        
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        self.clipsToBounds = clipsToBounds
        
        if let sview = view {
            sview.addSubview(self)
        }
    }
}
