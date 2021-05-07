//
//  MVCLanguageController.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

class MVCLanguageController: RxBagController {
    
    private var githubTrendService = GithubTrendService.share
    private var datas = [String]()
    var selectedLanguage: ((String)->Void)?
    
    #if false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellType = nil
        
        tableView.dataSource = self
        tableView.delegate = self
        
        requestLanguages()
    }
    
    private func requestLanguages() {
        githubTrendService.getLanguageList { [weak self] result in
            switch result {
            case .success(let languages):
                self?.datas = languages
                self?.tableView.reloadData()
            case .failure(let error):
                self?.presentAlert(message: error.localizedDescription)
            }
        }
    }
    #else
    
    private var selectLanguage = PublishSubject<String>.init()
    var didSelectLanguage: Observable<String> { return selectLanguage.asObserver() }
    
    override func setUI() {
        title = "Choose Language"
    }
    
    override func setBind() {
        let languages = githubTrendService.rxGetLanguageList()
        languages.bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { _, language, cell in
            cell.textLabel?.text = language
        }
        .disposed(by: bag)
        
        tableView.rx.modelSelected(String.self)
            .bind(to: selectLanguage)
            .disposed(by: bag)
    }
    
    #endif
}

extension MVCLanguageController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UITableViewCell.self, style: .subtitle)
        cell.textLabel?.text = datas[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLanguage?(datas[indexPath.item])
        navigationController?.popViewController(animated: true)
    }
}
