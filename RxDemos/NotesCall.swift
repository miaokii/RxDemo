//
//  NotesCall.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/25.
//

import UIKit
import RxSwift
import RxCocoa

class NotesCall {

    private static let share = NotesCall()
    private let bag = DisposeBag.init()

    private func observableTest() {
        let json = observableJSON()
        json.subscribe { (json) in
            print("获取到json：\(json)")
        } onError: { (error) in
            print("获取json失败：\(error)")
        } onCompleted: {
            print("获取json完成")
        }.disposed(by: bag)
        
        // asSingle()方法将observable转换为single，注意序列只有一个元素时才能转换成功
        observabNum().asSingle().subscribe { (num) in
            print(num)
        } onFailure: { (error) in
            print(error)
        }.disposed(by: bag)
    }

    private func singleTest() {
        let jsonObj = singleObservable()
        jsonObj.subscribe { (json) in
            print("获取到json：\(json)")
        } onFailure: { (error) in
            print("获取json失败：\(error)")
        } onDisposed: {
            print("已解绑")
        }.disposed(by: bag)
    }

    private func completableTest() {
        completeObservable().subscribe {
            print("complete")
        } onError: { (error) in
            print("error: \(error)")
        }.disposed(by: bag)
    }

    private func maybeTest() {
        maybeObservable().subscribe { (success) in
            print(success)
        } onError: { (error) in
            print(error)
        } onCompleted: {
            print("maybe success")
        }.disposed(by: bag)
    }
    
    private func anyObserver() {
        Observers.share.anyObserver()
    }

    static func Call() {
        Observers.share.anyObserverString()
    }
}
