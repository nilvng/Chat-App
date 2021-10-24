//
//  Conversation.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

struct Conversation {
    var id = UUID().uuidString
    var title : String
    var thumbnail : String? // url
    var messages : [Message] = []
    var members : [Friend]  = []
    
    init(friend: Friend){
        title = friend.fullName
        thumbnail = friend.avatar
        members.append(friend)
    }
    
    init(title: String, thumbnail: String? = nil, messages: [Message], members: [Friend]) {
        self.title = title
        self.thumbnail = thumbnail
        self.messages = messages
        self.members = members
    }
    
}

extension Conversation : Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool{
        return lhs.id == rhs.id
    }
    static func > (lhs: Conversation, rhs: Conversation) -> Bool{
        // Assume Conversation always has 1 message
        return lhs.messages.last!.timestamp > rhs.messages.last!.timestamp
    }
}

extension Conversation {
    init(friend: Friend, messages: [Message]){
        self.init(friend: friend)
        self.messages = messages
    }

    static let stubList : [Conversation] = [
        Conversation(friend: Friend.john,
              messages: [Message.stub1]),
        .init(friend: Friend.daniel,
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub2,]),
        .init(friend: Friend.angelou,
              messages: [.stub5]
        ),
        .init(friend: Friend.john, messages: [Message.stub1]),
        .init(friend: Friend.daniel,
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4,]),
        .init(title: "My group", messages: [.stub5],
              members: [Friend.angelou])

    ]
}

enum AvatarURL : String{
    case daniel = "https://images.ctfassets.net/aq13lwl6616q/6c2gnlGPDAGGaH0fXFjwtH/e64fdec463625b7912d9867cf1404f2d/Daniel.jpg?w=800&q=50"
    case john = "https://i.ytimg.com/vi/K64XpLVoXTI/maxresdefault.jpg"
    case angelou = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTCbrsbyP-wTfmJVN4K-PLlGIsr954Z_dyA9WrUeRxLvB8eJi7RghXXiyaHDpKG0e5kIo&usqp=CAU"
}
