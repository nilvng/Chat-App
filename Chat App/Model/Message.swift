//
//  Message.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import Foundation


struct Message {
    var sender : Friend
    var content : String
    var timestamp: Date
    
    static func newMessage(content: String) -> Message {
        return Message(sender: Friend.me, content: content, timestamp: Date())
    }
}

extension Message {
    static let stub1 : Message = Message(sender: Friend.me, content: "Today is Tuesday",
                                         timestamp: "2020-09-30 01:10:01".toDate()!)
    static let stub2 : Message = .init(sender: Friend.daniel, content: "Tomorrow is Wednesday",
                                       timestamp: "2021-08-23 08:10:01".toDate()!)
    static let stub3 : Message = .init(sender: Friend.daniel, content: "How is goin?",
                                       timestamp: "2021-09-29 12:10:01".toDate()!)
    static let stub4 : Message = .init(sender:Friend.me, content: "Just dance. How about you?",
                                       timestamp: "2021-09-30 15:10:01".toDate()!)
    static let stub5 : Message = Message(sender: Friend.me, content: "let them know how much you care",
                                         timestamp: "2021-09-30 14:10:01".toDate()!)
}

extension Message : Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool{
        return lhs.sender == rhs.sender &&
            lhs.content == rhs.content &&
            lhs.timestamp == rhs.timestamp
    }
}

struct Friend {
    var id = UUID().uuidString
    var firstName : String
    var lastName : String
    var avatar : URL?
    var fullName : String {
        get{
            return "\(firstName) \(lastName)"
        }
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
    static var daniel : Friend = .init(firstName: "Daniel", lastName: "Bourke")
    static var john = Friend(firstName: "John", lastName: "Fish")
    static var angelou = Friend(firstName: "Maya", lastName: "Angelou")
    static var steve = Friend(firstName: "Steve", lastName: "Job")
    
    static var stubList = [Friend.daniel, Friend.john, Friend.angelou, Friend.steve]
}
