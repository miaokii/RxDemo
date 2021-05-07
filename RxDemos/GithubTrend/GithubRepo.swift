//
//  GithubRepo.swift
//  RxDemos
//
//  Created by miaokii on 2021/5/7.
//

import UIKit

struct GithubRepo {
    let fullName: String
    let description: String
    let starsCount: Int
    let url: String
}

extension GithubRepo {
    init?(from json: [String: Any]) {
        guard
            let fullName = json["full_name"] as? String,
            let description = json["description"] as? String,
            let starsCount = json["stargazers_count"] as? Int,
            let url = json["html_url"] as? String
        else { return nil }

        self.init(fullName: fullName, description: description, starsCount: starsCount, url: url)
    }
}
