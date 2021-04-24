//
//  ViewController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit

class HomeViewController: MKPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = ["Simple validation", "Github Login"]
        cellType = HomeCell.self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc: UIViewController
        if indexPath.row == 0 {
            vc = SimpleValidationController.init()
        } else {
            vc = MKViewController()
        }
        navigationController?.pushViewController(vc, animated: true)
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
