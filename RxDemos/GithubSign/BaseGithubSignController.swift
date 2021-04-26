//
//  BaseGithubSignController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

class BaseGithubSignController: MKViewController {

    var nameField: UITextField!
    var passField: UITextField!
    var verifyField: UITextField!
    
    var nameValidLabel: UILabel!
    var passValidLabel: UILabel!
    var verifyValidLabel: UILabel!
    
    var signUpBtn: UIButton!
    var indicator: UIActivityIndicatorView!
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    func setUI() {
    
        nameField = UITextField.init(super: view,
                                     placeHolder: "Enter your name",
                                     borderStyle: .roundedRect)
        nameField.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(20)
            make.height.equalTo(35)
        }
        
        nameValidLabel = UILabel.init(super: view,
                                      font: .systemFont(ofSize: 13))
        nameValidLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameField)
            make.top.equalTo(nameField.snp.bottom).offset(5)
        }
        
        passField = UITextField.init(super: view,
                                     placeHolder: "Enter your password",
                                     borderStyle: .roundedRect)
        passField.snp.makeConstraints { (make) in
            make.left.height.right.equalTo(nameField)
            make.top.equalTo(nameValidLabel.snp.bottom).offset(10)
        }
        passValidLabel = UILabel.init(super: view,
                                      font: .systemFont(ofSize: 13))
        passValidLabel.snp.makeConstraints { (make) in
            make.left.equalTo(passField)
            make.top.equalTo(passField.snp.bottom).offset(5)
        }
        
        verifyField = UITextField.init(super: view,
                                       placeHolder: "Confirm your password",
                                       borderStyle: .roundedRect)
        verifyField.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(passField)
            make.top.equalTo(passValidLabel.snp.bottom).offset(10)
        }
        verifyValidLabel = UILabel.init(super: view,
                                        font: .systemFont(ofSize: 13))
        verifyValidLabel.snp.makeConstraints { (make) in
            make.left.equalTo(verifyField)
            make.top.equalTo(verifyField.snp.bottom).offset(5)
        }
        
        
        signUpBtn = UIButton.themeBtn(super: view, title: "Sign up", cornerRadius: 3)
        signUpBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(passField)
            make.height.equalTo(40)
            make.top.equalTo(verifyValidLabel.snp.bottom).offset(60)
        }
        
        indicator = UIActivityIndicatorView.init()
        indicator.isHidden = true
        signUpBtn.addSubview(indicator)
        indicator.color = .view_l1
        indicator.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }
        
        /*
        let infoLabel = UILabel.init(super: view,
                                     textColor: .text_l3,
                                     font: .systemFont(ofSize: 11),
                                     aligment: .center)
        infoLabel.text = """
Proving that observable sequences have wanted properties (UIThread, errors handled, sharing of side effects) is done manually. (but has some performance gain that shouldn't be noticeable in practice)

To do this automatically, check out the corresponding `Driver` example.
"""
        infoLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(signUpBtn.snp.bottom).offset(30)
            make.left.equalTo(40)
        }
 */
    }
}
