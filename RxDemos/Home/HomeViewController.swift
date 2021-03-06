//
//  ViewController.swift
//  RxDemos
//
//  Created by Miaokii on 2021/4/24.
//

import UIKit
import RxSwift

struct HomeViewModel {
    let data = Observable.just([
        RouteModel.init(name: "Simple Binding", controllerType: SimpleValidController.self),
        RouteModel.init(name: "Github sign", controllerType: GithubSignController.self),
        RouteModel.init(name: "Github Trend", controllerType: GithubTrendPageController.self),
        RouteModel.init(name: "Image Picker", controllerType: ImagePickerController.self),
        RouteModel.init(name: "API Wrappers", controllerType: APIWrapperController.self),
        RouteModel.init(name: "RxFeedback", controllerType: FeedBackController.self),
        RouteModel.init(name: "Github search", controllerType: GithubSearchController.self),
        .init(name: "Search", controllerType: HealthMailSearchController.self)
    ])
//    let data = Observable<[RouteModel]>.empty()
}

struct RouteModel {
    var name = ""
    var controllerType = MKViewController.self
}

class HomeViewController: RxBagController{

    var homeVM = HomeViewModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        homeVM.data.bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.reuseID)) { (_, model, cell) in
            cell.textLabel?.text = model.name
        }.disposed(by: bag)

        tableView.rx.modelSelected(RouteModel.self).subscribe(onNext: { model in
            let vc = model.controllerType.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: bag)
    }
}
