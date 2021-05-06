//
//  MKView.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

open class MKView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open func setup() {}
    open func set(model: Any) {}
}
