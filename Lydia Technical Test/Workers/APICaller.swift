//
//  APICaller.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 03/06/2023.
//

import Foundation
import UIKit

class APICaller {
    
    public var isPaginating = false
        
    //TODO: implement image cache (currently using URLSession cache)
    func fetchImage(urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let error {
                    completion(.failure(error))
                    return
                } else if let data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        completion(.success(image))
                    }
                } else {
                    completion(.success(nil))
                }
            }.resume()
        }
        else {
            completion(.success(nil))
        }
    }
    
    func fetchUsers(page: Int, seed: UUID, completion: @escaping (Result<[User], Error>) -> Void) {
        
        guard !isPaginating else { return }
        
        isPaginating = true
        
        let urlString = "https://randomuser.me/api/?page=\(page)&results=10&seed=\(seed)&exc=login"
                
        guard let url = URL(string: urlString) else {
            print("Bad url : \(urlString)")
            return
        }
        print("Api called: \(urlString)")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        
        URLSession(configuration: config).dataTask(with: url) { [weak self] data, response, error in
            
            if let error {
                completion(.failure(error))
            } else if let data {
                do {
                    let apiData = try JSONDecoder().decode(ApiData.self, from: data)
                    completion(.success(apiData.results))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.success([]))
            }
            self?.isPaginating = false
        }.resume()
    }
}
