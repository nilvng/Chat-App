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
    static let stub1 : Message = Message(sender: Friend.me, content: "Today is Tuesday", timestamp: Date())
    static let stub2 : Message = .init(sender: Friend.stubDan, content: "Tomorrow is Wednesday", timestamp: Date())
    static let stub3 : Message = .init(sender: Friend.stubDan, content: "How is goin?", timestamp: Date())
    static let stub4 : Message = .init(sender:Friend.me, content: "Just dance. How about you?", timestamp: Date())
}

struct Friend {
    var firstName : String
    var lastName : String
    
    static var me : Friend = .init(firstName: "It's", lastName: "Me")
    static var stubDan : Friend = .init(firstName: "Daniel", lastName: "Bourke")
}

extension Friend : Equatable {
    static func == (lhs : Friend, rhs: Friend ) -> Bool{
        return lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName
    }
}
