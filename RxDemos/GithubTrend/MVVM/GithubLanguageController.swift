//
//  GithubLanguageController.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

class GithubLanguageController: RxBagController {
    
    private var viewModel = GithubLanguageViewModel.init()
    var didSelectedLanguage = PublishRelay<String>.init()
    
    override func setUI() {
        title = "Choose Language"
    }
    override func setBind() {
        viewModel.languages
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { _, lang, cell in
                cell.textLabel?.text = lang
            }
            .disposed(by: bag)
        
        viewModel.didSelectedLanguage
            .subscribe(onNext:{ [weak self] lang in
                self?.didSelectedLanguage.accept(lang)
            })
            .disposed(by: bag)
        
        tableView.rx.modelSelected(String.self)
            .bind(to: viewModel.selectedLanguage)
            .disposed(by: bag)
    }
}
