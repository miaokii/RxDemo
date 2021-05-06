//
//  CLLocationManager+Reactive.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/6.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

extension Reactive where Base: CLLocationManager {
    var delegate: RxCLLocationManagerDelegateProxy {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    /// 位置权限信息
    var authorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:)))
            .map { param in
                return (param.first as! CLLocationManager).authorizationStatus
            }
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base).didUpdateLocations.asObserver()
    }
    
    var didFail: Observable<Error> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base).didFail.asObserver()
    }
}

