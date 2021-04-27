//
//  HomeViewModel.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import UIKit
import RxSwift

struct HomeViewModel {
    let data = Observable.just([
        RouteModel.init(name: "Simple Validation", controllerType: SimpleValidController.self),
        RouteModel.init(name: "Github sign", controllerType: GithubSignController.self),
        RouteModel.init(name: "ImagePicker", controllerType: ImagePickerController.self),
        RouteModel.init(name: "Github search", controllerType: DirverObservableController.self),
    ])
}

struct RouteModel {
    var name = ""
    var controllerType = MKViewController.self
}
