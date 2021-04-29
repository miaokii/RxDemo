//
//  RxProxyRegister.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/29.
//

import UIKit

class RxProxyRegister {
    
    static func register() {
        RxImagePickerDelegateProxy.register { p -> RxImagePickerDelegateProxy in
            return RxImagePickerDelegateProxy.init(imagePicker: p)
        }
    }
    
    
}
