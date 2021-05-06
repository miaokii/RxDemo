//
//  MKPickerController.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/2/2.
//

import UIKit

open class MKPickerController:  MKPopViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var cancelBtn: UIButton!
    private var confirmbtn: UIButton!
    private var titleLabel: UILabel!
    
    public var options = [[String]]() {
        didSet {
            if filterValues {
                if usefulOptionsIndex == nil {
                    usefulOptionsIndex = [Int]()
                    for (index, vals) in options.enumerated() where vals.count > 1 {
                        usefulOptionsIndex?.append(index)
                    }
                }
            } else if filterValues {
                usefulOptionsIndex = Array(0..<options.count)
            }
            
            if values == nil {
                values = options.map({ $0.first ?? "" })
            }
        }
    }
    
    public var values: [String]!
    public var pickerView: UIPickerView!
    
    public var cancelTitle = "取消"
    public var sureTitle = "确定"
    /// 设置需要返回列的索引
    ///
    /// 如果 options 里某一列只有1个元素，在某些情况可以认为是单位，就不需要返回该值，
    /// 比如options = [["1","2","3"],["月"],["12", "13", "24"],["日"]]，第二第四列只有一个元素，在某些需求里面可以认为是单位，
    /// 这个例子的场景是 选择月日，例如 1月24日，月和日数可以变，但是单位不变，所以不需要返回该单位
    ///
    /// 在默认情况下，options里面如果有某列只有1个元素，就不会返回该列的值，如果要返回该值
    /// 则手动指定 options里面需要返回的index，
    /// 例如上面这个列子，要返回月日的话，usefulOptionsIndex = [0,1,2,3]
    public var usefulOptionsIndex: [Int]?
    /// 是否开启usefulOptionsIndex过滤，默认不开启，每一列都会返回
    public var filterValues = false
    /// 回调
    public var callBackClosure: (([String], [Int]) -> Void)?
    
    private var indexs = [Int]()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = title
        
        var indexs = Array(0..<options.count)
        if filterValues, let usefulIndex = usefulOptionsIndex {
            indexs = usefulIndex
        }
        // 选中默认的picker row
        if let defaultValue = values {
            for (valueIndex, comIndex) in indexs.enumerated() {
                if let rowIndex = options[comIndex].firstIndex(of: defaultValue[valueIndex]) {
                    pickerView.selectRow(rowIndex, inComponent: comIndex, animated: true)
                }
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        popStyle = .bottom
        
        contentView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3).priority(.low)
            make.left.right.equalToSuperview()
        }
        
        let topLine = UIView.init(super: contentView,
                                  backgroundColor: .table_bg)
        topLine.snp.makeConstraints { (make) in
            make.top.equalTo(60)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        cancelBtn = UIButton.init()
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 15)
        cancelBtn.setTitle(cancelTitle, for: .normal)
        cancelBtn.setTitleColor(.text_l3, for: .normal)
        cancelBtn.setClosure { [unowned self] (_) in
            self.hide()
        }
        contentView.addSubview(cancelBtn)
        cancelBtn.contentHorizontalAlignment = .left
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.bottom.equalTo(topLine.snp.top).offset(-10)
            make.width.greaterThanOrEqualTo(40)
        }
        
        confirmbtn = UIButton()
        confirmbtn.setTitleColor(.text_l1, for: .normal)
        confirmbtn.setTitle(sureTitle, for: .normal)
        confirmbtn.titleLabel?.font = .systemFont(ofSize: 15)
        confirmbtn.setClosure { [unowned self] (_) in
            self.makeSelectedValues()
        }
        contentView.addSubview(confirmbtn)
        confirmbtn.contentHorizontalAlignment = .right
        confirmbtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.bottom.width.equalTo(cancelBtn)
        }
        
        cancelBtn.setContentHuggingPriority(.required, for: .horizontal)
        confirmbtn.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(cancelBtn)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(cancelBtn.snp.right).offset(20)
            make.right.lessThanOrEqualTo(confirmbtn.snp.left).offset(-20)
        }
        
        pickerView = UIPickerView.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        contentView.addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-MKDefine.bottomSafeAreaHeight-15)
            make.height.equalTo(200)
            make.top.equalTo(topLine.snp.bottom).offset(15)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.round(corners: [.topLeft, .topRight], radius: 8)
    }
    
    private func makeSelectedValues() {
        values = [String]()
        indexs.removeAll()
        if filterValues {
            for index in usefulOptionsIndex! where index < options.count {
                let row = pickerView.selectedRow(inComponent: index)
                values.append(options[index][row])
                indexs.append(row)
            }
        } else {
            for index in 0..<options.count {
                let row = pickerView.selectedRow(inComponent: index)
                values.append(options[index][row])
                indexs.append(row)
            }
        }
        confirm()
    }
    
    func confirm() {
        callBackClosure?(values, indexs)
        hide()
    }
}

// MARK: -- PickerView代理
public extension MKPickerController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if options.count == 1 {
            return pickerView.width
        }
        let rowWidth = options[component].first!.size().width
        return rowWidth + (options[component].count > 1 ? 40 : 20)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel.init()
        label.font = .systemFont(ofSize: 20)
        label.text = options[component][row]
        label.textColor = .text_l1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }
}
