//
//  FriendStore.swift
//  Chat App
//
//  Created by LAP11353 on 02/12/2021.
//

import UIKit
import Contacts
import CoreData

protocol FriendStore {
    func addFriend(_ person : FriendContact)
    func deleteFriend(id : String)
    func updateFriend(_ person: FriendContact)
    func getAll() -> [FriendContact]
    func saveChanges(completion: @escaping (Bool) ->Void)
    func getFriend(id: String) -> FriendContact?
    func contains(id: String) -> Bool
}


