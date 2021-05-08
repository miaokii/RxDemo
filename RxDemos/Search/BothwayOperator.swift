//
//  BothwayOperator.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/29.
//

import UIKit
import RxSwift
import RxCocoa

/*
 
 自定义运算符只能选择以下符号
    / = - + * % < >！& | ^。~
 
 操作符位置
     prefix     前置
     infix      中置
     postfix    后置
 
 // https://www.cnblogs.com/comsokey/p/Swift1.html
 
 */

// 中置   默认优先级
infix operator <=> : DefaultPrecedence

/// 不计算拼音输入中待确认的部分
func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument

    guard let rangeAll = textInput.textRange(from: start, to: end),
        let text = textInput.text(in: rangeAll) else {
            return nil
    }

    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }

    guard let startRange = textInput.textRange(from: start, to: markedTextRange.start),
        let endRange = textInput.textRange(from: markedTextRange.end, to: end) else {
        return text
    }

    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}

/// 定义双向绑定操作符 左边是TextInput序列 右边是BehaviorRelay<String>序列，相互绑定
/// 将输入源绑定到BehaviorRelay<String>序列
/// - Parameters:
///   - textInput: 文本输入，UI操作
///   - relay: 绑定到BehaviorRelay
/// - Returns: 可回收的包资源
@discardableResult
func <=> <Base>(textInput: TextInput<Base>, relay: BehaviorRelay<String>) -> Disposable {
    // relay绑定到输入源
    let bindToUIDisposable = relay.bind(to: textInput.text)
    // 输入源绑定到relay
    let bindToRelay = textInput.text
        // 观察输入
        .subscribe { [weak base = textInput.base] text in
            guard let base = base else { return }
            let noMarkedText = nonMarkedText(base)
            // 添加元素
            if let noMarkedText = noMarkedText, noMarkedText != relay.value {
                relay.accept(noMarkedText)
            }
        } onCompleted: {
            bindToUIDisposable.dispose()
        }
    return Disposables.create(bindToUIDisposable, bindToRelay)
}

@discardableResult
func <=> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    if T.self == String.self {
#if DEBUG && !os(macOS)
        fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx.text` property directly to relay.\n" +
            "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
            "REMEDY: Just use `textField <-> relay` instead of `textField.rx.text <-> relay`.\n" +
            "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
#endif
    }

    let bindToUIDisposable = relay.bind(to: property)
    let bindToRelay = property
        .subscribe(onNext: { n in
            relay.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToRelay)
}

