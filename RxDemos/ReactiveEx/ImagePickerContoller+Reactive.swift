//
//  ImagePickerContoller+Reactive.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/29.
//

import UIKit
import RxSwift
import RxCocoa

/// UIImagePickerController的rx创建
extension Reactive where Base: UIImagePickerController {
    /// 创建一个序列生成并弹出UIImagePickerController
    /// - Parameters:
    ///   - parent: from
    ///   - animated: true
    ///   - config: 配置
    /// - Returns: Observable<UIImagePickerController>
    static func createWithParent(_ parent: UIViewController?, animated:Bool = true, config: @escaping (UIImagePickerController) throws -> Void =  { x in }) -> Observable<UIImagePickerController> {
        // 创建序列
        return Observable.create { [weak parent] (observer) in
            let imagePicker = UIImagePickerController.init()
            // imagePicker退出时回收的资源
            let dismissDisposeable = imagePicker.rx
                .didCancel
                .subscribe(onNext: { [weak imagePicker] _ in
                    guard let imagePicker = imagePicker else { return }
                    dismissViewController(imagePicker, animated: animated)
                })
            do {
                // 配置Picker
                try config(imagePicker)
            }
            // 捕捉到错误事件
            catch let error {
                // 发送错误事件
                observer.onError(error)
                // 清除资源包用于解除绑定
                return Disposables.create()
            }
            
            // 如果没有传入present picker的控制器，发送完成事件
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            // 弹出picker
            parent.present(imagePicker, animated: animated, completion: nil)
            // 向序列中添加一个picker元素
            observer.on(.next(imagePicker))
            // 清除资源包
            return Disposables.create(dismissDisposeable, Disposables.create {
                dismissViewController(imagePicker, animated: animated)
            })
        }
    }
}

/// UIImagePickerController的rx扩展，将UIImagePickerControllerDelegate代理转换为可观察序列
/// 添加UIImagePickerController取消和完成的序列
extension Reactive where Base: UIImagePickerController {
    /// UIImagePickerController取消的序列
    var didCancel: Observable<()> {
        // 将imagePickerControllerDidCancel方法转换为一个事件序列
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map{ _ in }
    }
    /// 选择了一张照片
    var didFinishPickingMediaWithInfo: Observable<[String: AnyObject]> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            // a = [imagePickerController, info]，即代理方法imagePickerController(_:didFinishPickingMediaWithInfo:)代理方法的两个参数
            .map{ a in
                return try castOrThrow(Dictionary<String, AnyObject>.self, a[1])
            }
    }
}

/// 判断object是否为resultType类型，是就转换为该类型，否则抛出错误
/// - Parameters:
///   - resultype: 类型
///   - object: 对象
/// - Throws: 异常
/// - Returns: 转换后的类型
func castOrThrow<T>(_ resultype: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultype)
    }
    return returnValue
}


/// 判断object是否为resultType?类型，是就转换为该类型，否则抛出错误
/// - Parameters:
///   - resultype: 类型
///   - object: 对象
/// - Throws: 异常
/// - Returns: 转换后的类型
func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    return try castOrThrow(resultType.self, object)
}
