//
//  APIWrapperController.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/29.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class APIWrapperController: RxBagController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var setpperValueLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pwdFuekd: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var logLabel: UILabel!
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationSubscribe()
        applicationStateSubscribe()
        
        let segmentValue = BehaviorRelay.init(value: 0)
        segmentControl.rx.value <=> segmentValue
        segmentValue.asObservable()
            .map{ "\($0)" }
            .bind(to: logLabel.rx.text)
            .disposed(by: bag)
        
        let sliderValue = BehaviorRelay.init(value: slider.value)
        slider.rx.value <=> sliderValue
        sliderValue
            .map{ "\($0)" }
            .bind(to: logLabel.rx.text)
            .disposed(by: bag)
        sliderValue
            .bind(to: progress.rx.progress)
            .disposed(by: bag)
        
        let switchValue = BehaviorRelay.init(value: true)
        switchView.rx.value <=> switchValue
        switchValue
            .map{ "\($0 ? "on" : "off")" }
            .bind(to: logLabel.rx.text)
            .disposed(by: bag)
        switchValue
            .bind(to: indicator.rx.isAnimating)
            .disposed(by: bag)
        switchValue
            .map{ !$0 }
            .bind(to: indicator.rx.isHidden)
            .disposed(by: bag)
        
        stepper.stepValue = 1
        let stepperValue = BehaviorRelay<Double>.init(value: 0)
        stepper.rx.value <=> stepperValue
        stepperValue
            .map{"\($0)"}
            .bind(to: setpperValueLabel.rx.text)
            .disposed(by: bag)
        
        button.rx.tap
            .map{ "tapped \($0)" }
            .bind(to: logLabel.rx.text)
            .disposed(by: bag)
        
        let fieldTextValue = BehaviorRelay.init(value: "")
        nameField.rx.textInput <=> fieldTextValue
        fieldTextValue
            .bind(to: logLabel.rx.text)
            .disposed(by: bag)
        
        let pwdValue = BehaviorRelay<String>.init(value: "")
        pwdFuekd.rx.textInput <=> pwdValue
        pwdValue
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { print($0) })
            .disposed(by: bag)
        
        let dateValue = BehaviorRelay.init(value: datePicker.date)
        datePicker.rx.date <=> dateValue
        dateValue
            .map{ $0.format("yyyy-MM-dd HH:mm:ss") }
            .bind(to: logLabel.rx.text)
            .disposed(by: bag)
        
        let attributeTextValue = BehaviorRelay<NSAttributedString?>.init(value: .init())
        textView.rx.attributedText <=> attributeTextValue
        attributeTextValue
            .bind(to: logLabel.rx.attributedText)
            .disposed(by: bag)
        
        location.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.locationManager.requestLocation()
            })
            .disposed(by: bag)
    }
    
    private func locationSubscribe() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.rx.authorizationStatus
            .subscribe(onNext: { state in
                switch state {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("位置权限已获取")
                case .denied:
                    print("位置权限拒绝")
                case .restricted:
                    print("无法使用位置权限")
                case .notDetermined:
                    print("待获取位置权限")
                @unknown default:
                    break
                }
            })
            .disposed(by: bag)
        
        locationManager.rx
            .didUpdateLocations
            .subscribe(onNext: { cl in
                print(cl)
            })
            .disposed(by: bag)
        
        locationManager.rx
            .didFail
            .subscribe(onNext: { print($0.localizedDescription) })
            .disposed(by: bag)
    }
    
    /// 监听程序状态
    private func applicationStateSubscribe() {
        UIApplication.shared.rx
            .willTerminate
            .subscribe(onNext: {_ in
                print("程序被杀掉")
            })
            .disposed(by: bag)
        
        UIApplication.shared.rx
            .willResignActive
            .subscribe(onNext: {_ in
                print("进入非活跃状态")
            })
            .disposed(by: bag)
        
        UIApplication.shared.rx
            .willEnterForeground
            .subscribe(onNext: {_ in
                print("即将进入前台")
            })
            .disposed(by: bag)
        
        UIApplication.shared.rx
            .didEnterBackground
            .subscribe(onNext: {_ in
                print("进入后台")
            })
            .disposed(by: bag)
        
        UIApplication.shared.rx
            .didBecomeActive
            .subscribe(onNext: {_ in
                print("进入活跃状态")
            })
            .disposed(by: bag)
        
        UIApplication.shared.rx
            .states
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: bag)
    }
}
