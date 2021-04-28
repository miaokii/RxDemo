//
//  AppDelegate.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIColor.theme = .init(0x222831)
        RxBag.Call()
        return true
    }
}

