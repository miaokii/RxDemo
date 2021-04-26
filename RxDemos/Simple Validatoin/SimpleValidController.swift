//
//  SimpleValidController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

class SimpleValidController: MKViewController {
    private let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        let simpleBtn = UIButton.themeBorderBtn(super: view, title: "Simple Validation")
        simpleBtn.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(45)
        }
        simpleBtn.rx.tap
            .subscribe(onNext: {
                let vc = SimpleValidationController.init()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
        
        let mvvmSimpleBtn = UIButton.themeBtn(super: view, title: "MVVM Simple Validation")
        mvvmSimpleBtn.snp.makeConstraints { (make) in
            make.top.equalTo(simpleBtn.snp.bottom).offset(30)
            make.left.right.height.equalTo(simpleBtn)
        }
        mvvmSimpleBtn.rx.tap
            .subscribe(onNext: {
                let vc = MVVMSimpleValidController.init()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
    }
    
}
