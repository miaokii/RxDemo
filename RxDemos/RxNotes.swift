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
 Observer：监听并响应事件
 share(replay:)：共享源

 响应式-------------------------------------------------------------
 | 输入密码            操作函数  密码是否有效       数据绑定 提示语是否隐藏
 | Observable<String> ------> Observable<Bool> -----> Observer<Bool>
 |
 | 函数响应式编程是一种编程范式，它通过构建函数操作数据序列，对这些序列做出响应的编程方式
 | 结合了函数式和相应式
 |

 可监听序列--------------------------------------------------------
 | 1、Observable
 |    可监听序列，描述元素异步产生的序列
 | 2、Event事件
 |    - next(ele): 产生一个元素
 |    - error(err): 产生一个错误
 |    - completed: 元素已经全部产生，没有更多元素了
 | 3、Single
 |    另一个Observable版本，要么只能发出一个元素，要么发出error事件
 |        - 不会共享附加作用
 |    对Observable使用asSingle()方法可以转换为single
 | 4、Completable
 |    另一个Observable版本，不能发出序列元素，要么只产生completed事件
 |    要么产生error事件
 |        - 不共享附加作用
 |    适用于只关心任务完成与否，不在意任务的返回值，类似Observab<Void>
 | 5、Maybe
 |    另一个Observable版本，要么发出一个元素，要么发出一个completed事件
 |    要么发出一个error事件，相当于Single和Completable之间
 |        - 不共享附加作用
 |    可能发出一个元素，也可能不发出时使用
 |    对Observable使用asMaybe()方法转换为Maybe序列
 | 6、Driver
 |    特殊的序列，主要用于简化UI代码，当所需的序列具备一下特征时使用：
 |        - 不会产生error事件
 |        - 在MainScheduler主线程监听
 |        - 共享附加作用
 |    即驱动UI事件的序列所具有的特征
 | 7、Signal
 |    和Dirver相似，不同在于Dirver会对观察者重新发送上一个元素，而
 |    Signal不会对观察者回放上一个元素
 |         - 不会产生error事件
 |         - 在MainScheduler主线程监听
 |         - 共享附加作用
 |
 |    - 一般情况下状态序列会用Diver类型，事件序列选用Signal类型
 |

 观察者--------------------------------------------------------
 | 观察者响应事件
 | 1、AnyObserver
 |     用来描述任意一种观察者
 | 2、Binder
 |     具有以下两个特征的观察者
 |         - 不会处理错误事件
 |         - 确保绑定都是在Scheduler上执行（默认MainScheduler）
 |     一般情况下，UI观察者不会出现错误事件，只会处理next事件，而且UI的更新都是在主线程上执行
 |     所以放在Binder上更合理
 
 Observable & Observer----------------------------------------
 |  Observable & Observer既可以时可监听序列可以是观察者
 |  有的元素既可以是可监听序列，也可能是观察者，比如UITextField的text属性、UISwitch开关状态
 |  segmentedControl的选中索引号，datePicker的选中日期等
 |
 
 */

// MARK: - Error
enum RxNoteError: Error {
    case cantParseJSON
    case completeError
    case maybeError
    
    case anyObserverError
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

class Observers  {
    static let share = Observers()
    var bag = DisposeBag()
    // MARK: - AnyObserver
    func anyObserver()  {
        URLSession.shared.rx.data(request: URLRequest(url: url))
            .subscribe { (data) in
                print(String.init(data: data, encoding: .utf8) ?? "\(data)")
            } onError: { (error) in
                print("data task error: \(error)")
            } onCompleted: {
                print("data task complete")
            }.disposed(by: bag)
        
        // 等价于
        // <=============>
        
        let observer: AnyObserver<Data> = AnyObserver.init { (event) in
            switch event {
            case .next(let data):
                print(String.init(data: data, encoding: .utf8) ?? "\(data)")
            case .error(let error):
                print("data task error: \(error)")
            case .completed:
                print("data task complete")
            }
        }
        
        URLSession.shared.rx.data(request: URLRequest.init(url: url))
            .subscribe(observer)
            .disposed(by: bag)
    }
    
    func anyObserverString() {
        /*
        let observable = Single<String>.create { (single) -> Disposable in
            let next = arc4random()%2 == 1
            if next {
                single(.success("hello rxswift"))
            } else {
                single(.failure(RxNoteError.anyObserverError))
            }
            return Disposables.create()
        }
         */
        let observable = Observable<String>.create { (observe) -> Disposable in
            observe.onNext("hello rxswift")
            let next = arc4random()%2 == 1
            if next {
                observe.onNext("hello rxswift")
            } else {
                observe.onError(RxNoteError.anyObserverError)
            }
            observe.onCompleted()
            return Disposables.create()
        }
        
        observable.subscribe { (val) in
            print(val)
        } onError: { (error) in
            print(error)
        } onCompleted: {
            print("string observable complete")
        }.disposed(by: bag)
        
        let observer = AnyObserver<String>.init { (event) in
            switch event {
            case .completed:
                print("string observable complete")
            case .next(let val):
                print(val);
            case .error(let error):
                print(error)
            }
        }
        
        observable
            .subscribe(observer)
            .disposed(by: bag)
    }
    
    // MARK: - Binder
    func binder()  {
        let button = UIButton.init()
        
        let observable = Observable<Bool>.create { (o) -> Disposable in
            o.onNext(true)
            o.onCompleted()
            return Disposables.create()
        }
        
        observable
            .bind(to: button.rx.isEnabled)
            .disposed(by: bag)
        
        // 等价
        // <=========>
        
        let enableObserver = Binder.init(button) { (btn, value) in
            btn.isEnabled = value
        }
        
        observable
            .subscribe(enableObserver)
            .disposed(by: bag)
        
        // isEnable元素的实现就是通过Binder
    }
    
    // MARK: - Observable & Observer 可监听也是观察者
    private func boothObservableObserver() {
        let textField = UITextField()
        
        // 作为可监听序列
        let textObservable = textField.rx.text.orEmpty
        textObservable.subscribe { (text) in
            print(text)
        }.disposed(by: bag)

        let otherTextObservable = Observable<String>.create { (obs) -> Disposable in
            obs.onNext("hello  rx")
            obs.onCompleted()
            return Disposables.create()
        }
        // 作为观察者
        otherTextObservable
            .bind(to: textField.rx.text)
            .disposed(by: bag)
    }
}
