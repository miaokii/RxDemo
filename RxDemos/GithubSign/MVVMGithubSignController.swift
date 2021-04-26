//
//  MVVMGithubSignController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate struct GithubSignViewModel {
    /// 用户名验证结果
    let nameValid: Observable<ValidationResult>
    /// 密码验证结果
    let pwdValid: Observable<ValidationResult>
    /// 确认密码验证结果
    let pwdValidRepeat: Observable<ValidationResult>
    /// 可否登录
    let signupEnabled: Observable<Bool>
    /// 登录成功
    let signedIn: Observable<Bool>
    /// 正在登录
    let signingIn: Observable<Bool>
    
    /// 转换输入为状态
    /// - Parameters:
    ///   - input: 输入内容
    ///   - dependency: 依赖
    init(input: (
        name: Observable<String>,
        pwd: Observable<String>,
        pwdRepeat: Observable<String>,
        loginTaps: Observable<Void>
    ), dependency: (
        api: GitHubAPI,
        validationService: GitHubValidationService,
        wrieframe: Wrieframe
    )) {
        let api = dependency.api
        let validationService = dependency.validationService
        let wrieframe = dependency.wrieframe
    
        nameValid = input.name
            // 将一个observable转换为另一个observable
            .flatMapLatest({ (name) in
                // 验证用户名
                return validationService.validateName(name)
                    // 在主线程设置观察
                    .observe(on: MainScheduler.instance)
                    // 如果发生错误，重新生成一个元素返回
                    // 生成的元素为failed
                    .catchAndReturn(.failed(message: "Error contacting server"))
            }).share(replay: 1)
        
        pwdValid = input.pwd
            .map{ validationService.validatePwd($0) }
            .share(replay: 1)
        
        pwdValidRepeat = Observable.combineLatest(input.pwd, input.pwdRepeat, resultSelector: validationService.validateRepeatedPwd)
            .share(replay: 1)
        
        let signingIn = ActivityIndicator.init()
        self.signingIn = signingIn.asObservable()

        // combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经发出过元素）。
        let nameAndPwd = Observable.combineLatest(input.name, input.pwd) { (name: $0, pwd: $1) }
        
        // withLatestFrom操作符号将两个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去。
        signedIn = input.loginTaps.withLatestFrom(nameAndPwd)
            // flatMapLatest 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
            .flatMapLatest { (pair) in
                return api.signup(name: pair.name, pwd: pair.pwd)
                    .observe(on: MainScheduler.instance)
                    // 转换错误结果
                    .catchAndReturn(false)
                    .trackActivity(signingIn)
            }
            .flatMapLatest { (loggedIn) -> Observable<Bool> in
                let message = loggedIn ? "Signed in to Github." : "Sign in to Github failed"
                return wrieframe.promptFor(message, cancel: "OK", actions: [])
                    .map({ _ in loggedIn })
            }
            .share(replay: 1)
            
        signupEnabled = Observable.combineLatest(nameValid, pwdValid, pwdValidRepeat, signingIn.asObservable()) { name, pwd, pwdRepeat, signingIn in
            name.isValid &&
                pwd.isValid &&
                pwdRepeat.isValid &&
            !signingIn
        }
        // distinctUntilChanged 操作符将阻止 Observable 发出相同的元素。如果后一个元素和前一个元素是相同的，那么这个元素将不会被发出来。如果后一个元素和前一个元素不相同，那么这个元素才会被发出来。
        .distinctUntilChanged()
        .share(replay: 1)
    }
}

class MVVMGithubSignController: BaseGithubSignController {
    
    private var vm: GithubSignViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        vm = GithubSignViewModel
            .init(input: (
                nameField.rx.text.orEmpty.asObservable(),
                passField.rx.text.orEmpty.asObservable(),
                verifyField.rx.text.orEmpty.asObservable(),
                signUpBtn.rx.tap.asObservable()
            ), dependency: (
                GithubDefaultAPI.share,
                GithubDefaultValidationService.share,
                DefaultWireframe.share
            ))
        
        // 可否登录状态绑定到登录按钮
        vm.signupEnabled
            .subscribe(onNext: { [weak self] (vaild) in
                self?.signUpBtn.isEnabled = vaild
                self?.signUpBtn.alpha = vaild ? 1 : 0.5
            })
            .disposed(by: bag)
        
        vm.nameValid
            .bind(to: nameValidLabel.rx.validationResult)
            .disposed(by: bag)
        
        vm.pwdValid
            .bind(to: passValidLabel.rx.validationResult)
            .disposed(by: bag)
        
        vm.pwdValidRepeat
            .bind(to: verifyValidLabel.rx.validationResult)
            .disposed(by: bag)
        
        vm.signingIn
            .bind(to: indicator.rx.isAnimating)
            .disposed(by: bag)
        
        vm.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: bag)
        
        let tapbackgroud = UITapGestureRecognizer.init()
        tapbackgroud.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: bag)
        view.addGestureRecognizer(tapbackgroud)
    }
}
