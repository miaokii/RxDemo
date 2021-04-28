//
//  GithubSignController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

fileprivate struct HomeGithubSignViewModel {
    var datas = Observable.just([
        RouteModel.init(name: "MVVM Github Sign", controllerType: MVVMGithubSignController.self)
    ])
}

class GithubSignController: RxBagController {

    private var sourceVM = HomeGithubSignViewModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceVM.datas
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { (_, model, cell) in
                cell.textLabel?.text = model.name
            }.disposed(by: bag)
        
        tableView.rx.modelSelected(RouteModel.self).subscribe(onNext: { (model) in
            let vc = model.controllerType.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: bag)
    }
}
