//
//  GithubTrendPageController.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

class GithubTrendPageController: RxBagController {
    private var routes = Observable<[RouteModel]>.just(
        [RouteModel.init(name: "MVC Github Trend", controllerType: MVCTrendController.self),
                          .init(name: "MVVM GitHub Trend", controllerType: GithubTrendController.self)]
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Github Trend"
        
        routes.bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { _, model, cell in
            cell.textLabel?.text = model.name
        }.disposed(by: bag)
        
        tableView.rx.modelSelected(RouteModel.self).subscribe(onNext: { model in
            let vc = model.controllerType.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: bag)
    }
}
