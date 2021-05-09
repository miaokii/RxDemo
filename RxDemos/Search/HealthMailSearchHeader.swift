//
//  HealthMailSearchHeader.swift
//  RxDemos
//
//  Created by Miaokii on 2021/5/8.
//

import UIKit

class SandboxManager {
    static var searchHistoryPath: ()->String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/SearchHistory"
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        return path
    }
}

extension UIColor {
    static let tableViewBackground = UIColor.table_bg
    static let textColorLevel1 = UIColor.text_l1
    static let textColorLevel2 = UIColor.text_l2
    static let viewBackgroundColorLevel1 = UIColor.view_l1
}

class RxViewController: RxBagController {}

extension String {
    func size(withFont: UIFont, maxWidth: CGFloat) -> CGSize {
        let att = NSAttributedString.init(string: self,attributes: [NSAttributedString.Key.font: withFont])
        return att.boundingRect(with: .init(width: maxWidth, height: CGFloat.infinity), options: .usesFontLeading, context: nil).size
    }
    /*
     func size(withFont font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
               maxWidth width: CGFloat = UIScreen.main.bounds.width) -> CGSize {
         if self.isEmpty { return CGSize.init(width: 0, height: 0 ) }
         let attrStr = NSAttributedString.init(string: self, attributes: [NSAttributedString.Key.font : font])
         var range = NSMakeRange(0, attrStr.length)
         let dic = attrStr.attributes(at: 0, effectiveRange: &range)
         let sizeToFit = self.boundingRect(with: CGSize.init(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: dic, context: nil).size
         return sizeToFit
     }
     */
}

let screenWidth = UIScreen.main.bounds.width
