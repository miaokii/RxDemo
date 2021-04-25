//
//  RxNotes.swift
//  RxNotes
//
//  Created by miaokii on 2021/4/25.
//

import Foundation
import RxSwift
import RxCocoa

/*
 Observable：可监听序列，产生事件
 Observer：响应事件
 share(replay:)：共享源

 响应式-------------------------------------------------------------
 | 输入密码            操作函数  密码是否有效       数据绑定 提示语是否隐藏
 | Observable<String> ------> Observable<Bool> -----> Observer<Bool>
 |
 | 函数响应式编程是一种编程范式，它通过构建函数操作数据序列，对这些序列做出响应的编程方式
 | 结合了函数式和相应式
 |

 1、Observable
    可监听序列，描述元素异步产生的序列
 2、Event事件
    - next(ele): 产生一个元素
    - error(err): 产生一个错误
    - completed: 元素已经全部产生，没有更多元素了
 3、Single
    另一个Observable版本，要么只能发出一个元素，要么发出error事件
        - 不会共享附加作用
    对Observable使用asSingle()方法可以转换为single
 4、Completable
    另一个Observable版本，不能发出序列元素，要么只产生completed事件
    要么产生error事件
        - 不共享附加作用
    适用于只关心任务完成与否，不在意任务的返回值，类似Observab<Void>
 5、Maybe
    另一个Observable版本，要么发出一个元素，要么发出一个completed事件
    要么发出一个error事件，相当于Single和Completable之间
        - 不共享附加作用
    可能发出一个元素，也可能不发出时使用
    对Observable使用asMaybe()方法转换为Maybe序列
 6、Driver
    特殊的序列，主要用于简化UI代码，当所需的序列具备一下特征时使用：
        - 不会产生error事件
        - 在MainScheduler主线程监听
        - 共享附加作用
    即驱动UI事件的序列所具有的特征
    
 */

// MARK: - Error
enum RxNoteError: Error {
    case cantParseJSON
    case completeError
    case maybeError
}

// MARK: - Observable
func observabNum() -> Observable<Int> {
    return Observable<Int>.create { (observer) -> Disposable in
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        observer.onCompleted()
        return Disposables.create()
    }
}

let url = URL.init(string: "https://api.github.com/repos/RxSwift")!
typealias JSON = Any

func observableJSON() -> Observable<JSON> {
    return Observable.create { (observer) -> Disposable in
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                observer.onError(err)
                return
            }

            guard let data = data, let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                observer.onError(RxNoteError.cantParseJSON)
                return
            }
            observer.onNext(jsonObj)
            observer.onCompleted()
        }
        task.resume()
        // 绑定被销毁时取消请求
        return Disposables.create {
            task.cancel()
        }
    }
}

// MARK: - Single
func singleObservable() -> Single<[String: Any]> {
    return Single<[String: Any]>.create { (single) -> Disposable in
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                single(.failure(err))
                return
            }
            
            guard let data = data, let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
                single(.failure(RxNoteError.cantParseJSON))
                return
            }
            
            single(.success(jsonObj))
        }
        task.resume()
        return Disposables.create {
            task.cancel()
        }
    }
}

// MARK: - Completable事件
func completeObservable() -> Completable {
    return Completable.create { (completable) -> Disposable in
        let arcValue = arc4random()%2 == 1
        if arcValue {
            completable(.completed)
        } else {
            completable(.error(RxNoteError.completeError))
        }
        return Disposables.create()
    }
}

// MARK: - Maybe
func maybeObservable() -> Maybe<String> {
    return Maybe.create { (maybe) -> Disposable in
        let arcValue = arc4random()%2
        
        if arcValue == 0 {
            maybe(.success("MayBe Success"))
        } else if arcValue == 1 {
            maybe(.completed)
        } else {
            maybe(.error(RxNoteError.maybeError))
        }
        
        return Disposables.create()
    }
}

// MARK: - Driver
func dirverObservable() {
    // 查看DirverObservableController
}
