//
//  GithubTrendViewModel.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

class GithubTrendViewModel {
    
    // MARK: - Input
    /// 更改当前语言，刷新仓库列表
    let setCurrentLanguage: AnyObserver<String>
    /// 选择语言事件
    let chooseLanguage: AnyObserver<Void>
    /// 选中某个仓库
    let selectRepo: AnyObserver<GithubRepo>
    /// 刷新列表
    let reload: AnyObserver<Void>
    
    // MARK: - Output
    /// 数据源序列
    let repos: Observable<[GithubRepo]>
    /// 标题
    let title: Observable<String>
    /// 提示消息
    let alertMessage: Observable<String>
    /// 显示仓库详细
    let showRepo: Observable<String>
    /// 显示语言列表
    let showLanguageList: Observable<Void>
    
    init(language: String, githubService: GithubTrendService) {
        let _reload = PublishSubject<Void>.init()
        reload = _reload.asObserver()
        
        let _currentLanguage = BehaviorSubject<String>.init(value: language)
        setCurrentLanguage = _currentLanguage.asObserver()
        
        title = _currentLanguage.asObserver()
            .map{$0}
        
        let _alertMessage = PublishSubject<String>()
        alertMessage = _alertMessage.asObserver()
        
        repos = Observable.combineLatest(_reload, _currentLanguage) { _, lang in lang }
            .flatMapLatest({ lang in
                githubService.rxGetTrend(by: lang)
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        _alertMessage.onNext(error.localizedDescription)
                        return .empty()
                    }
            })
        
        let _selectRepo = PublishSubject<GithubRepo>.init()
        selectRepo = _selectRepo.asObserver()
        showRepo = _selectRepo.asObserver()
            .map{ $0.url }
        
        let _chooseLanguage = PublishSubject<Void>.init()
        chooseLanguage = _chooseLanguage.asObserver()
        showLanguageList = _chooseLanguage.asObserver()
    }
}
