//
//  HealthMailSearchResultController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/5/9.
//

import UIKit

class HealthMailSearchResultController: RxViewController {
    var searchKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Result"
    }
    
    override func setUI() {
        let keyLabel = UILabel.init(super: view,
                                    text: searchKey,
                                    font: .boldSystemFont(ofSize: 22))
        keyLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
