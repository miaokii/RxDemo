//
//  DirverObservableController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/25.
//

import UIKit
import RxSwift
import RxCocoa

class DirverObservableController: MKPageViewController {

    private var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        dirverBind()
    }
    
    private func setUI() {
        let searchView = UIView.init(super: nil,
                                     backgroundColor: .view_l1)
        searchView.frame = .init(x: 0, y: 0, width: view.width, height: 50)
        searchField = UITextField.init(super: searchView,
                                       placeHolder: "输入Github仓库", backgroundColor: .table_bg,
                                       cornerRadius: 15)
        searchField.leftView = .init(frame: .init(x: 0, y: 0, width: 15, height: 30))
        searchField.leftViewMode = .always
        searchField.frame = .init(x: 20, y: 10, width: searchView.width-40, height: 30)
        
        tableView.tableHeaderView = searchView
    }
    
    private func dirverBind() {
        let result = searchField.rx.text.asDriver()
    
    }
}

fileprivate class GithubRepoCell: MKTableCell {
    override func set(model: Any) {
        
    }
}
