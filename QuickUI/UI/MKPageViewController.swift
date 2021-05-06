//
//  MKPageViewController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit

class MKPageViewController:  MKViewController {
    
    /// 总页数
    var totalPage = 0
    /// 总数据数
    var totalCount = 0
    /// 数据源
    var dataSource: [Any] = []
    /// 当前页数
    var page: Int = 0
    ///
    var tableView: UITableView!
    /// cell类型
    var cellType: MKTableCell.Type! {
        didSet {
            tableView.register(cellType.classForCoder(), forCellReuseIdentifier: cellType.reuseID)
        }
    }
    
    /// 空白页文字
    var emptyTitle = "暂无数据"
    
    var tableStyle = UITableView.Style.plain

    convenience init(style: UITableView.Style = .plain) {
        self.init()
        self.tableStyle = style
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView.init(frame: .zero, style: tableStyle)
        tableView.tableFooterView = .init(frame: .init(x: 0, y: 0, width: view.width, height: 10))
        tableView.separatorStyle = .none
        tableView.backgroundColor = .table_bg
        tableView.delegate = self
        tableView.dataSource = self
        
        if tableStyle == .grouped {
            tableView.tableHeaderView = .init(frame: .init(x: 0, y: 0, width: MKDefine.screenWidth, height: 0.001))
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        view.addSubview(tableView)
        
        cellType = MKTableCell.self
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }

        /*
        tableView.mj_header = RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.page = 0
            self?.emptyTitle = "暂无数据"
            self?.requestList()
        })

        tableView.mj_footer = RefreshFooter.init(refreshingBlock: { [weak self] in
            self?.emptyTitle = "暂无数据"
            self?.requestList()
        })
        
        showEmpty = true
 */
    }
    
    private func resetState() {
        dataSource.removeAll()
        page = 0
        totalPage = 0
        totalCount = 0
//        endMJRefresh()
        willReloadData()
        tableView.reloadData()
    }
    
    /// 下拉请求
    func requestList() { }
    
    /// 即将刷新，这个方法在reload(response:)方法结束时执行
    func willReloadData() { }
    
    /// 刷新
    ///
    /// 这个方法只适用于data返回的数据格式是 ListModel 格式的，如果是其他格式，自己实现
    /*
    func reload<T: HandyJSON>(response: Result<ResultModel<ListModel<T>>, Error>) {
        tableView.mj_header?.endRefreshing()
        tableView.mj_footer?.endRefreshing()
        
        switch response{
        case .success(let result):
            guard let listM = result.data else {
                HUD.flash(hint: result.message)
                resetState()
                return
            }
            page = listM.currPage
            totalPage = listM.totalPage
            totalCount = listM.totalCount
            
            if listM.currPage == 1 {
                dataSource = listM.list
            } else {
                dataSource.append(contentsOf: listM.list)
            }
            endMJRefresh()
        case .failure(let error):
            HUD.flash(error: error)
        }
        willReloadData()
        tableView.reloadData()
    }
    
    /// 结束刷新组件
    /// 设置是否显示footer，如果page达到totalpage，并且数据源数量达到totalCount，就不显示
    func endMJRefresh() {
        tableView.mj_header?.endRefreshing()
        tableView.mj_footer?.endRefreshing()
        let hideMjFooter = page >= totalPage ||
            dataSource.count >= totalCount
        tableView.mj_footer?.isHidden = hideMjFooter
    }
 */
}

extension MKPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseID, for: indexPath) as! MKTableCell
        cell.set(model: dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/*
extension MKPageViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "暂无数据")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return .init(string: emptyTitle, attributes: TextAttributes.init().font(.systemFont(ofSize: 15)).foregroundColor(.text_l2).alignment(.center))
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        requestList()
    }
    
    func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
}
 */
