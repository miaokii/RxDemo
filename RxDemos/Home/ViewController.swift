//
//  ViewController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit
import RxSwift

class HomeViewController: MKPageViewController {

    var homeVM = HomeViewModel.init()
    private let bag = DisposeBag.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellType = HomeCell.self
        
        tableView.delegate = nil
        tableView.dataSource = nil
            
        homeVM.data.bind(to: tableView.rx.items(cellIdentifier: HomeCell.reuseID)) { (_, model, cell) in
            (cell as! HomeCell).set(model: model.name)
        }.disposed(by: bag)

        tableView.rx.modelSelected(RouteModel.self).subscribe(onNext: { model in
            let vc = model.controllerType.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: bag)
        
    }
}

fileprivate class HomeCell: MKTableCell {
    private var nameLabel: UILabel!
    override func setup() {
        accessoryType = .disclosureIndicator
        nameLabel = UILabel.init(super: contentView,
                                 font: .systemFont(ofSize: 17))
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
        }
    }
    
    override func set(model: Any) {
        guard let item = model as? String else { return }
        nameLabel.text = item
    }
}
