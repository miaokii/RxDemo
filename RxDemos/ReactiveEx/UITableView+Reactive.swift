//
//  UITableView+Reactive.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UITableView {
//    public func items<Sequence: Swift.Sequence, Cell: UITableViewCell, Source: ObservableType>
//        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
//        -> (_ source: Source)
//        -> (_ configureCell: @escaping (Int, Sequence.Element, Cell) -> Void)
//        -> Disposable
//        where Source.Element == Sequence {
//        return { source in
//            return { configureCell in
//                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<Sequence> { tv, i, item in
//                    let indexPath = IndexPath(item: i, section: 0)
//                    let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! Cell
//                    configureCell(i, item, cell)
//                    return cell
//                }
//                return self.items(dataSource: dataSource)(source)
//            }
//        }
//    }
    
    
}
