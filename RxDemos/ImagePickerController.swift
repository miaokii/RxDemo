//
//  ImagePickerController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/27.
//

import UIKit
import RxSwift
import RxCocoa

class ImagePickerController: RxBagController {

    private var imageView:UIImageView!
    private var cameraBtn:UIButton!
    private var galleryBtn: UIButton!
    private var cropBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Image Picker"
        setUI()
        setBind()
    }

    override func setUI() {
        imageView = UIImageView.init(super: view,
                                     backgroundColor: .table_bg,
                                     contentMode: .scaleAspectFill)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(10/16.0)
        }
        
        cameraBtn = UIButton.themeBtn(super: view, title: "Camera")
        cameraBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(50)
            make.height.equalTo(40)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        galleryBtn = UIButton.themeBtn(super: view, title: "Gallery")
        galleryBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(cameraBtn.snp.bottom).offset(20)
            make.height.width.equalTo(cameraBtn)
        }
        cropBtn = UIButton.themeBtn(super: view, title: "Crop")
        cropBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(galleryBtn.snp.bottom).offset(20)
            make.width.height.equalTo(galleryBtn)
        }
    }
    
    override func setBind() {
        // 不能调用相机时，拍照不可选
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        cameraBtn.rx.tap
            // 只保留最后一次点击事件
            .flatMapLatest { [weak self] _ in
                // 返回选择照片结果的序列，类型是Observable<[String: AnyObject]>
                return UIImagePickerController.rx
                    .createWithParent(self) { picker in
                        picker.sourceType = .camera
                        picker.allowsEditing = false
                    }
                    .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                    // 仅仅从序列开始发送1个元素，忽略后面的元素
                    .take(1)
            }
            // 转换为图片
            .map{ info in
                return info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
            }
            // 绑定到imageView
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
        
        galleryBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { (picker) in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { (info) in
                return info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
        
        cropBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { (picker) in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { (info) in
                return info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
    }
}

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

extension Reactive where Base: UIImagePickerController {
    /// 创建一个序列生成并弹出UIImagePickerController
    /// - Parameters:
    ///   - parent: from
    ///   - animated: true
    ///   - config: 配置
    /// - Returns: Observable<UIImagePickerController>
    static func createWithParent(_ parent: UIViewController?, animated:Bool = true, config: @escaping (UIImagePickerController) throws -> Void =  { x in }) -> Observable<UIImagePickerController> {
        // 创建序列
        return Observable.create { (observer) in
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

// 添加UIImagePickerController取消和完成的序列
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
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            // a = [imagePickerController, info]，即代理方法imagePickerController(_:didFinishPickingMediaWithInfo:)代理方法的两个参数
            .map{ a in
                return try castOrThrow([String: AnyObject].self, a[1])
            }
    }
}

/// 判断object是否为resultType类型，是就转换为该类型，否则抛出错误
func castOrThrow<T>(_ resultype: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultype)
    }
    return returnValue
}
