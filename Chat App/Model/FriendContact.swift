//
//  Friend.swift
//  Chat App
//  Created by Nil Nguyen on 8/24/21.
//

import Contacts
import UIKit
import CoreData

struct FriendContact{
    
    var uid : String
    var firstName: String
    var lastName: String
    var phoneNumbers: [String]
    var avatarData: Data?

    var source: CNContact? {
        didSet{
            // uid and avatar have to comply native source
            guard let s = source else { return }
            self.uid = s.identifier
            if let photoData = s.imageData {
                self.avatarData = photoData
            }
        }
    }

    init() {
        uid = UUID().uuidString
        firstName = ""
        lastName = ""
        phoneNumbers = []
    }
    
    init(firstName: String, lastName: String, phoneNumbers: [String]){
        self.uid = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumbers = phoneNumbers

    }
    
    func getPhoneNumber(index: Int) -> String{
        guard index > -1 else {
            print("Warning: access phone number out of range.")
            return ""
        }
        guard  phoneNumbers.count > index else {
            return ""
        }
        return phoneNumbers[index]
    }
    
    mutating func setPhoneNumber(_ value :String ,at index: Int) {
        if phoneNumbers.count <= index {
            phoneNumbers.append(value)
        } else {
            phoneNumbers[index] = value
        }
    }
}

extension FriendContact{
        
    init(contact: CNContact) {
        self.init()
        self.uid            = contact.identifier
        self.firstName      = contact.givenName
        self.lastName       = contact.familyName
        self.source         = contact
        self.avatarData     = contact.imageData
        self.phoneNumbers   = contact.phoneNumbers.compactMap { $0.value.stringValue}
    }

    
    func toCNContact() -> CNContact {
        if let storedContact = source{
            return storedContact
        }
        // in case when there a contact is not in native App
        return toMutableContact() as CNContact
    }
    
    func toMutableContact() -> CNMutableContact {
        let contactObj : CNMutableContact
        if let source = source {
            contactObj = source.mutableCopy() as! CNMutableContact
        } else{
            contactObj = CNMutableContact()
        }

        contactObj.givenName = firstName
        contactObj.familyName = lastName

        contactObj.phoneNumbers = phoneNumbers.map {
            return CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: $0))}
        return contactObj

    }
}

extension FriendContact : Equatable {
    static func == (lhs: FriendContact, rhs: FriendContact) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.phoneNumbers == rhs.phoneNumbers &&
            lhs.source == rhs.source
    }
    
    static func != (lhs: FriendContact, rhs: CNContact) -> Bool {
        return !(lhs.uid == rhs.identifier &&
            lhs.firstName == rhs.givenName &&
            lhs.lastName == rhs.familyName &&
            lhs.phoneNumbers == rhs.phoneNumbers.compactMap { $0.value.stringValue})
    }
}

extension FriendContact : CustomStringConvertible {
    var description: String{
        "\(uid); \(firstName) \(lastName); \(phoneNumbers)"
    }
}
