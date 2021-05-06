//
//  UIImageEx.swift
//  MKSwiftRes
//
//  Created by miaokii on 2021/1/28.
//

import UIKit

// MARK: - UIImage
public extension UIImage {
    
    /// 使用主题色生成的照片
    static let themeImage = UIImage.init(color: .theme)
    
    /// 根据颜色生成图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片大小
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)){
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect.init(origin: CGPoint.zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
    
    /// 缩放图片
    /// - Parameter size: 目的大小
    /// - Returns: 缩放后图片
    func scale(to size: CGSize) -> UIImage {
        // 获得原图像的 大小 宽  高
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        
        // 计算图像新尺寸与旧尺寸的宽高比例
        let widthFactor = size.width/width
        let heightFactor = size.height/height
        // 获取最小的比例
        let scalerFactor = (widthFactor < heightFactor) ? widthFactor : heightFactor
        
        // 计算图像新的高度和宽度，并构成标准的CGSize对象
        let scaledWidth = width * scalerFactor
        let scaledHeight = height * scalerFactor
        let targetSize = CGSize(width: scaledWidth, height: scaledHeight)
        
        // 创建绘图上下文环境
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        
        // 获取上下文里的内容，将视图写入到新的图像对象
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
}
