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
        let searchView = SearchView.init()
        let searchBtn = UIButton.init(super: searchView,
                                      title: searchKey,
                                      titleColor: .text_l1,
                                      normalImage: UIImage.init(named: "搜索图标"),
                                      backgroundColor: .tableViewBackground,
                                      font: .systemFont(ofSize: 14),
                                      cornerRadius: 15)
        searchBtn.contentHorizontalAlignment = .left
        searchBtn.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        searchBtn.titleEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 0)
        searchBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        searchBtn.setClosure { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigationItem.titleView = searchView
    }
    
    override func setBind() {
        
    }
}
