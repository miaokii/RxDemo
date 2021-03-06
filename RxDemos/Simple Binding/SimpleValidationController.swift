//
//  SimpleValidationController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleValidationController: RxBagController {

    private var nameField: UITextField!
    private var passField: UITextField!
    private var loginBtn: UIButton!
    
    private var nameValidLabel: UILabel!
    private var passValidLabel: UILabel!
    
    private var userNameMinLength = 4
    private var passWordMinLength = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUI() {
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
    
    override func setBind() {
        
        // ???????????????
        let userNameValid = nameField.rx.text.orEmpty
            // ????????????????????????????????????
            .map{ $0.count >= 4 }
            // ??????userNameValid???????????????nameValidLabel??????????????????????????????????????????
            .share(replay: 1)
        // ?????????????????????
        let passwordvalid = passField.rx.text.orEmpty
            // ??????????????????
            .map{ $0.count >= 4 }
            .share(replay: 1)
        // ????????????????????????
        let everythingValid = Observable.combineLatest(
            // ??????????????????????????????
            userNameValid, passwordvalid){ $0 && $1 }
            .share(replay: 1)
        
        // ???passField??????????????????usernameValid?????????
        userNameValid
            .bind(to: passField.rx.isEnabled)
            // ????????????????????????disposeBag?????????disposeBag????????????????????????????????????????????????ARC
            .disposed(by: bag)
        
         userNameValid.bind(to: nameValidLabel.rx.isHidden)
            .disposed(by: bag)
        // ??????
        // =====>
        // ??????binder???????????????
//        let usernameValidObserver = Binder.init(nameValidLabel) { (view, isHidden) in
//            view.isHidden = isHidden
//        }
//        userNameValid
//            .bind(to: usernameValidObserver)
//            .disposed(by: bag)
        
        
        passwordvalid
            .bind(to: passValidLabel.rx.isHidden)
            .disposed(by: bag)
        // ??????????????????????????????
        everythingValid
            .bind(to: loginBtn.rx.isEnabled)
            .disposed(by: bag)
        
        loginBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.showAlert()
        }).disposed(by: bag)
    }
    
    private func showAlert() {
        let alertController = UIAlertController.init(title: "Rx Vaild", message: "Do something", preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
