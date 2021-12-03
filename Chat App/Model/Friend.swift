//
//  Friend.swift
//  Chat App
//
//  Created by LAP11353 on 02/12/2021.
//

import Foundation
struct Friend {
    var uid = UUID().uuidString
    var firstName : String
    var lastName : String
    var avatar : String?
    var fullName : String {
        get{
            return "\(firstName) \(lastName)"
        }
    }
    
    init(firstName: String, lastName: String, avatar: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
    }
    init(friendContact: FriendContact){
        firstName = friendContact.firstName
        lastName = friendContact.lastName
        uid = friendContact.uid
    }
}

extension Friend : Equatable {
    static func == (lhs : Friend, rhs: Friend ) -> Bool{
        return lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName
    }
}

extension Friend {
    
    static var me : Friend = .init(firstName: "It's", lastName: "Me")
    static var daniel : Friend = .init(firstName: "Daniel", lastName: "Bourke", avatar: AvatarURL.daniel.rawValue)
    static var john = Friend(firstName: "John", lastName: "Fish", avatar: AvatarURL.john.rawValue)
    static var angelou = Friend(firstName: "Maya", lastName: "Angelou", avatar: AvatarURL.angelou.rawValue)
    static var steve = Friend(firstName: "Steve", lastName: "Job")
    
    static var stubList = [Friend.john, Friend.angelou, Friend.steve, Friend.daniel]
}

extension Friend : Searchable{
    func getKeyword() -> String {
        return fullName
    }
}
