//
//  ActivityIndicator.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import RxSwift
import RxCocoa

/// ObservableConvertibleType可以转换为可观察序列
/// Disposable可释放的资源
private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    
    private let _source: Observable<E>
    private let _dispose: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping ()->Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }
    
    func dispose() {
        _dispose.dispose()
    }
    
    func asObservable() -> Observable<E> {
        return _source
    }
}

/// 表示活动指示器，是一个可观察的共享源序列
class ActivityIndicator: SharedSequenceConvertibleType {
    
    // 共享策略
    typealias SharingStrategy = DriverSharingStrategy
    // 序列元素类型
    typealias Element = Bool
    
    // 锁
    private let _lock = NSRecursiveLock()
    // BehaviorRelay是BehaviorSubject的封装，BehaviorSubject会发送源中的最新元素，如果源没有元素可以发送默认元素，如果遇到错误或者完成事件会停止，BehaviorRelay遇到错误和完成事件不会停止
    // 默认值0
    private let _relay = BehaviorRelay.init(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    init() {
        _loading = _relay.asDriver()
            .map{ $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        // 创建一个可被清除的资源，它和 Observable 具有相同的寿命
        return Observable.using { () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken.init(source: source.asObservable(), disposeAction: self.decrement)
        } observableFactory: { (token) -> Observable<Source.Element> in
            return token.asObservable()
        }
    }
    
    private func increment() {
        _lock.lock()
        _relay.accept(_relay.value + 1)
        _lock.unlock()
    }
    
    private func decrement() {
        _lock.lock()
        _relay.accept(_relay.value - 1)
        _lock.unlock()
    }
    
    func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Bool> {
        return _loading
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
