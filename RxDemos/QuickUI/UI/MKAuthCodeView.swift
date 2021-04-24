//
//  MKAuthcodeView.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

fileprivate class CodeField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

/// 验证码视图
public class MKAuthcodeView: MKView {
    
    /// 验证码位数
    public var codeDigit: Int = 4
    /// 验证码之间间距
    public var codeSpace: CGFloat = 10
    /// 号码背景颜色
    public var codeNumBgColor: UIColor = .table_bg
    /// 号码颜色
    public var codeNumColor = UIColor.text_l1
    /// 字体
    public var codeFont = UIFont.boldSystemFont(ofSize: 20)
    /// 圆角
    public var cradius: CGFloat = 3
    
    /// 输入结束回调
    public var codeClosure: ((String)->Void)?
    
    public var code: String {
        return codeField.text ?? ""
    }
    
    private var inited = false
    private var codeField: CodeField!
    
    public override func setup() {
        codeField = CodeField.init(super: self,
                                   textColor: .clear,
                                   tintColor: .clear,
                                    backgroundColor: .clear,
                                    keyboardType: .numberPad)
        codeField.snp.makeConstraints({ $0.edges.equalTo(0) })
        codeField.addTarget(self, action: #selector(codeFieldTextChanged), for: .editingChanged)
        codeField.addTarget(self, action: #selector(codeFieldEditBegin), for: .editingDidBegin)
        clipsToBounds = true
    }
    
    @discardableResult public override func becomeFirstResponder() -> Bool {
        codeField.becomeFirstResponder()
    }
    
    @objc private func codeFieldTextChanged() {
        var codeString = codeField.text ?? ""
        
        /// 给每一个label设置值
        for i in 0..<codeDigit {
            let codeLabel = codeField.viewWithTag(i+1) as! UILabel
            if i < codeString.count {
                codeLabel.text = String.init(codeString[i])
            } else {
                codeLabel.text = ""
            }
        }
        
        /// 如果输入框超出了最大长度，就截取
        if codeString.count >= codeDigit {
            codeField.resignFirstResponder()
            codeString = codeString[0..<codeDigit]
            codeField.text = codeString
            codeClosure?(codeString)
        }
    }
    
    @objc private func codeFieldEditBegin() {
        codeField.text = ""
        guard inited else {
            return
        }
        /// 给每一个label设置值
        for i in 0..<codeDigit {
            let codeLabel = codeField.viewWithTag(i+1) as! UILabel
            codeLabel.text = ""
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for i in 0..<codeDigit {
            let codeLabel = UILabel.init(super: codeField,
                                         textColor: codeNumColor,
                                         font: codeFont,
                                         aligment: .center)
            codeLabel.backgroundColor = codeNumBgColor
            codeLabel.tag = i+1
            if cradius > 0 {
                codeLabel.layer.cornerRadius = cradius
                codeLabel.clipsToBounds = true
            }
            codeLabel.snp.makeConstraints { (make) in
                make.centerY.centerY.equalToSuperview()
                make.centerX.equalToSuperview().multipliedBy((CGFloat(i)*2+1)/CGFloat(codeDigit))
                make.top.equalTo(5)
                make.width.equalToSuperview().dividedBy(codeDigit).offset(-codeSpace)
            }
        }
        inited = true
    }
}
