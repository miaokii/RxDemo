//
//  CellEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import Foundation
import SnapKit

// MARK: - cell
public extension UICollectionReusableView {
    /// 复用id
    static var reuseID: String {
        return String.init(describing: Self.self)
    }
}

public extension UITableViewCell {
    /// 复用id
    static var reuseID: String {
        return String.init(describing: Self.self)
    }
}

public class MKCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backColor = .view_l1
        setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 背景色
    public var backColor: UIColor? {
        didSet {
            contentView.backgroundColor = backColor
            backgroundColor = backColor
            if #available(iOS 14.0, *) {
                backgroundConfiguration?.backgroundColor = backColor
            }
        }
    }
    
    public func setup() {}
    public func set(model: Any) {}
}

public class MKTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backColor = .view_l1
        setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 背景色
    public var backColor: UIColor? {
        didSet {
            contentView.backgroundColor = backColor
            backgroundColor = backColor
            if #available(iOS 14.0, *) {
                backgroundConfiguration?.backgroundColor = backColor
            }
        }
    }
    
    public func setup() { }
    public func set(model: Any) {  }
}

/// 圆角cell
public class RoundCornerCell: MKTableCell {
    public var container = UIView()
    public override func setup() {
        selectionStyle = .none
        contentView.addSubview(container)
        container.backgroundColor = .view_l1
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        container.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.bottom.equalToSuperview()
            make.right.equalTo(-10)
            make.height.greaterThanOrEqualTo(20)
        }
    }
}
