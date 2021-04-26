//
//  GithubDefaultAPI.swift
//  RxDemos
//
//  Created by miaokii on 2021/4/26.
//

import Foundation
import RxSwift

class GithubDefaultAPI: GitHubAPI {
    let urlSession: URLSession!
    static let share = GithubDefaultAPI(
        session: URLSession.shared
    )
    
    init(session: URLSession) {
        urlSession = session
    }
    
    func nameValiable(_ name: String) -> Observable<Bool> {
        let url = URL.init(string: "https://github.com/\(name.URLEscaped)")!
        return urlSession.rx.response(request: URLRequest.init(url: url))
            .map{ $0.response.statusCode == 200 }
            .catchAndReturn(false)
    }
    
    func signup(name: String, pwd: String) -> Observable<Bool> {
        let signupResule = arc4random()%3 == 0
        return Observable.just(signupResule)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}

extension String {
    var URLEscaped: String {
       return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
