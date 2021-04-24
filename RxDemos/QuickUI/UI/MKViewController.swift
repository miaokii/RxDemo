//
//  MKViewController.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

open class MKViewController: UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .view_l1
    }

    open func popOrDismiss() {
        if let _ = self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
        } else if let nav = self.navigationController {
            if nav.viewControllers.first != self {
                nav.popViewController(animated: true)
            } else if let tabNav = tabBarController?.navigationController {
                tabNav.popViewController(animated: true)
            } else {
                nav.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    deinit {
        print("deinit \(String.init(describing: Self.self)): \(String.init(format: "%p", self))")
    }
}
