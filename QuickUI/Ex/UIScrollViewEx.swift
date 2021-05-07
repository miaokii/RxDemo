//
//  UIScrollViewEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

public typealias MKTableViewCombineDelegate = UITableViewDataSource & UITableViewDelegate
public extension UITableView {
    
    /// 遍历构造tableview
    /// - Parameters:
    ///   - superView: 父视图
    ///   - frame: 默认zero
    ///   - style: 默认plain
    ///   - object: 代理，默认nil
    ///   - backgroundColor: 默认table_bg
    ///   - separatorColor: 默认table_bg
    ///   - separatorStyle: 分割线风格 默认singleLine
    ///   - allowsSelection: 允许选中 默认true
    ///   - contentInset: 内缩 默认zero
    convenience init(super view: UIView?,
                     frame: CGRect = .zero,
                     style: Style = .plain,
                     delegate object: MKTableViewCombineDelegate? = nil,
                     backgroundColor: UIColor = .table_bg,
                     separatorColor: UIColor = .line_gray,
                     separatorStyle: UITableViewCell.SeparatorStyle = .singleLine,
                     allowsSelection: Bool = true,
                     contentInset: UIEdgeInsets = .zero){
        self.init(frame: frame, style: style)
        self.backgroundColor = backgroundColor
        tableFooterView = UIView()
        self.separatorColor = separatorColor
        self.separatorStyle = separatorStyle
        self.contentInset = contentInset
        self.allowsSelection = allowsSelection
        
        if let target = object {
            delegate = target
            dataSource = target
        }
        
        if let sv = view {
            sv.addSubview(self)
            if style == .grouped {
                tableHeaderView = .init(frame: .init(x: 0, y: 0, width: sv.frame.width, height: 0.001))
            }
        }
    }
    
    /// 注册nib cell
    /// - Parameters:
    ///   - name: nib名称
    ///   - cellType: cell类
    func register(nib name: String, cellType: UITableViewCell.Type) {
        register(UINib.init(nibName: name, bundle: nil), forCellReuseIdentifier: cellType.reuseID)
    }
    
    /// 注册cell
    /// - Parameter cellType: cell类型
    func register(cellType: UITableViewCell.Type) {
        register(cellType.classForCoder(), forCellReuseIdentifier: cellType.reuseID)
    }
    
    /// 寻找复用cell
    /// - Parameters:
    ///   - type: cell类型
    ///   - indexPath: 位置
    /// - Returns: type类型的cell
    func dequeueCell<T: UITableViewCell>(type: T.Type, at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: type.reuseID, for: indexPath) as! T
    }
    
    /// 寻找复用cell，如果没找到会创建
    /// - Parameter type: cell类型
    /// - Returns: type类型的cell
    func dequeueCell<T: UITableViewCell>(type: T.Type, style: UITableViewCell.CellStyle = .default) -> T {
        var cell = dequeueReusableCell(withIdentifier: type.reuseID) as? T
        if cell == nil {
            cell = T.init(style: style, reuseIdentifier: type.reuseID)
        }
        return cell!
    }
}

public typealias MKCollectionViewCombineDelegate = UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
public extension UICollectionView {
    
    func register(nib name: String, cellType: UICollectionViewCell.Type) {
        register(UINib.init(nibName: name, bundle: nil), forCellWithReuseIdentifier: cellType.reuseID)
    }
    
    func register(nib name: String, headerType: UICollectionReusableView.Type) {
        register(UINib.init(nibName: name, bundle: nil),
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: headerType.reuseID)
    }
    
    func register(nib name: String, footerType: UICollectionReusableView.Type) {
        register(UINib.init(nibName: name, bundle: nil),
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: footerType.reuseID)
    }
    
    func register(cellType: UICollectionViewCell.Type) {
        register(cellType.classForCoder(), forCellWithReuseIdentifier: cellType.reuseID)
    }
    
    func register(headerType: UICollectionReusableView.Type) {
        register(headerType.classForCoder(),
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: headerType.reuseID)
    }
    
    func register(footerType: UICollectionReusableView.Type) {
        register(footerType.classForCoder(),
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: footerType.reuseID)
    }
    
    func dequeueCell<T: UICollectionViewCell>(type: T.Type, at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.reuseID, for: indexPath) as! T
    }
    
    func dequeueHeaderView<T: UICollectionReusableView>(type: T.Type,
                                                        at indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                withReuseIdentifier: type.reuseID,
                                                for: indexPath) as! T
    }
    
    func dequeueFooterView<T: UICollectionReusableView>(type: T.Type,
                                                        at indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                withReuseIdentifier: type.reuseID,
                                                for: indexPath) as! T
    }
}
