//
//  AddingNumberController.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/6.
//

import UIKit
import RxSwift
import RxCocoa

class AddingNumberController: RxBagController {
    
    private var num1Field: UITextField!
    private var num2Field: UITextField!
    private var num3Field: UITextField!
    private var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Adding Numbers"
    }
    
    override func setUI() {
        
        num1Field = UITextField.init(super: view,
                                     text: "0",
                                     aligment: .right,
                                     keyboardType: .numberPad,
                                     borderStyle: .roundedRect)
        num1Field.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        num2Field = UITextField.init(super: view,
                                     text: "0",
                                     aligment: .right,
                                     keyboardType: .numberPad,
                                     borderStyle: .roundedRect)
        num2Field.snp.makeConstraints { make in
            make.size.centerX.equalTo(num1Field)
            make.top.equalTo(num1Field.snp.bottom).offset(10)
        }
        
        num3Field = UITextField.init(super: view,
                                     text: "0",
                                     aligment: .right,
                                     keyboardType: .numberPad,
                                     borderStyle: .roundedRect)
        num3Field.snp.makeConstraints { make in
            make.size.centerX.equalTo(num1Field)
            make.top.equalTo(num2Field.snp.bottom).offset(10)
        }
        
        num1Field.clearsOnBeginEditing = true
        num2Field.clearsOnBeginEditing = true
        num3Field.clearsOnBeginEditing = true
        
        let addSymbol = UILabel.init(super: view,
                                     text: "+",
                                     font: .systemFont(ofSize: 17))
        addSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(num3Field)
            make.right.equalTo(num3Field.snp.left).offset(-10)
        }
        
        let divide = UIView.init(super: view,
                                 backgroundColor: .lightGray)
        divide.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(num3Field.snp.bottom).offset(10)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(0.5)
        }
        
        resultLabel = UILabel.init(super: view,
                                   text: "0",
                                   font: .boldSystemFont(ofSize: 20),
                                   aligment: .right)
        resultLabel.snp.makeConstraints { make in
            make.right.centerX.equalTo(num1Field)
            make.top.equalTo(divide.snp.bottom).offset(10)
        }
    }
    
    override func setBind() {
        let num1Value = num1Field.rx.text.orEmpty
            .map{ Float($0) ?? 0 }
        let num2Value = num2Field.rx.text.orEmpty
            .map{ Float($0) ?? 0 }
        let num3Value = num3Field.rx.text.orEmpty
            .map{ Float($0) ?? 0}
        
        Observable.combineLatest(num1Value, num2Value, num3Value) {$0 + $1 + $2}
            .map{ String.decimal(value: $0, style: .decimal) }
            .bind(to: resultLabel.rx.text)
            .disposed(by: bag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.resignFirstResponder()
    }
}
