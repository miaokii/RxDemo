//
//  GithubSignViewModel.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

class HomeGithubSignViewModel: NSObject {
    var datas = Observable.just([
        RouteModel.init(name: "MVVM Github Sign", controllerType: MVVMGithubSignController.self),
        RouteModel.init(name: "Driver Github Sign", controllerType: DriverGithubSignController.self)
    ])
}
