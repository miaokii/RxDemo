//
//  RxBagController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/27.
//

import UIKit
import RxCocoa
import RxSwift
import SafariServices

class RxBagController: MKViewController {
    var bag = DisposeBag()
    var cellType: UITableViewCell.Type? = UITableViewCell.self
    lazy var tableView: UITableView = {
        let table = UITableView.init(super: view)
        table.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        if let ct = cellType {
            table.register(cellType: ct.self)
        }
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
    
    func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    func openRepository(_ url: String) {
        let url = URL(string: url)!
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.pushViewController(safariViewController, animated: true)
    }
}
