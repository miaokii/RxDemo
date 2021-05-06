//
//  RxUIApplicationDelegateProxy.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/6.
//

import UIKit
import RxSwift
import RxCocoa

/// 程序生命周期监听代理
class RxUIApplicationDelegateProxy: DelegateProxy<UIApplication, UIApplicationDelegate>, DelegateProxyType, UIApplicationDelegate {
    
    public weak private(set) var application: UIApplication?
    
    init(application: ParentObject) {
        self.application = application
        super.init(parentObject: application, delegateProxy: RxUIApplicationDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { p in
            return RxUIApplicationDelegateProxy.init(application: p)
        }
    }
    
    static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: UIApplicationDelegate?, to object: UIApplication) {
        object.delegate = delegate
    }
    
    override func setForwardToDelegate(_ delegate: DelegateProxy<UIApplication, UIApplicationDelegate>.Delegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(delegate, retainDelegate: true)
    }
}
