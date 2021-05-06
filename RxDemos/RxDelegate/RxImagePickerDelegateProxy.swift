//
//  RxImagePickerDelegateProxy.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/6.
//

import UIKit
import RxSwift
import RxCocoa

/// 图片选择的代理
class RxImagePickerDelegateProxy: RxNavigationControllerDelegateProxy,
                                  UIImagePickerControllerDelegate {
    init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }
}
