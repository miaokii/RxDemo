//
//  MKPopViewController.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/2/2.
//

import UIKit

/// 弹框控制器，可以从底部中部，左边弹出
open class MKPopViewController: UIViewController {
    
    /// 展示样式
    /// - center：中间弹出，有缩放效果
    /// - bottom：底部弹出，注意计算安全区域
    /// - left：左侧滑出
    /// - right：右侧滑出
    /// - top：顶部弹出
    /// - custom：自定义效果
    ///
    /// 当样式为自定义效果时：重写beforePop、hideing、hideing方法以实现自定义效果
    public enum PopStyle {
        case center
        case bottom
        case left
        case right
        case top
        case custom
    }
    
    /// 子视图添加在ContentView
    public var contentView: UIView!
    /// 默认弹出方式，中间弹出
    public var popStyle: PopStyle = .center
    /// 是否正在显示
    public var isShow: Bool { return _isShow }
    /// 展示动画时间
    public var presentDuration: TimeInterval = 0.5 {
        didSet {
            animatedTransition.presentDuration = presentDuration
        }
    }
    /// 消失动画时间
    public var dismissDuration: TimeInterval = 0.3 {
        didSet {
            animatedTransition.dismissDuration = dismissDuration
        }
    }
    /// 高度
    public var contentHeight: CGFloat = 200
    /// 宽度
    public var contentWidth: CGFloat = UIScreen.main.bounds.size.width * 0.8
    /// 点击背景消失
    public var hideOnTapBackground = true {
        didSet {
            tap.isEnabled = hideOnTapBackground
        }
    }
    /// 底部安全区域高度
    public var bottomSafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return mKeyWindow?.safeAreaInsets.bottom ?? 0
        } else{
            return 0
        }
    }
    
    /// 过渡
    private lazy var animatedTransition = PopAnimatedTransition.init()
    
    /// window
    private var mKeyWindow: UIWindow? {
        get {
            return UIApplication.shared.windows.first
        }
    }
    
    private let tap = UITapGestureRecognizer.init()
    private var _isShow = false
    private var presentComplete: (()->Void)?
    private var dismissComplete: (()->Void)?
    private var _backgroundColor: UIColor?

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
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
        
        /*
        let visualEffectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
        visualEffectView.alpha = 0.5
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)
        */
        
        contentView = UIView()
        contentView.backgroundColor = .view_l1
        view.addSubview(contentView)

        tap.addTarget(self, action: #selector(tapDismiss))
        tap.cancelsTouchesInView = true
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        animatedTransition.beforePresentClosure = { [unowned self] in
            self.beforePop()
        }
        
        animatedTransition.presentingClosure = { [unowned self] in
            self.inPoping()
        }
        
        animatedTransition.endPresentedClosure = { [unowned self] in
            self.endPoping()
        }
        
        animatedTransition.beforeDismissClosure = { [unowned self] in
            self.beforeHide()
        }
        
        animatedTransition.dismissingClosure = { [unowned self] in
            self.inHiding()
        }
        
        animatedTransition.dismissedClosure = { [unowned self] in
            self.endHiding()
        }
        
        animatedTransition.presentDuration = presentDuration
        animatedTransition.dismissDuration = dismissDuration
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calLayout()
    }
    
    public func calLayout() {

        var _contentHeight: CGFloat = 0, _contentWidth: CGFloat = 0
        if contentView.size == .zero {
            let layoutSize = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            _contentHeight = layoutSize.height
            _contentWidth = layoutSize.width
        } else {
            _contentHeight = contentView.height
            _contentWidth = contentView.width
        }
        
        if _contentHeight != 0 {
            contentHeight = _contentHeight
        }
            
        if _contentWidth != 0 {
            contentWidth = _contentWidth
        }
    }
    
    @objc private func tapDismiss() {
        hide()
    }
   
    // MARK: - 显示与隐藏
    /// 显示
    open func show(on vc: UIViewController? = nil, complete: (()->Void)? = nil) {
        presentComplete = complete
        if let vc = vc {
            vc.present(self, animated: true, completion: nil)
        } else if #available(iOS 13.0, *), let rootVC = mKeyWindow?.rootViewController {
            rootVC.present(self, animated: true, completion: nil)
        } else if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(self, animated: true, completion: nil)
        }
    }
    
    /// 隐藏
    open func hide(_ complete: (()->Void)? = nil) {
        dismissComplete = complete
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 状态设置
    /// 执行弹出之前的状态
    open func beforePop() {
        _backgroundColor = view.backgroundColor
        switch popStyle {
        case .center:
            contentView.alpha = 0
            contentView.center = view.center
            contentView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        case .bottom:
            contentView.transform = CGAffineTransform.init(translationX: 0, y: contentHeight)
        case .top:
            contentView.transform = CGAffineTransform.init(translationX: 0, y: -contentHeight)
        case .right:
            contentView.transform = CGAffineTransform.init(translationX: contentWidth, y: 0)
        case .left:
            contentView.transform = CGAffineTransform.init(translationX: -contentWidth, y: 0)
        case .custom:
            break
        }
        // 由clear向_backgroundColor渐变动画
        if popStyle != .custom {
            view.backgroundColor = .clear
        }
    }
    
    /// 弹出后的状态
    open func inPoping() {
        switch popStyle {
        case .center:
            contentView.alpha = 1
            contentView.transform = .identity
        default:
            contentView.transform = .identity
        }
        if popStyle != .custom {
            view.backgroundColor = _backgroundColor
        }
    }
    
    /// 弹出结束
    open func endPoping() {
        self._isShow = true
        self.presentComplete?()
    }
    
    /// 隐藏前
    open func beforeHide() {
        
    }
    
    /// 隐藏后的状态
    open func inHiding() {
        switch popStyle {
        case .center:
            contentView.alpha = 0
            contentView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        case .custom:
            break
        default:
            beforePop()
        }
        if popStyle != .custom {
            view.alpha = 0
        }
    }
    
    /// 隐藏结束
    open func endHiding() {
        if popStyle != .custom {
            view.alpha = 1
        }
        self._isShow = false
        self.dismissComplete?()
    }
}

// MARK: - 手势
extension MKPopViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: contentView)
        return !contentView.layer.contains(point)
    }
}

/// 管理控制器之间的交互式过度代理，
extension MKPopViewController: UIViewControllerTransitioningDelegate {
    /// presented动画
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransition.isPresent = true
        return animatedTransition
    }
    
    /// dismissed动画
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransition.isPresent = false
        return animatedTransition
    }
    
    /*
    /// 展示时的交互式过渡
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
    }
    
    /// 取消展示时的交互式过度
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
    }
 */
    
    /// 呈现控制器
    /*
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
    }
    */
}

/// 自定义淡入淡出动画
fileprivate class PopAnimatedTransition:NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 展示动画时间
    var presentDuration: TimeInterval = 0.2
    /// 消失动画时间
    var dismissDuration: TimeInterval = 0.2
    
    /// 是否展示
    var isPresent = true

    /// 展示前
    var beforePresentClosure: (()->Void)?
    
    /// 展示中
    var presentingClosure: (()->Void)?
    
    /// 展示结束
    var endPresentedClosure: (()->Void)?
    
    /// 取消前
    var beforeDismissClosure: (()->Void)?
    
    /// 取消展示
    var dismissingClosure: (()->Void)?
    
    /// 取消结束
    var dismissedClosure: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresent ? presentDuration : dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// 旧的控制器
        guard let formVC = transitionContext.viewController(forKey: .from),
        /// 新的控制器
              let toVC = transitionContext.viewController(forKey: .to),
              let formView = formVC.view,
              let toView = toVC.view
        else {
            return
        }
        /// 转场容器
        /// 当转场执行的时候，containerView只包含formView，不负责toView的添加
        /// 转场结束，containerView会将formView移除
        let animateContainer = transitionContext.containerView
        
        if !isPresent {
            beforeDismissClosure?()
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut) {
                self.dismissingClosure?()
            } completion: { (_) in
                self.dismissedClosure?()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            /// 添加toView到animateContainer
            animateContainer.addSubview(toView)
            animateContainer.bringSubviewToFront(formView)
            
            beforePresentClosure?()
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut) {
                self.presentingClosure?()
            } completion: { (_) in
                /// 在非交互转场中，动画结束之后需要执行transitionContext.completeTransition(!transitionContext.transitionWasCancelled)（如果动画被取消，传NO）
                /// 在interactive交互转场中，动画是否结束是由外界控制的（用户行为或者特定函数），需要在外部调用
                self.endPresentedClosure?()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

