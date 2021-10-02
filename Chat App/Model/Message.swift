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
    static let stub2 : Message = .init(sender: Friend.stubDan, content: "Tomorrow is Wednesday",
                                       timestamp: "2021-08-23 08:10:01".toDate()!)
    static let stub3 : Message = .init(sender: Friend.stubDan, content: "How is goin?",
                                       timestamp: "2021-09-29 12:10:01".toDate()!)
    static let stub4 : Message = .init(sender:Friend.me, content: "Just dance. How about you?",
                                       timestamp: "2021-09-30 15:10:01".toDate()!)
    static let stub5 : Message = Message(sender: Friend.me, content: "let them know how much you care",
                                         timestamp: "2021-09-30 14:10:01".toDate()!)
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


func stringToDate(_ st: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.date(from: st)
}

