//
//  GithubLanguageViewModel.swift
//  Pods
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

class GithubLanguageViewModel {
    // MARK: - input
    /// 选中语言
    let selectedLanguage: AnyObserver<String>
    
    // MARK: - output
    /// 语言
    let languages: Observable<[String]>
    /// 选中语言
    let didSelectedLanguage: Observable<String>

    init(githubService: GithubTrendService = .share) {
        languages = githubService.rxGetLanguageList()
        
        let _selected = PublishSubject<String>.init()
        selectedLanguage = _selected.asObserver()
        didSelectedLanguage = _selected.asObservable()
    }
}
