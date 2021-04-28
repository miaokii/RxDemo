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
 操作符：变换组合原有序列，组成新的序列
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
 |    * 一般情况下状态序列会用Diver类型，事件序列选用Signal类型
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
 |  1、AsyncSubject
 |       AsyncSubject将在源Observable产生完事件后，只发出最后一个事件，如果源Observable
 |       没有任何元素，只有一个完成事件，AsyncSubject也只有一个完成事件，如果源序列产生一个error
 |       事件而终止，AsyncSubject不会发出任何事件，而是发出error事件后终止
 |  2、PublishSubject
 |       PublishSubject只会对观察者发出订阅后产生的事件，如果源Observable产生错误事件，那么观察
 |       者会接收到该错误之前添加订阅之后的所有事件，包括error事件
 |  3、ReplaySubject
 |       ReplaySubject可以将所有元素（buffersize指定数量）发送给观察者，不论观察者合适进行订阅
 |  4、BehaviorSubject
 |       观察者对BehaviorSubject进行订阅时，他会将源Observable中最新的元素发送出来，如果没有
 |       最新元素，就会发送默认的元素，随后正常发送元素
 
 Schedulers 调度器 ----------------------------------------
 |  Schedulers是Rx实现多线程核心，主要控制任务在那个线程或多列运行
 |  比如数据请求放在后台线程执行，显示请求结果放在主线程执行
 |
 |   1、subscribeOn
 |       决定序列数据的构建在那个Scheduler上执行
 |   2、observeOn
 |       决定序列在那个Scheduler上监听
 |   3、MainScheduler
 |       主线程
 |   4、SerialDispatchQueueScheduler
 |       串行队列
 |   5、ConcurrentDispatchQueueScheduler
 |       并行队列
 |   6、OperationQueueScheduler
 |       OperationQueue的抽象，可以设置最大并发数maxConcurrentOperationCount

 错误处理 ----------------------------------------
    当产生序列发生错误时，序列就会终止，并发出错误事件，此时有两种处理方式
    1、retry
        发生错误时重试，可以指定重试次数
    2、retryWhen
        可以指定重试的时机
    3、
 */

// MARK: - Error
enum RxNoteError: Error {
    case cantParseJSON
    case completeError
    case maybeError
    
    case anyObserverError
    case asyncSubjectError
}

let url = URL.init(string: "https://api.github.com/repos/RxSwift")!
typealias JSON = Any

// MARK: - 生产序列或订阅
class RxBag  {
    static let share = RxBag()
    var bag = DisposeBag()
    
    // MARK: - Observable
    private func observabNum() -> Observable<Int> {
        return Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onError(RxNoteError.completeError)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func observableJSON() -> Observable<JSON> {
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
    private func singleObservable() -> Single<[String: Any]> {
        // single其实是Result<Element, Error>类型
        return Single<[String: Any]>.create { (single) -> Disposable in
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                // 请求失败，产生一个error事件
                if let err = error {
                    single(.failure(err))
                    return
                }
                // 解析失败，产生一个error事件
                guard let data = data, let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
                    single(.failure(RxNoteError.cantParseJSON))
                    return
                }
                // 解析成功，发送一个成功事件
                single(.success(jsonObj))
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }

    // MARK: - Completable事件
    private func completeObservable() -> Completable {
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
    private func maybeObservable() -> Maybe<String> {
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
    private func dirverObservable() {
        // 查看DirverObservableController
    }
    
    // MARK: - AnyObserver
    private func anyObserver()  {
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
    
    private func anyObserverString() {
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
    private func binder()  {
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
    
    // MARK: - AsyncSubject
    private func asyncSubject() {
        let subject = AsyncSubject<String>.init()
        subject.subscribe { (str) in
            print(str)
        } onError: { (errpr) in
            print(errpr)
        } onCompleted: {
            print("subject complete")
        }.disposed(by: bag)
        
        // 只会发出完成事件之前的最后一个元素
        subject.onNext("🐷")
        subject.onNext("🐶")
        // 如果序列中有error，就会发出error
        subject.onError(RxNoteError.asyncSubjectError)
        subject.onNext("🐱")
        subject.onNext("🐔")
        subject.onCompleted()
    }
    
    // MARK: - PublishSubject
    private func publishSubject() {
        // 对订阅者发出订阅后的元素
        let subject = PublishSubject<String>.init()
        
        subject.onNext("🐷")
        subject.onNext("🐂")
        
        // 添加订阅
        subject.subscribe { (event) in
            switch event {
            case .next(let str):
                print(str)
            case .error(let error):
                print(error)
            case .completed:
                print("publish subject complete")
            }
        }.disposed(by: bag)
        
        subject.onNext("🐑")
        subject.onNext("🐎")
        subject.onNext("🐱")
        // 如果有错误事件，发出错误事件后终止
        subject.onError(RxNoteError.anyObserverError)
        subject.onNext("🐭")
        subject.onCompleted()
    }
    
    // MARK: - ReplaySubject
    private func replaySubject() {
        // buffersize指定添加观察之前添加监听的元素数量
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        subject.onNext("🐷")
        subject.onNext("🐂")
        
        // 添加订阅
        subject.subscribe { (event) in
            switch event {
            case .next(let str):
                print(str)
            case .error(let error):
                print(error)
            case .completed:
                print("publish subject complete")
            }
        }.disposed(by: bag)
        
        subject.onNext("🐑")
        subject.onNext("🐎")
        // 如果有错误事件，发出错误事件后终止
        // subject.onError(RxNoteError.anyObserverError)
        subject.onCompleted()
    }
    
    // MARK: - BehaviorSubject
    private func behaviorSubject() {
        let subject = BehaviorSubject<String>.init(value: "㊗️")
        
        subject.onNext("🐶")
        // 添加订阅
        subject.subscribe { (event) in
            switch event {
            case .next(let str):
                print(str)
            case .error(let error):
                print(error)
            case .completed:
                print("publish subject complete")
            }
        }.disposed(by: bag)
        
        subject.onNext("🐑")
        subject.onNext("🐎")
        subject.onNext("🐱")
        // 如果有错误事件，发出错误事件后终止
        // subject.onError(RxNoteError.anyObserverError)
        subject.onNext("🐭")
        subject.onCompleted()
    }
    
    // MARK: - Schedulers
    private func schedulers() {
        // 全局队列读取数据，主线程使用数据
        DispatchQueue.global().async(qos: .userInitiated) {
            guard let data = try? Data.init(contentsOf: url) else {
                print("error read data")
                return
            }
            DispatchQueue.main.async {
                print(data)
            }
        }
        
        // ---------->
        
        let rxData = Single<Data>.create { (signle) -> Disposable in
            guard let data = try? Data.init(contentsOf: url) else {
                signle(.failure(RxNoteError.maybeError))
                return Disposables.create()
            }
            signle(.success(data))
            return Disposables.create()
        }
        
        rxData
            // 决定数据序列的构建函数在哪个 Scheduler 上运行
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            // 在那个Scheduler上监听数据
            .observe(on: MainScheduler.instance)
            .subscribe { (data) in
                print(data)
            } onFailure: { (error) in
                print(error)
            }.disposed(by: bag)

    }
}

// MARK: - 创建序列
extension RxBag {
    func create() {
        Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            observer.onNext(2)
            observer.onCompleted()
            return Disposables.create()
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
    }
}

// MARK: - 转换序列
extension RxBag {
    // MARK: - map
    func map() {
        Observable.of(1, 2, 3)
            .map{ $0 * 10 }
            .subscribe(onNext: { print($0) })
            .disposed(by: bag)
    }
    // MARK: - flatMap
    func flatMap() {
        let streamA = Observable.of(10, 20, 30)
        let streamB: ((Int) -> Observable<Int>) = { n in
            let d = Observable.of(n+1, n+2, n+3)
            print("(\(n))")
            return d
        }
        
        streamA
            .flatMap{ streamB($0) }
            .subscribe(onNext: { print($0) })
            .disposed(by: bag)
    }
    
    // MARK: - flatMapLatest
    func flatMapLatest() {
        let stream1 = Observable.of(1, 2, 3)
        let stream2 = Observable.of(4, 5, 6)
        Observable.of(stream1, stream2)
            .flatMapLatest{ $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: bag)
    }
    
    // MARK: - flatMapFirst
    func flatMapFirst() {
        let stream1 = Observable.of(1, 2, 3)
        let stream2 = Observable.of(4, 5, 6)
        Observable.of(stream1, stream2)
            .flatMapFirst{ $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: bag)
    }
}

// MARK: - 过滤序列
extension RxBag {
    // MARK: - take
    func take() {
        Observable.of(1, 2, 3, 4)
            .take(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: bag)
    }
}

// MARK: - 调用
extension RxBag {

    private func observableTest() {
        let json = observableJSON()
        json
        .subscribe { (json) in
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
        // 发生错误3s后重试
        jsonObj.retry(when: { (error) -> Observable<Int> in
            return Observable.timer(.seconds(3), scheduler: MainScheduler.instance)
        }).subscribe { (json) in
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
    
    static func Call() {
        share.take()
    }
}
