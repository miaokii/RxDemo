//
//  HealthMailSearchViewModel.swift
//  healthpassport
//
//  Created by miaokii on 2021/5/8.
//  Copyright © 2021 fighter. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 搜索路径
fileprivate let mailSearchHistoryPath = SandboxManager.searchHistoryPath() + "/mailSearchHistory.plist"

class HealthMailSearchViewModel {
    // MARK: - input
    /// 删除所有历史搜索记录
    let removeAllSearchHistory: AnyObserver<Void>
    /// 插入一条搜索关键字
    let newSearchKey: AnyObserver<String>
    /// 实时搜索
    let editSearchKey: AnyObserver<String>
    /// 开始输入
    let beginEdit: AnyObserver<Void>
    
    // MARK: - output
    /// 热门搜索记录
    let hotSearch: Observable<[String]>
    /// 数据源
    let sections: Observable<[MailSearchSection]>
    /// 是否显示搜索结果
    let showEditSearchResult = BehaviorRelay<Bool>.init(value: false)
    /// 实时搜索结果
    let editSearchResult: Observable<[String]>
    
    private var keys = [String]()
    private var bag = DisposeBag.init()
    
    init() {
        
        if FileManager.default.fileExists(atPath: mailSearchHistoryPath) {
            keys = NSArray(contentsOfFile: mailSearchHistoryPath) as? [String] ?? []
        }
        
        let _removeAllSearchHistory = PublishSubject<Void>.init()
        removeAllSearchHistory = _removeAllSearchHistory.asObserver()
        
        let _searchKeySource = BehaviorRelay<[String]>.init(value: keys)
        
        hotSearch = Observable.just(["落花", "香蕉", "特斯拉"])
        
        sections = Observable.combineLatest(_searchKeySource, hotSearch) { (his: $0, hot: $1) }
            .map{ pair in
                [MailSearchSection.init(header: "搜索记录", items: pair.his),
                 MailSearchSection.init(header: "搜索发现", items: pair.hot)]
            }
        
        let _beginEdit = PublishSubject<Void>.init()
        beginEdit = _beginEdit.asObserver()
        
        _beginEdit
            .map{ false }
            .bind(to: showEditSearchResult)
            .disposed(by: bag)
        
        let _editSearchKey = PublishSubject<String>.init()
        editSearchKey = _editSearchKey.asObserver()
        
        editSearchResult = _editSearchKey
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest({ key in
                fetchAutoCompleteItems(key)
            })
            .asObservable()
        
        editSearchResult
            .map{ $0.isEmpty }
            .bind(to: showEditSearchResult)
            .disposed(by: bag)
        
        let _newSearchKey = PublishSubject<String>.init()
        newSearchKey = _newSearchKey.asObserver()
        
        _newSearchKey
            .map({ [weak self] key -> [String] in
                guard let this = self else { return [] }
                if let i = this.keys.firstIndex(of: key) {
                    this.keys.remove(at: i)
                }
                this.keys.insert(key, at: 0)
                (this.keys as NSArray).write(toFile: mailSearchHistoryPath, atomically: true)
                _searchKeySource.accept(this.keys)
                return this.keys
            })
            .bind(to: _searchKeySource)
            .disposed(by: bag)
        
            
    }
}

private func fetchAutoCompleteItems(_ key: String) -> Observable<[String]> {
    let count = arc4random() % 20
    let digits = Int(arc4random()%20 + 1)
    let arr = (0..<count).map({ _ in String.randomStr(len: digits) })
    return Observable.just(arr)
}

extension String{
    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func randomStr(len : Int) -> String{
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}
