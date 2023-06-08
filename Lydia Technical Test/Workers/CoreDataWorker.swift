//
//  CoreDataWorker.swift
//  Lydia Technical Test
//
//  Created by Billy Cauchy-Tharin on 07/06/2023.
//

import CoreData

class CoreDataWorker {
    
    let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
    let persistentContainer = CoreDataStack.shared.persistentContainer
    
    func saveUsers(users: [User], shouldOverride: Bool = false) {
        if shouldOverride {
            let batchDelete = NSBatchDeleteRequest(fetchRequest: UserEntity.fetchRequest())
            _ = try? persistentContainer.viewContext.execute(batchDelete)
        }
        for user in users {
            let userEntity = UserEntity(context: persistentContainer.viewContext)
            userEntity.firstName = user.name.first
            userEntity.lastName = user.name.last
            userEntity.email = user.email
            userEntity.cell = user.cell
            userEntity.phone = user.phone
            userEntity.dateOfBirth = user.dob.date
            userEntity.gender = user.gender
            userEntity.largePictureUrl = user.picture.large
            userEntity.mediumPicutreUrl = user.picture.medium
            userEntity.nationality = user.nat
            userEntity.streetName = user.location.street.name
            userEntity.streetNumber = Int32(user.location.street.number)
            userEntity.city = user.location.city
            userEntity.state = user.location.state
            userEntity.country = user.location.country
            userEntity.postcode = user.location.postcode
            if let lat = user.location.coordinates.latitude {
                userEntity.latitude = "\(lat)"
            } else {
                userEntity.latitude = nil
            }
            if let long = user.location.coordinates.longitude {
                userEntity.longitude = "\(long)"
            } else {
                userEntity.longitude = nil
            }
            persistentContainer.saveContext()
        }
    }
    
    func getUsers() -> [User]? {
        guard let userEntities = try? persistentContainer.viewContext.fetch(request) else {
            return nil
        }
        
        var newUsers = [User]()
        for userEntity in userEntities {
            let newUser = User(userEntity: userEntity)
            newUsers.append(newUser)
        }
        return newUsers
    }
}
