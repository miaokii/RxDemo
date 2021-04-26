//
//  Protocols.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import Foundation
import RxSwift

/// 验证结果
enum ValidationResult {
    /// 成功
    case ok(message: String)
    /// 空
    case empty
    /// 正在校验
    case validating
    /// 校验失败
    case failed(message: String)
    
    /// 校验通过
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case .failed(let message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating..."
        case .ok(let message):
            return message
        }
    }
}

extension ValidationResult {
    var color: UIColor {
        switch self {
        case .ok:
            return .green
        case .empty:
            return .clear
        case .failed:
            return .red
        case .validating:
            return .black
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.text = result.description
            label.textColor = result.color
        }
    }
}

/// 网络服务
protocol GitHubAPI {
    /// 用户名是否有效
    func nameValiable(_ name: String) -> Observable<Bool>
    /// 登录
    func signup(name: String, pwd: String) -> Observable<Bool>
}

/// 验证服务
protocol GitHubValidationService {
    /// 验证用户名
    func validateName(_ name: String) -> Observable<ValidationResult>
    /// 验证密码
    func validatePwd(_ pwd: String) -> ValidationResult
    /// 验证重复密码
    func validateRepeatedPwd(pwd: String, repeatPwd: String) -> ValidationResult
}

