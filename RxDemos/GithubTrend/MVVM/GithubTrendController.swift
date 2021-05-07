//
//  GithubTrendController.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit

class GithubTrendController: RxBagController {
    
    private let viewModel = GithubTrendViewModel.init(language: "Swift", githubService: .share)
    private let rightItem = UIBarButtonItem.init(image: .init(systemName: "list.dash"))
    private let refreshControl = UIRefreshControl.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    override func setUI() {
        navigationItem.rightBarButtonItem = rightItem
        cellType = nil
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    override func setBind() {
        
        // MARK: - output
        
        viewModel.repos
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID, style: .subtitle)) { _, model, cell in
                cell.textLabel?.text = model.fullName
                cell.detailTextLabel?.text = "\(model.description)\n ⭐️ \(model.starsCount)"
                cell.detailTextLabel?.numberOfLines = 0
            }
            .disposed(by: bag)
        
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: bag)
        
        viewModel.showRepo
            .subscribe(onNext: { [weak self] url in
                self?.openRepository(url)
            })
            .disposed(by: bag)
        
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] msg in
                self?.presentAlert(message: msg)
            })
            .disposed(by: bag)
        
        viewModel.showLanguageList
            .subscribe(onNext: { [weak self] in
                self?.showLanguageList()
            })
            .disposed(by: bag)
        
        // MARK: - input
        
        refreshControl.rx.controlEvent(.valueChanged)
            .do(onNext: { [weak self] in
                self?.refreshControl.beginRefreshing()
            })
            .bind(to: viewModel.reload)
            .disposed(by: bag)
        
        rightItem.rx.tap
            .bind(to: viewModel.chooseLanguage)
            .disposed(by: bag)
        
        tableView.rx.modelSelected(GithubRepo.self)
            .bind(to: viewModel.selectRepo)
            .disposed(by: bag)
    }
    
    private func showLanguageList() {
        let vc = GithubLanguageController.init()
        vc.didSelectedLanguage
            .bind(to: viewModel.setCurrentLanguage)
            .disposed(by: bag)
        vc.didSelectedLanguage
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
