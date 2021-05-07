//
//  GithubTrendService.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

enum GithubTrendError: Error {
    case cannotParse
}

class GithubTrendService {
    
    static let share = GithubTrendService.init()
    
    private let session = URLSession.shared
    
    /// 语言列表
    func getLanguageList(completeHandle: @escaping((Result<[String], Error>) -> Void)) {
        let languages = [
            "Swift",
            "Objective-C",
            "Java",
            "C",
            "C++",
            "Python",
            "C#"]
        completeHandle(.success(languages))
    }
    
    func rxGetLanguageList() -> Observable<[String]> {
        let languages = [
            "Swift",
            "Objective-C",
            "Java",
            "C",
            "C++",
            "Python",
            "C#"]
        return Observable.just(languages)
    }
    
    /// 根据语言获取排行
    /// - Parameters:
    ///   - language: 语言
    ///   - completeHandle: 回调
    func getTrend(by language: String, completeHandle: @escaping((Result<[GithubRepo], Error>)->Void)) {
        let urlString = "https://api.github.com/search/repositories?q=language:\(language)&sort=stars"
        let url = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let err = error {
                    completeHandle(.failure(err))
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                      let items = json["items"] as? [[String: Any]] else {
                    completeHandle(.failure(GithubTrendError.cannotParse))
                    return
                }
                // compactMap转换结果中不包括nil
                completeHandle(.success(items.compactMap(GithubRepo.init)))
            }
        }.resume()
    }
    
    func rxGetTrend(by language: String) -> Observable<[GithubRepo]> {
        let urlString = "https://api.github.com/search/repositories?q=language:\(language)&sort=stars"
        let url = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        return session.rx.json(url: url)
            .flatMap { json -> Observable<[GithubRepo]> in
                guard let json = json as? [String: Any],
                      let jsonItems = json["items"] as? [[String: Any]] else {
                    return Observable.error(GithubTrendError.cannotParse)
                }
                return Observable.just(jsonItems.compactMap(GithubRepo.init))
            }
    }
}
