//
//  RxBagController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/27.
//

import UIKit
import RxCocoa
import RxSwift

class RxBagController: MKViewController {
    var bag = DisposeBag()
    lazy var tableView: UITableView = {
        let table = UITableView.init(super: view)
        table.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        table.register(cellType: UITableViewCell.self)
        table.tableFooterView = .init()
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setBind()
    }
    
    func setUI() {
        
    }
    
    func setBind() {
        
    }
}
