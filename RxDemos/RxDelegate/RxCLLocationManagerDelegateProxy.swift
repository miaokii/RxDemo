//
//  RxCLLocationManagerDelegateProxy.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/6.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType {
    
    public weak private(set) var manager: CLLocationManager?
    
    init(manager: ParentObject) {
        self.manager = manager
        super.init(parentObject: manager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { p in
            return RxCLLocationManagerDelegateProxy.init(manager: p)
        }
    }
    
    static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
        object.delegate = delegate
    }
    
    override func setForwardToDelegate(_ delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>.Delegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(delegate, retainDelegate: true)
    }
    
    lazy var didUpdateLocations = PublishSubject<[CLLocation]>()
    lazy var didFail = PublishSubject<Error>()
}

extension RxCLLocationManagerDelegateProxy: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager(manager, didUpdateLocations: locations)
        didUpdateLocations.onNext(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _forwardToDelegate?.locationManager(manager, didFailWithError: error)
        didFail.onNext(error)
    }
}


