//
//  HealthMailSearchViews.swift
//  healthpassport
//
//  Created by miaokii on 2021/5/8.
//  Copyright © 2021 fighter. All rights reserved.
//

import UIKit
import RxDataSources


struct MailSearchSection: AnimatableSectionModelType {
    typealias Item = String
    
    var header: String
    var items: [String]
    
    init(header: String, items: [String]) {
        self.header = header
        self.items = items
    }
    
    init(original: MailSearchSection, items: [String]) {
        self = original
        self.items = items
    }
    
    typealias Identity = String
    var identity: String {
        return header
    }
}

class MailSearchHeader: UICollectionReusableView {
    private var titleLabel: UILabel!
    private lazy var deleBtn: UIButton = {
        let btn = UIButton.init(super: self,
                                normalImage: UIImage.init(named: "video_delete"))
        btn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
        }
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel.init(super: self,
                                  textColor: .textColorLevel1,
                                  font: .systemFont(ofSize: 15))
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }
    }
    
    func set(title: String, deleteHandle: (()->Void)? = nil) {
        if let delete = deleteHandle {
            deleBtn.rx.tap
                .subscribe(onNext: {
                    delete()
                }).disposed(by: rx.disposeBag)
        }
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - 历史搜索关键字
class MailSearchHistoryCell: UICollectionViewCell {
    private var addressLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addressLabel = UILabel.init(super: contentView,
                                    textColor: .textColorLevel2,
                                    font: .systemFont(ofSize: 14),
                                    aligment: .center)
        addressLabel.cornerRadius = 3
        addressLabel.backgroundColor = .tableViewBackground
        addressLabel.clipsToBounds = true
        addressLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func set(his: String) {
        addressLabel.text = his
    }
}

// MARK: - 热门搜索关键字
class MailSearchHotCell: UICollectionViewCell {
    private var keyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let dot = UIView.init(super: contentView,
                              backgroundColor: .theme,
                              cornerRadius: 2)
        dot.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(4)
        }
        keyLabel = UILabel.init(super: contentView,
                                    textColor: .textColorLevel2,
                                    font: .systemFont(ofSize: 14),
                                    aligment: .left)
        keyLabel.backgroundColor = .viewBackgroundColorLevel1
        keyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dot.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalTo(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func set(hot: String) {
        keyLabel.text = hot
    }
}
