//
//  GithubSearchController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/5/8.
//

import UIKit
import RxSwift
import RxCocoa

class GithubSearchController: RxBagController {

    private var searchBar: UISearchBar!
    private var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setBind() {
        let searchBar = UISearchBar.init(frame: .init(x: 0, y: 0, width: view.width, height: 50))
        searchBar.tintColor = .text_l1
        tableView.tableHeaderView = searchBar
    }
}
