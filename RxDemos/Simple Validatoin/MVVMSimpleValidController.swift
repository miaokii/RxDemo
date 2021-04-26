//
//  MVVMSimpleValidController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate let userNameMinLength = 4
fileprivate let passWordMinLength = 4

// 将输入行为转换为输出状态
fileprivate struct SimpleValidViewModel {
    
    /// 用户名是否有效
    let nameValid: Observable<Bool>
    /// 密码是否有效
    let passValid: Observable<Bool>
    /// 所有输入是否有效
    let entryValid: Observable<Bool>
    
    
    init(name: Observable<String>, pass: Observable<String>) {
        nameValid = name
            .map{ $0.count > userNameMinLength }
            .share(replay: 1)
        
        passValid = pass
            .map{ $0.count > passWordMinLength }
            .share(replay: 1)
        
        entryValid = Observable.combineLatest(nameValid, passValid) { $0 && $1 }
            .share(replay: 1)
    }
}

class MVVMSimpleValidController: MKViewController {

    private var nameField: UITextField!
    private var passField: UITextField!
    private var loginBtn: UIButton!
    
    private var nameValidLabel: UILabel!
    private var passValidLabel: UILabel!
    
    private var viewModel: SimpleValidViewModel!
    
    // 绑定的生命周期管理器
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindValid()
    }
    
    private func setUI() {
        let nameLabel = UILabel.init(super: view,
                                     text: "Username")
        nameLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(20)
        }
        
        nameField = UITextField.init(super: view,
                                     placeHolder: "Enter your name",
                                     borderStyle: .roundedRect)
        nameField.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.equalTo(-20)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(35)
        }
        
        nameValidLabel = UILabel.init(super: view,
                                      text: "Username has to be at least \(userNameMinLength) characters",
                                      textColor: .init(0xfb3640))
        nameValidLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameField)
            make.top.equalTo(nameField.snp.bottom).offset(5)
        }
        
        let passLabel = UILabel.init(super: view,
                                     text: "Password")
        passLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameValidLabel.snp.bottom).offset(20)
        }
        
        passField = UITextField.init(super: view,
                                     placeHolder: "Enter your password",
                                     borderStyle: .roundedRect)
        passField.snp.makeConstraints { (make) in
            make.left.height.right.equalTo(nameField)
            make.top.equalTo(passLabel.snp.bottom).offset(8)
        }
        passValidLabel = UILabel.init(super: view,
                                      text: "Password has to be at least \(passWordMinLength) characters",
                                      textColor: .init(0xfb3640))
        passValidLabel.snp.makeConstraints { (make) in
            make.left.equalTo(passField)
            make.top.equalTo(passField.snp.bottom).offset(5)
        }
        
        
        loginBtn = UIButton.themeBtn(super: view, title: "Do Something", cornerRadius: 3)
        loginBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(passField)
            make.height.equalTo(40)
            make.top.equalTo(passValidLabel.snp.bottom).offset(60)
        }
    }
    
    private func bindValid() {
        let nameObservable = nameField.rx.text.orEmpty.asObservable()
        let passObservable = passField.rx.text.orEmpty.asObservable()
        viewModel = SimpleValidViewModel.init(name: nameObservable,
                                              pass: passObservable)
        viewModel.nameValid
            .bind(to: nameValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.nameValid
            .bind(to: passField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.passValid
            .bind(to: passValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.entryValid
            .bind(to: loginBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginBtn.rx.tap
            .subscribe(onNext: {
                self.showAlert()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func showAlert() {
        let alertController = UIAlertController.init(title: "Rx Vaild", message: "Do something", preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
