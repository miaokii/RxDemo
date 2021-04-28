//
//  Wrieframe.swift
//  Pods
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

enum RetryResult {
    case retry
    case cancel
}

/// 弹窗服务
protocol Wrieframe {
    func open(url: URL)
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancel: Action, actions: [Action]) -> Observable<Action>
}

class DefaultWireframe: Wrieframe {
    static let share = DefaultWireframe()
    
    func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private static func rootVC() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    static func presentAlert(_ message: String) {
        let alert = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        rootVC().present(alert, animated: true, completion: nil)
    }
    
    func promptFor<Action>(_ message: String, cancel: Action, actions: [Action]) -> Observable<Action> where Action : CustomStringConvertible {
        return Observable.create { (observer) -> Disposable in
            let alert = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: cancel.description, style: .cancel, handler: { (_) in
                observer.on(.next(cancel))
            }))
            for action in actions {
                alert.addAction(UIAlertAction.init(title: action.description, style: .cancel, handler: { (_) in
                    observer.on(.next(action))
                }))
            }
            DefaultWireframe.rootVC().present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
