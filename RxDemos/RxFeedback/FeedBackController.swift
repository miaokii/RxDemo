//
//  FeedBackController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/27.
//

import UIKit
import RxSwift
import RxCocoa
/*
 
 RxFeedback内容分为状态State、事件Event、反馈循环Feedback Loop
  - State：页面中需要的各种数据，通过状态触发显示或事件
  - Event：描述产生的事件，当发生某个事件时，更新当前状态
  - Feedback Loop：修改状态、IO和资源，例如可以输出状态到UI、将UI事件输入到反馈循环里面
 */
fileprivate struct FeedbackViewModel {
    var data: Observable<[RouteModel]>!
    
    init() {
        data = Observable.just([
            RouteModel.init(name: "Count num", controllerType: CountNumController.self)
        ])
    }
}

class FeedBackController: RxBagController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RxFeedback"
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        tableView.register(cellType: UITableViewCell.self)
        
        let vm = FeedbackViewModel.init()
        vm.data
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { _, model, cell in
                cell.textLabel?.text = model.name
            }
            .disposed(by: bag)
        tableView.rx.modelSelected(RouteModel.self).subscribe(onNext: { [weak self] _ in
            let vc = CountNumController.init()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        .disposed(by: bag)
    }
}
