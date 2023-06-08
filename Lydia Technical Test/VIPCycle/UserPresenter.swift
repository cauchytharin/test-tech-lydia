//
//  UserPresenter.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 07/06/2023.
//

import Foundation
import CoreLocation
import UIKit
import Contacts

protocol UserPresentationLogic {
    
    func presentUsers(response: UserModel.Response)
}

class UserPresenter: UserPresentationLogic {
    
    weak var viewController: UserDisplayLogic?
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    let addressFormatter: CNPostalAddressFormatter = {
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        return formatter
    }()
    
    func presentUsers(response: UserModel.Response) {
        let newUsers = getPreparedUsers(users: response.users)
        
        if let error = response.error {
            var errorMessage = error.localizedDescription
            if newUsers.count != 0 {
                errorMessage.append("\nLoaded last results.")
            }
            viewController?.presentError(viewModel: .init(users: newUsers,
                                                          errorMessage: errorMessage))
        } else {
            if response.isRefresh {
                viewController?.loadNewUsers(viewModel: .init(users: newUsers))
            } else {
                viewController?.appendUsers(viewModel: .init(users: newUsers))
            }
        }
    }
    
    func getPreparedUsers(users: [User]) -> [UserModel.ViewModel.User] {
        var newUsers = [UserModel.ViewModel.User]()
        for user in users {
            newUsers.append(prepareUser(user: user))
        }
        return newUsers
    }
    
    func prepareUser(user: User) -> UserModel.ViewModel.User {
        let fullName = "\(user.name.first) \(user.name.last)"
        
        return UserModel.ViewModel.User(
            fullName: fullName,
            fullNameWithGender: getFullNameWithGender(user: user),
            mediumImageUrl: user.picture.medium,
            largeImageUrl: user.picture.large,
            userInformation: getUserInformation(user: user),
            coordinates: getCoordinates(user: user))
    }
    
    func getFullNameWithGender(user: User) -> String? {
        var nameString = "\(user.name.first) \(user.name.last)"
        if user.gender == "male" {
            nameString.append(" ♂")
            return nameString
        } else if user.gender == "female" {
            nameString.append(" ♀")
            return nameString
        } else {
            return nil
        }
    }
    
    func getUserInformation(user: User) -> [UserModel.ViewModel.User.UserInformation] {
        var userInformation = [UserModel.ViewModel.User.UserInformation]()
        userInformation.append(.init(
            icon: UIImage(systemName: "flag.fill"),
            text: getNationalityStringWithFlag(user: user))
        )
        userInformation.append(.init(
            icon: UIImage(systemName: "at"),
            text: user.email,
            linkType: .email)
        )
        userInformation.append(.init(
            icon: UIImage(systemName: "phone.fill"),
            text: user.phone,
            linkType: .phoneNumber)
        )
        userInformation.append(.init(
            icon: UIImage(systemName: "iphone"),
            text: user.cell,
            linkType: .phoneNumber)
        )
        userInformation.append(.init(
            icon: UIImage(systemName: "birthday.cake.fill"),
            text: getDateOfBirthString(user: user))
        )
        userInformation.append(.init(
            icon: UIImage(systemName: "house.fill"),
            text: getAddressString(user: user))
        )
        
        return userInformation
    }
    
    func getNationalityStringWithFlag(user: User) -> String {
        let current = Locale(identifier: "en_US")
        let string = current.localizedString(forRegionCode: user.nat) ?? user.nat
        if let flag = getFlag(country: user.nat) {
            return "\(string) \(flag)"
        } else {
            return string
        }
    }
    
    func getFlag(country: String) -> String? {
        let base : UInt32 = 127397
        var flagString = ""
        for character in country.unicodeScalars {
            if let newCharacter = UnicodeScalar(base + character.value) {
                flagString.unicodeScalars.append(newCharacter)
            } else {
                return nil
            }
        }
        return String(flagString)
    }
    
    func getDateOfBirthString(user: User) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: user.dob.date) {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        } else {
            return user.dob.date
        }
    }
    
    func getAddressString(user: User) -> String {
        let address = CNMutablePostalAddress()
        address.street = "\(user.location.street.number) \(user.location.street.name)"
        address.city = user.location.city
        address.state = user.location.state
        address.postalCode = user.location.postcode
        address.country = user.location.country
        
        return addressFormatter.string(from: address)
    }
    
    func getCoordinates(user: User) -> CLLocationCoordinate2D? {
        if let lat = user.location.coordinates.latitude,
           let long = user.location.coordinates.longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
}
