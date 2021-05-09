//
//  AppDelegate.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIColor.theme = .init(0x222831)
        RxBag.Call()
        RxProxyRegister.register()
        
        return true
    }
}

