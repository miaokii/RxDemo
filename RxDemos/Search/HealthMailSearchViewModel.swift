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
//    let removeAllSearchHistory: AnyObserver<Void>
    /// 插入一条搜索关键字
    let newSearchKey: AnyObserver<String>
    /// 实时搜索
    let editSearchKey: AnyObserver<String>
    
    // MARK: - output
    /// 数据源
    let sections: Observable<[MailSearchSection]>
    /// 实时搜索结果
    let editSearchResult: Observable<[String]>
    
    /// 搜索发现数据源
    private var searchKeySource: BehaviorSubject<[String]>
    /// 搜索发现数据源
    private var hotSearch: BehaviorSubject<[String]>
    
    private var keys = [String]()
    private var bag = DisposeBag.init()
    
    init() {
        
        if FileManager.default.fileExists(atPath: mailSearchHistoryPath) {
            keys = NSArray(contentsOfFile: mailSearchHistoryPath) as? [String] ?? []
        }
        
        searchKeySource = BehaviorSubject<[String]>.init(value: keys)
        hotSearch = BehaviorSubject<[String]>.init(value: [])
        
        sections = Observable.combineLatest(searchKeySource, hotSearch) { (his: $0, hot: $1) }
            .map{ pair in
                [MailSearchSection.init(header: "搜索记录", items: pair.his),
                 MailSearchSection.init(header: "搜索发现", items: pair.hot)]
            }
        
        let _editSearchKey = PublishSubject<String>.init()
        editSearchKey = _editSearchKey.asObserver()
        
        editSearchResult = _editSearchKey
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest({ key -> Observable<[String]> in
                key.isEmpty ? .just([]) : fetchAutoCompleteItems(key)
            })
            .asObservable()
            .share(replay: 1)
        
        let _newSearchKey = PublishSubject<String>.init()
        newSearchKey = _newSearchKey.asObserver()
    
        _newSearchKey
            .filter{$0.count > 0}
            .map({ [weak self] key -> [String] in
                guard let this = self else { return [] }
                if let i = this.keys.firstIndex(of: key) {
                    this.keys.remove(at: i)
                }
                this.keys.insert(key, at: 0)
                (this.keys as NSArray).write(toFile: mailSearchHistoryPath, atomically: true)
                return this.keys
            })
            .bind(to: searchKeySource)
            .disposed(by: bag)
        
        DispatchQueue.main.async {
            self.hotSearch.onNext(["康养包", "电影消费券", "钢铁侠", "日照香炉生紫烟", "♨️"])
        }
    }
    
    func removeAllSearchHistory() {
        keys.removeAll()
        (keys as NSArray).write(toFile: mailSearchHistoryPath, atomically: true)
        searchKeySource.onNext([])
    }
}

private func fetchAutoCompleteItems(_ key: String) -> Observable<[String]> {
    let count = arc4random() % 20 + 1
    let arr = (0..<count).map({ _ in key+String.randomStr(len: Int(arc4random()%20 + 1)) })
    return Observable.just(arr)
}
