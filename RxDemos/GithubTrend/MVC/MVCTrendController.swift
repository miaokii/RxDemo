//
//  MVCTrendController.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class MVCTrendController: RxBagController {
    
    private var githubTrendService = GithubTrendService.share
    private var datas = [GithubRepo]()
    private var language = "Swift"
    private var refreshControl = UIRefreshControl.init()
    
    private var rxLanguage = BehaviorRelay<String>.init(value: "Swift")
    private var rightItem = UIBarButtonItem.init(image: UIImage.init(systemName: "list.dash"))
    
    // MARK: - MVC
    
    #if false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellType = nil
        tableView.insertSubview(refreshControl, at: 0)
        refreshControl.addTarget(self, action: #selector(requestRepos), for: .valueChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let rightItem = UIBarButtonItem.init(image: UIImage.init(systemName: "list.dash")) { [weak self] in
            let vc = MVCLanguageController.init()
            vc.selectedLanguage = { lan in
                self?.language = lan
                self?.requestRepos()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        navigationItem.rightBarButtonItem = rightItem
        
        requestRepos()
    }
     
    @objc private func requestRepos() {
        refreshControl.beginRefreshing()
        navigationItem.title = language
        githubTrendService.getTrend(by: language) { [weak self] result in
            self?.refreshControl.endRefreshing()
            switch result {
            case .success(let repos):
                self?.datas = repos
                self?.tableView.reloadData()
            case .failure(let error):
                self?.presentAlert(message: error.localizedDescription)
            }
        }
    }
    #else
    // MARK: - MVC + Rx
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    override func setUI() {
        cellType = nil
        tableView.insertSubview(refreshControl, at: 0)
        navigationItem.rightBarButtonItem = rightItem
    }
    
    override func setBind() {
        rightItem.rx.tap
            .subscribe(onNext: { _ in
                let vc = MVCLanguageController.init()
                vc.didSelectLanguage
                    .do(onNext:{ [weak self] _ in self?.navigationController?.popViewController(animated: true) })
                    .bind(to: self.rxLanguage)
                    .disposed(by: self.bag)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
        
        rxLanguage
            .bind(to: navigationItem.rx.title)
            .disposed(by: bag)
        
        // 刷新事件序列
        let refreshObservable = refreshControl.rx.controlEvent(.valueChanged).asObservable()
        // 根据语言重载事件 = 刷新+语言改变
        let reloadObservable = Observable.combineLatest(refreshObservable.startWith().debug(), rxLanguage.debug()) { _, lang in return lang
        }
        .debug()
        .do(onNext: {[weak self] _ in self?.refreshControl.beginRefreshing()})
        // 转换序列为请求结果
        .flatMap { [unowned self] lang in
            githubTrendService.rxGetTrend(by: lang)
                .subscribe(on: MainScheduler.instance)
                .catch { error in
                    self.presentAlert(message: error.localizedDescription)
                    return .empty()
                }
        }
        .do(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        })
        
        reloadObservable
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID, style: .subtitle)) { _, model, cell in
                cell.textLabel?.text = model.fullName
                cell.detailTextLabel?.text = "\(model.description)\n ⭐️ \(model.starsCount)"
                cell.detailTextLabel?.numberOfLines = 0
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(GithubRepo.self)
            .subscribe(onNext: { [weak self] repo in
                self?.openRepository(repo.url)
            })
            .disposed(by: bag)
    }
    #endif
}

extension MVCTrendController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UITableViewCell.self, style: .subtitle)
        cell.textLabel?.text = datas[indexPath.item].fullName
        cell.detailTextLabel?.text = "\(datas[indexPath.item].description)\n ⭐️ \(datas[indexPath.item].starsCount)"
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}

