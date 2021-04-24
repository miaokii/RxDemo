//
//  MKScrollController.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

open class MKScrollController: MKViewController {

    /// 滑动视图，懒加载
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .clear
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
       return scrollView
    }()
    
    /// 懒加载 滑动视图的内容视图，所有的子元素都放在这里面
    ///
    /// 子元素布局首尾相接，就会撑开整个视图，从而滑动
    /// 如果布局设置正确，scrollView的cotentsize就会自动计算，不需重手动设置
    public lazy var scrollContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(MKDefine.screenWidth)
        }
        return container
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addScrollSubViews()
    }

    /// 在该方法添加子视图
    open func addScrollSubViews() {
        
    }
}
