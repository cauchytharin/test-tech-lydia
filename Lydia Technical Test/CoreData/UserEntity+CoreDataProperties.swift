//
//  UserEntity+CoreDataProperties.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 06/06/2023.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var email: String
    @NSManaged public var firstName: String
    @NSManaged public var gender: String
    @NSManaged public var largePictureUrl: String
    @NSManaged public var lastName: String
    @NSManaged public var mediumPicutreUrl: String
    @NSManaged public var nationality: String
    @NSManaged public var streetNumber: Int32
    @NSManaged public var streetName: String
    @NSManaged public var city: String
    @NSManaged public var state: String
    @NSManaged public var country: String
    @NSManaged public var postcode: String
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var dateOfBirth: String
    @NSManaged public var cell: String
    @NSManaged public var phone: String

}

extension UserEntity : Identifiable {

}
