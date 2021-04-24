//
//  KKPopViewController.swift
//  officelive
//
//  Created by Miaokii on 2020/11/24.
//  Copyright © 2020 lplb. All rights reserved.
//

import UIKit

/// 自定义弹窗试图控制器
open class MKBasePopController: UIViewController {

    public enum PopStyle {
        case center
        case bottom
        case left
    }
    
    /// 需要设置frame，子视图添加在ContentView
    public var contentView: UIView!
    /// 默认弹出方式，中间弹出
    public var popStyle: PopStyle = .center
    /// 是否正在显示
    public var isShow: Bool = false
    
    /// 高度
    public var defaultContentViewHeight: CGFloat! = 200
    /// 宽度
    public var defaultContentViewWidth: CGFloat = UIScreen.main.bounds.size.width * 0.8
    /// 点击背景消失
    public var hideOnTapBackground = true {
        didSet {
            tap.isEnabled = hideOnTapBackground
        }
    }
    
    private var safeAreaInsets: UIEdgeInsets! = .zero
    private var firstShow = true
    private let tap = UITapGestureRecognizer.init()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        self.definesPresentationContext = true
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        print("deinit \(String.init(describing: Self.self)): \(String.init(format: "%p", self))")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        contentView = UIView()
        contentView.backgroundColor = .view_l1
        view.addSubview(contentView)

        tap.addTarget(self, action: #selector(tapDismiss))
        tap.cancelsTouchesInView = true
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popAnimation()
    }
    
    public override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            safeAreaInsets = view.safeAreaInsets
            popAnimation()
        }
    }
    
    @objc private func tapDismiss() {
        hide()
    }
    
    /// 显示
    public func show(vc: UIViewController? = nil) {
        isShow = true
        if let vc = vc {
            vc.present(self, animated: true, completion: nil)
        } else if #available(iOS 13.0, *), let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(self, animated: true, completion: nil)
        } else if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(self, animated: true, completion: nil)
        }
    }
    
    /// 隐藏
    public func hide(_ closure: (()->Void)? = nil) {
        isShow = false
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 5,
                       options: [.curveEaseOut],
                       animations: {
                        self.hideing()
        }, completion: { [unowned self] (_) in
            self.dismiss(animated: true, completion: nil)
            if let closure = closure {
                closure()
            }
        })
    }
    
    public func beforePop() {
        
        if firstShow {
            
            var h: CGFloat = 0, w: CGFloat = 0
            if contentView.size == .zero {
                let layoutSize = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                h = layoutSize.height
                w = layoutSize.width
            } else {
                h = contentView.height
                w = contentView.width
            }
            
            if h != 0 {
                defaultContentViewHeight = h
            }
                
            if w != 0 {
                defaultContentViewWidth = w
            }
            
            firstShow = false
            contentView.frame = CGRect.init(x: 0, y: view.height, width: defaultContentViewWidth, height: defaultContentViewHeight)
        }
        
        switch popStyle {
        case .center:
            contentView.alpha = 0
            contentView.center = view.center
            contentView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        case .bottom:
            contentView.frame = CGRect.init(x: 0, y: view.height, width: view.width, height: defaultContentViewHeight + safeAreaInsets.bottom)
        case .left:
            contentView.right = 0
        }
    }
    
    public func poping() {
        switch popStyle {
        case .center:
            contentView.alpha = 1
            contentView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        case .bottom:
            contentView.bottom = view.height
        case .left:
            contentView.right = view.width
        }
    }
    
    public func hideing() {
        switch popStyle {
        case .center:
            contentView.alpha = 0
            contentView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        case .bottom:
            contentView.top = view.height
        case .left:
            contentView.right = 0
        }
    }
    
    public func popAnimation() {
        beforePop()
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 5,
                       options: [.curveEaseOut],
                       animations: {
                        self.poping()
        }, completion: nil)
    }
}

extension MKBasePopController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: contentView)
        return !contentView.layer.contains(point)
    }
}
