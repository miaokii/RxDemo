//
//  DirverObservableController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/25.
//

import UIKit
import RxSwift
import RxCocoa

class DirverObservableController: RxBagController {

    private var searchField: UITextField!
    private var countLabel: UILabel!
        
    override func setUI() {
        let searchView = UIView.init(super: nil,
                                     backgroundColor: .view_l1)
        searchView.frame = .init(x: 0, y: 0, width: view.width, height: 80)
        searchField = UITextField.init(super: searchView,
                                       placeHolder: "输入Github仓库", backgroundColor: .table_bg,
                                       cornerRadius: 15)
        searchField.leftView = .init(frame: .init(x: 0, y: 0, width: 15, height: 30))
        searchField.leftViewMode = .always
        searchField.frame = .init(x: 20, y: 10, width: searchView.width-40, height: 30)
        
        countLabel = UILabel.init(super: searchView,
                                  text: "0 count",
                                  font: .systemFont(ofSize: 12))
        countLabel.frame = .init(x: 20, y: 50, width: searchField.width, height: 20)
        
        tableView.tableHeaderView = searchView
        tableView.delegate = nil
        tableView.dataSource = nil
    }
    
    private func fetchAutoCompleteItems(_ key: String) -> Observable<[String]> {
        let count = arc4random() % 20
        let digits = Int(arc4random()%20 + 1)
        let arr = (0..<count).map({ _ in String.randomStr(len: digits) })
        return Observable.just(arr)
    }
    
    override func setBind() {
        let results = searchField.rx.text.orEmpty.asDriver()
            // 节流，0.3s内重复产生的序列会覆盖上次产生的序列
            .throttle(.milliseconds(300))
            .flatMapLatest { query in
                self.fetchAutoCompleteItems(query)
                    .asDriver(onErrorJustReturn: [])
            }
        
        results
            .map{"\($0.count) count result"}
            .drive(countLabel.rx.text)
            .disposed(by: bag)
        
        results
            .drive(tableView.rx.items(cellIdentifier: UITableViewCell.reuseID))
            { _, value, cell in
                cell.textLabel?.text = value
            }
            .disposed(by: bag)
    }
}

fileprivate class GithubRepoCell: MKTableCell {
    override func set(model: Any) {
        guard let name = model as? String else { return }
        textLabel?.text = name
    }
}


extension String{
    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func randomStr(len : Int) -> String{
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}
