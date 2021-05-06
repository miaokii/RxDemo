//
//  UIApplication+Reactive.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/6.
//

import UIKit
import RxSwift
import RxCocoa

enum ApplicationState {
    case active
    case inactive
    case background
    case terminated
}

extension UIApplication.State {
    var state: ApplicationState {
        switch self {
        case .inactive:
            return .inactive
        case .background:
            return .background
        case .active:
            return .active
        @unknown default:
            fatalError()
        }
    }
}

extension Reactive where Base: UIApplication {
    
    /// 委托代理
    var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
        return RxUIApplicationDelegateProxy.proxy(for: base)
    }
    
    /// 回到活跃状态
    var didBecomeActive: Observable<ApplicationState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:)))
            .map{ _ in .active }
    }
    
    /// 进入非活动状态
    var willResignActive: Observable<ApplicationState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillResignActive(_:)))
            .map{ _ in .inactive}
    }
    
    /// 即将进入前台（非活跃状态）
    var willEnterForeground: Observable<ApplicationState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:)))
            .map{ _ in .inactive}
    }
    
    /// 进入后台
    var didEnterBackground: Observable<ApplicationState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
            .map{ _ in .background}
    }
    
    /// 被杀掉
    var willTerminate: Observable<ApplicationState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillTerminate(_:)))
            .map{ _ in .terminated }
    }

    /// 状态组
    var states: Observable<ApplicationState> {
        return Observable.of(
            didBecomeActive,
            willResignActive,
            willTerminate,
            willEnterForeground,
            didEnterBackground
            )
        .merge()
        .startWith(base.applicationState.state)
    }
}
