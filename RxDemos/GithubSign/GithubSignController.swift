//
//  GithubSignController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

class GithubSignController: MKPageViewController {

    private var sourceVM = HomeGithubSignViewModel.init()
    private let bag = DisposeBag.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.delegate = self
        
        tableView.register(cellType: UITableViewCell.self)
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
