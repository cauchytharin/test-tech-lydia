//
//  User.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 03/06/2023.
//

import Foundation
import CoreLocation

struct ApiData: Decodable {
    let results: [User]
}

//FIXME: use optionals

struct User: Decodable {
    
    let gender: String
    let email: String
    let nat: String
    let name: NestedName
    let picture: NestedPicture
    let location: NestedLocation
    let phone: String
    let cell: String
    let dob: NestedDoB
    
    struct NestedName: Decodable {
        let first: String
        let last: String
    }
    
    struct NestedPicture: Decodable {
        let large: String
        let medium: String
        let thumbnail: String?
    }
    
    struct NestedDoB: Decodable {
        let date: String
    }
    
    struct NestedLocation: Decodable {
        internal init(street: User.NestedStreet, city: String, state: String, country: String, postcode: String, coordinates: User.NestedCoordinates) {
            self.street = street
            self.city = city
            self.state = state
            self.country = country
            self.postcode = postcode
            self.coordinates = coordinates
        }
        
        let street: NestedStreet
        let city: String
        let state: String
        let country: String
        var postcode: String
        let coordinates: NestedCoordinates
        
        enum CodingKeys: CodingKey {
            case street
            case city
            case state
            case country
            case postcode
            case coordinates
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<User.NestedLocation.CodingKeys> = try decoder.container(keyedBy: User.NestedLocation.CodingKeys.self)
            
            self.street = try container.decode(User.NestedStreet.self, forKey: User.NestedLocation.CodingKeys.street)
            self.city = try container.decode(String.self, forKey: User.NestedLocation.CodingKeys.city)
            self.state = try container.decode(String.self, forKey: User.NestedLocation.CodingKeys.state)
            self.country = try container.decode(String.self, forKey: User.NestedLocation.CodingKeys.country)
            self.postcode = try {
                if let postcode = try? container.decode(String.self, forKey: User.NestedLocation.CodingKeys.postcode) {
                    return postcode
                } else {
                    let postcodeNumber = try container.decode(Int.self, forKey: User.NestedLocation.CodingKeys.postcode)
                    return "\(postcodeNumber)"
                }
            }()
            self.coordinates = try container.decode(User.NestedCoordinates.self, forKey: User.NestedLocation.CodingKeys.coordinates)
        }
    }
    
    struct NestedStreet: Decodable {
        let number: Int
        let name: String
    }
    
    struct NestedCoordinates: Decodable {
        internal init(latitude: Double? = nil, longitude: Double? = nil) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        let latitude: Double?
        let longitude: Double?
        
        enum CodingKeys: CodingKey {
            case latitude
            case longitude
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<User.NestedCoordinates.CodingKeys> = try decoder.container(keyedBy: User.NestedCoordinates.CodingKeys.self)
            
            let latString = try container.decode(String.self, forKey: User.NestedCoordinates.CodingKeys.latitude)
            let longString = try container.decode(String.self, forKey: User.NestedCoordinates.CodingKeys.longitude)
            self.latitude = Double(latString)
            self.longitude = Double(longString)
        }
    }
    
    init(userEntity: UserEntity) {
        self.email = userEntity.email
        self.gender = userEntity.gender
        self.name = .init(first: userEntity.firstName,
                          last: userEntity.lastName)
        self.nat = userEntity.nationality
        self.picture = .init(
            large: userEntity.largePictureUrl,
            medium: userEntity.mediumPicutreUrl,
            thumbnail: nil
        )
        let street = NestedStreet(
            number: Int(userEntity.streetNumber),
            name: userEntity.streetName
        )
        var coordinates = NestedCoordinates(
            latitude: nil,
            longitude: nil
        )
        if let lat = userEntity.latitude,
           let long = userEntity.longitude {
            coordinates = .init(
                latitude: Double(lat),
                longitude: Double(long)
            )
        }
        self.location = .init(
            street: street,
            city: userEntity.city,
            state: userEntity.state,
            country: userEntity.country,
            postcode: userEntity.postcode,
            coordinates: coordinates
        )
        self.cell = userEntity.cell
        self.dob = .init(date: userEntity.dateOfBirth)
        self.phone = userEntity.phone
    }
}
