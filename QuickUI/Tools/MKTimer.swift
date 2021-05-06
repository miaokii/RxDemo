//
//  KKWTimer.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import Foundation

public class MKWTimer: NSObject {
    private var timer: Timer!
    fileprivate weak var target: AnyObject!
    fileprivate var selector: Selector!
    
    public var fireDate: Date {
        get{
            return timer.fireDate
        }
        set{
            timer.fireDate = newValue
        }
    }
    
    public class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: AnyObject, selector aSelector: Selector, userInfo: Any? = nil, repeats yesOrNo: Bool = true) -> MKWTimer {
       let timer = MKWTimer()
       
       timer.target = aTarget
       timer.selector = aSelector
       timer.timer = Timer.scheduledTimer(timeInterval: ti, target: timer, selector: #selector(MKWTimer.timerAction), userInfo: userInfo, repeats: yesOrNo)
        RunLoop.main.add(timer.timer, forMode: RunLoop.Mode.common)
       return timer
    }
    
    public class func scheduledTimer(timeInterval: TimeInterval, repeats: Bool = true, timeClosure: @escaping ()->Void) -> MKWTimer {
        let timer = MKWTimer()
        timer.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: { (_) in
            timeClosure()
        })
        RunLoop.main.add(timer.timer, forMode: RunLoop.Mode.common)
        return timer
    }

    public func fire() {
       timer.fire()
    }

    public func invalidate() {
       timer.invalidate()
    }

    @objc private func timerAction() {
       _ = target.perform(selector)
    }
    
    deinit {
       print("deinit timer")
    }
}
