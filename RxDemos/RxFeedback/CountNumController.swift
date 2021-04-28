//
//  CountNumController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/27.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

enum CountEvent {
    case increment
    case decrement
}

class CountNumController: RxBagController {
    
    private var numLabel: UILabel!
    private var plusBtn: UIButton!
    private var minuBtn: UIButton!
    private var num = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Count Num"
    }
    
    override func setUI() {
        
        let countView = UIView.init(super: view,
                                    backgroundColor: .table_bg,
                                    cornerRadius: 5)
        countView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(50)
        }
        
        numLabel = UILabel.init(super: countView,
                                text: "\(num)",
                                font: .boldSystemFont(ofSize: 20))
        numLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        plusBtn = UIButton.init(super: countView,
                                normalImage: UIImage.init(systemName: "plus"))
        plusBtn.snp.makeConstraints { make in
            make.centerY.equalTo(numLabel)
            make.left.equalTo(numLabel.snp.right).offset(30)
            make.right.equalTo(-30)
        }
        minuBtn = UIButton.init(super: countView,
                                normalImage: UIImage.init(systemName: "minus"))
        minuBtn.snp.makeConstraints { make in
            make.centerY.equalTo(numLabel)
            make.right.equalTo(numLabel.snp.left).offset(-30)
            make.left.equalTo(30)
        }
    }
    
    override func setBind() {
        // 定义状态
        typealias State = Int
        // 改变状态的事件
        typealias Event = CountEvent
        Observable.system(
            // 初始状态
            initialState: num,
            // 各个事件对状态的改变
            reduce: { (state, event) -> State in
            switch event {
            case .increment:
                return state + 1
            case .decrement:
                return state - 1
            }
        },
            // UI线程
            scheduler: MainScheduler.instance,
            // UI反馈绑定到页面上
            feedback: bind(self) { me, state -> Bindings<Event> in
                // 将状态输出到label
            let subscriptions = [
                state.map(String.init).bind(to: me.numLabel.rx.text)
            ]
                // 将UI事件变成Event输入到反馈循环里面
            let events = [
                me.plusBtn.rx.tap.map{ Event.increment },
                me.minuBtn.rx.tap.map{ Event.decrement },
            ]
            return Bindings.init(subscriptions: subscriptions, events: events)
            })
        .subscribe()
        .disposed(by: bag)
    }
}
