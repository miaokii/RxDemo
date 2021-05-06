//
//  RxProxyRegister.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/29.
//

import UIKit

/// 注册所有的自定义的rx协议
class RxProxyRegister {
    static func register() {
        // registerKnownImplementations静态方法不能重载，所以手动注册
        // RxImagePickerDelegateProxy继承自RxNavigationControllerDelegateProxy
        RxImagePickerDelegateProxy.register { p -> RxImagePickerDelegateProxy in
            return RxImagePickerDelegateProxy.init(imagePicker: p)
        }
    }
}


