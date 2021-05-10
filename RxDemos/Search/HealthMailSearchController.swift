//
//  HealthMailSearchController.swift
//  healthpassport
//
//  Created by miaokii on 2021/5/8.
//  Copyright © 2021 fighter. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchView: UIView {
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}

class HealthMailSearchController: RxViewController {
    
    private var searchField: UITextField!
    private var searchBtn: UIBarButtonItem!
    private var collectionView: UICollectionView!
    private var viewModel = HealthMailSearchViewModel.init()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<MailSearchSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUI() {
        searchBtn = UIBarButtonItem.init(title: "搜索", style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = searchBtn
        
        let searchView = SearchView.init()
        searchField = UITextField.init(super: searchView,
                                       placeHolder: "请输入商品名称",
                                       backgroundColor: .tableViewBackground,
                                       cornerRadius: 15)
        searchField.returnKeyType = .search
        searchField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        let searchIconView = UIView.init()
        let searchIcon = UIImageView.init(super: searchIconView,
                                          image: UIImage.init(named: "搜索图标"),
                                          backgroundColor: .clear)
        searchIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-5)
        }
        searchField.delegate = self
        searchField.leftView = searchIconView
        searchField.leftViewMode = .always
        searchField.clearsOnBeginEditing = true
        navigationItem.titleView = searchView
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 12
        
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .viewBackgroundColorLevel1
        collectionView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        collectionView.register(cellType: MailSearchHistoryCell.self)
        collectionView.register(cellType: MailSearchHotCell.self)
        collectionView.register(headerType: MailSearchHeader.self)
    }
    
    override func setBind() {
        dataSource = RxCollectionViewSectionedReloadDataSource<MailSearchSection>.init { _, coll, indexPath, item in
            if indexPath.section == 0 {
                let cell = coll.dequeueCell(type: MailSearchHistoryCell.self, at: indexPath)
                cell.set(his: item)
                return cell
            } else {
                let cell = coll.dequeueCell(type: MailSearchHotCell.self, at: indexPath)
                cell.set(hot: item)
                return cell
            }
        } configureSupplementaryView: { datas, coll, title, indexPath in
            let sectionHeader = coll.dequeueHeaderView(type: MailSearchHeader.self, at: indexPath)
            sectionHeader.set(title: datas.sectionModels[indexPath.section].header, deleteHandle: indexPath.section == 0 ? { [weak self] in
                self?.viewModel.removeAllSearchHistory()
            } : nil)
            return sectionHeader
        }
        
        /// 布局代理
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        /// 选中一个历史搜索或者热点搜索
        collectionView.rx.modelSelected(String.self)
            .do(onNext: { [weak self] key in
                self?.searchEndEdit(key: key)
            })
            .bind(to: viewModel.newSearchKey)
            .disposed(by: rx.disposeBag)

        /// 数据源
        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        /// 搜索关键字结果
        viewModel.editSearchResult
            .subscribe(onNext: { result in
                print(result)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.editSearchResult
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { _, key, cell in
                cell.textLabel?.text = key
            }
            .disposed(by: rx.disposeBag)
        
        /// 关键字搜索为空时，隐藏关键字结果
        viewModel.editSearchResult
            .map{ $0.isEmpty }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        let searchKey = BehaviorRelay<String>.init(value: "")
        /// 双向绑定中过滤掉了待确认的输入
        searchField.rx.textInput <=> searchKey
        
        /// 当搜索编辑时容时，更改搜索建议
        searchKey
            .bind(to: viewModel.editSearchKey)
            .disposed(by: rx.disposeBag)
        
        /// 输入内容才可以编辑
        searchKey
            .map{!$0.isEmpty}
            .bind(to: searchBtn.rx.isEnabled)
            .disposed(by: bag)
        
        searchBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.searchEndEdit(key: self?.searchField.text ?? "")
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] key in
                self?.searchEndEdit(key: key)
            })
            .disposed(by: rx.disposeBag)
    }
    
    /// 保存搜索记录，请求搜索结果页面
    private func searchEndEdit(key: String) {
        
        if searchField.isEditing {
            searchField.text = ""
            searchField.resignFirstResponder()
        }
        
        guard key.count > 0 else {
            return
        }
        let vc = HealthMailSearchResultController.init()
        vc.searchKey = key
        navigationController?.pushViewController(vc, animated: true)
        
        viewModel.newSearchKey
            .onNext(key)
    }
}

extension HealthMailSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let item = dataSource.sectionModels[indexPath.section].items[indexPath.item]
            let size = item.size(withFont: .systemFont(ofSize: 14), maxWidth: screenWidth)
            return .init(width: size.width + 20, height: size.height + 10)
        } else {
            let interSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
            return .init(width: floor(collectionView.width-40-interSpacing)/2, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: screenWidth, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 10, left: 20, bottom: 10, right: 20)
    }
}

extension HealthMailSearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchEndEdit(key: textField.text ?? "")
        return true
    }
}
