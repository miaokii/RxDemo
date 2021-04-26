//
//  DriverGithubSignController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/26.
//

import UIKit
import RxCocoa
import RxSwift

fileprivate struct DriverGithubSignViewModel {
    let nameValid: Driver<ValidationResult>
    let pwdValid: Driver<ValidationResult>
    let pweRepeatValid: Driver<ValidationResult>
    
    let signupEnable: Driver<Bool>
    let signedIn: Driver<Bool>
    let signingIn: Driver<Bool>
    
    init(input: (
        name: Driver<String>,
        pwd: Driver<String>,
        pwdRepeat: Driver<String>,
        ontap: Signal<()>
    ), dependency:(
        API: GitHubAPI,
        validationService: GitHubValidationService,
        wireframe: Wrieframe
    )) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        nameValid = input.name
            .flatMapLatest({ (name) in
                return validationService.validateName(name)
                    .asDriver(onErrorJustReturn: .failed(message: "Error contacting server"))
            })
        
        pwdValid = input.pwd
            .map({ pwd in
                return validationService.validatePwd(pwd)
            })
        
        pweRepeatValid = Driver.combineLatest(input.pwd, input.pwdRepeat, resultSelector: validationService.validateRepeatedPwd)
        
        let signingIn = ActivityIndicator.init()
        self.signingIn = signingIn.asDriver()
        
        let nameAndPwd = Driver.combineLatest(input.name, input.pwd){(name: $0, pwd: $1)}
        
        signedIn = input.ontap.withLatestFrom(nameAndPwd)
            .flatMapLatest { (pair) in
                return API.signup(name: pair.name, pwd: pair.pwd)
                    .trackActivity(signingIn)
                    .asDriver(onErrorJustReturn: false)
            }
            .flatMapLatest { (loggedIn) -> Driver<Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
                return wireframe.promptFor(message, cancel: "OK", actions: [])
                    .map{_ in loggedIn}
                    .asDriver(onErrorJustReturn: false)
            }
        
        signupEnable = Driver.combineLatest(nameValid, pwdValid, pweRepeatValid, signingIn) { name, pwd, pwdRepeat, singingIn in
            name.isValid &&
                pwd.isValid &&
                pwdRepeat.isValid &&
            !singingIn
        }
        .distinctUntilChanged()
    }
}

class DriverGithubSignController: BaseGithubSignController {

    private var vm: DriverGithubSignViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm = .init(input: (
            nameField.rx.text.orEmpty.asDriver(),
            passField.rx.text.orEmpty.asDriver(),
            verifyField.rx.text.orEmpty.asDriver(),
            signUpBtn.rx.tap.asSignal()
        ), dependency: (
            GithubDefaultAPI.share,
            GithubDefaultValidationService.share,
            DefaultWireframe.share
        ))
        
        vm.signupEnable
            .drive(onNext:{ [weak self] valid in
                self?.signUpBtn.isEnabled = valid
                self?.signUpBtn.alpha = valid ? 1 : 0.5
            })
            .disposed(by: bag)
        
        vm.nameValid
            .drive(nameValidLabel.rx.validationResult)
            .disposed(by: bag)
        
        vm.pwdValid
            .drive(passValidLabel.rx.validationResult)
            .disposed(by: bag)
        
        vm.pweRepeatValid
            .drive(verifyValidLabel.rx.validationResult)
            .disposed(by: bag)
        
        vm.signingIn
            .drive(indicator.rx.isAnimating)
            .disposed(by: bag)
        
        vm.signedIn
            .drive(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: bag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: bag)
        view.addGestureRecognizer(tapBackground)
    }

}
