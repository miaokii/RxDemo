//
//  GithubDefaultValidationService.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import Foundation
import RxSwift

class GithubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI
    
    static let share = GithubDefaultValidationService.init(API: GithubDefaultAPI.share)
    
    init(API: GitHubAPI) {
        self.API = API
    }
    
    let minPwdCount = 5
    
    func validateName(_ name: String) -> Observable<ValidationResult> {
        
        if name.isEmpty {
            return .just(.empty)
        }
        
        if name.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = ValidationResult.validating
        
        return API.nameValiable(name)
            .map { (available) in
                if available {
                    return .ok(message: "Username availabe")
                } else {
                    return .failed(message: "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePwd(_ pwd: String) -> ValidationResult {
        let numberCount = pwd.count
        if numberCount == 0 {
            return .empty
        }
        
        if numberCount < minPwdCount {
            return .failed(message: "Password mast be at least \(minPwdCount) characters")
        }
        
        return .ok(message: "Password acceptable")
    }
    
    func validateRepeatedPwd(pwd: String, repeatPwd: String) -> ValidationResult {
        if repeatPwd.isEmpty {
            return .empty
        }
        
        if repeatPwd == pwd {
            return .ok(message: "Password repeated")
        } else {
            return .failed(message: "Password different")
        }
    }
}
