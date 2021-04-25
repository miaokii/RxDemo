//
//  SimpleValidationController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleValidationController: MKViewController {

    private var nameField: UITextField!
    private var passField: UITextField!
    private var loginBtn: UIButton!
    
    private var nameValidLabel: UILabel!
    private var passValidLabel: UILabel!
    
    private var userNameMinLength = 4
    private var passWordMinLength = 4
    
    // 绑定的生命周期管理器
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setValid()
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
    
    private func setValid() {
        // 不允许为空
        let userNameValid = nameField.rx.text.orEmpty
            // 输出长度判断，有效用户名
            .map{ $0.count >= 4 }
            // 共享userNameValid源，不是为nameValidLabel单独创建的源，其他地点也要用
            .share(replay: 1)
        // 密码输入不为空
        let passwordvalid = passField.rx.text.orEmpty
            // 密码长度判断
            .map{ $0.count >= 4 }
            .share(replay: 1)
        // 所有输入是否有效
        let everythingValid = Observable.combineLatest(
            // 用户名和密码同时有效
            userNameValid, passwordvalid){ $0 && $1 }
            .share(replay: 1)
        
        // 将passField可编辑与否与usernameValid源绑定
        userNameValid.bind(to: passField.rx.isEnabled)
            // 绑定的生命周期由disposeBag管理，disposeBag被释放，未清除的绑定也释放了，同ARC
            .disposed(by: disposeBag)
        userNameValid.bind(to: nameValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        passwordvalid.bind(to: passValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        // 输入无效不能惦记按钮
        everythingValid.bind(to: loginBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.showAlert()
        }).disposed(by: disposeBag)
    }
    
    private func showAlert() {
        let alertController = UIAlertController.init(title: "Rx Vaild", message: "Do something", preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
