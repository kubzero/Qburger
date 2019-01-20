//
//  File.swift
//  Qburger
//
//  Created by Andrew on 20/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
let burgerApi = "https://pplkdijj76.execute-api.eu-west-1.amazonaws.com/prod/recognize"

extension ViewController {
    //MARK: Check image by qminder burger API
    func burgerCheking(linkToCheck:String, completion: @escaping (String?) -> Void) {
        var answer = ""
        guard let url = URL(string: burgerApi) else {return}
        let recognize = Recognize(urls: [linkToCheck])
        let jsonEncoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? jsonEncoder.encode(recognize) else {return }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response else {return}
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200){
                do {
                    print("successfully one burger place found")
                    let jsonRequest = try! JSONDecoder().decode(Responses.self, from: data)
                    answer = jsonRequest.urlWithBurger!
                    completion(answer)
                }}
            if(statusCode == 400){
                do {
                    answer = ""
                    completion(answer)
                }}
            if(statusCode == 404){
                do {
                    answer = ""
                    completion(answer)
                }}}.resume()
    }
}
