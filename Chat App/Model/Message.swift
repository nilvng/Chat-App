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
    static let stub2 : Message = .init(sender: Friend.daniel, content: "Tomorrow is Wednesday. ",
                                       timestamp: "2021-08-23 08:10:01".toDate()!)
    static let stub3 : Message = .init(sender: Friend.daniel, content: "How is goin?",
                                       timestamp: "2021-09-29 12:10:01".toDate()!)
    static let stub4 : Message = .init(sender:Friend.me, content: "Just dance. How about you? This just a long long message, do you see how long it is? Almost there, almost finish",
                                       timestamp: "2021-09-30 15:10:01".toDate()!)
    static let stub5 : Message = .init(sender:Friend.me,
                                       content: "Today is Friday and I'm feeling awesome. Able to get stuff done and excied to do even more",
                                           timestamp: "2021-11-12 11:10:01".toDate()!)
    static let stub6 : Message = .init(sender:Friend.me,
                                       content: "Just keep swimming",
                                           timestamp: "2021-11-12 11:10:01".toDate()!)
    static let stub7 : Message = .init(sender:Friend.me,
                                       content: "Bless my laptop. You rock!",
                                           timestamp: "2021-11-12 11:10:01".toDate()!)
    static let stub8 : Message = Message(sender: Friend.angelou, content: "Let them know how much you care",
                                         timestamp: "2021-09-30 14:10:01".toDate()!)
    
    static let myOnly = [stub1, stub4, stub5, stub6, stub7]
}

extension Message : Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool{
        return lhs.sender == rhs.sender &&
            lhs.content == rhs.content &&
            lhs.timestamp == rhs.timestamp
    }
}


