//
//  UserModel.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 07/06/2023.
//

import UIKit
import CoreLocation

struct UserModel {
    
    struct Request {
        var isRefresh: Bool = false
    }
    
    struct Response {
        var users: [User]
        var isRefresh: Bool = false
        var error: (any Error)?
    }
    
    struct ViewModel {
        
        var users: [User]
        var errorMessage: String?
        
        struct User {
            var fullName: String
            var fullNameWithGender: String?
            var mediumImageUrl: String?
            var largeImageUrl: String?
            var userInformation: [UserInformation]
            var coordinates: CLLocationCoordinate2D?
            
            struct UserInformation {
                var icon: UIImage?
                var text: String
                var linkType: LinkType = .none
                
                enum LinkType {
                    case phoneNumber
                    case email
                    case none
                }
            }
        }
    }
}
