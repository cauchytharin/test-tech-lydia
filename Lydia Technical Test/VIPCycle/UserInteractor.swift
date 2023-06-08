//
//  UserInteractor.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 07/06/2023.
//

import Foundation

protocol UserBusinessLogic {
    
    func fetchItems(request: UserModel.Request)
}

class UserInteractor: UserBusinessLogic {
    
    let apiCaller = APICaller()
    let coreDataWorker = CoreDataWorker()
    
    private var currentPage = 1
    private var seed = UUID()
    
    var presenter: UserPresentationLogic?
    
    func fetchItems(request: UserModel.Request) {
        if request.isRefresh {
            currentPage = 1
            seed = UUID()
        }
        apiCaller.fetchUsers(page: currentPage, seed: seed) { [weak self] result in
            if let self {
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.coreDataWorker.saveUsers(users: data, shouldOverride: self.currentPage == 1)
                        self.currentPage += 1
                    }
                    self.presenter?.presentUsers(response: .init(users: data, isRefresh: request.isRefresh))
                case.failure(let error):
                    print("Error while fetching users : \(error)")
                    if let savedUsers = self.coreDataWorker.getUsers() {
                        self.presenter?.presentUsers(response: .init(users: savedUsers,
                                                                     error: error))
                    } else {
                        self.presenter?.presentUsers(response: .init(users: [],
                                                                    error: error))
                    }
                }
            }
        }
    }
}
