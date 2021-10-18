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
    var thumbnail : URL? // url
    var messages : [Message] = []
    var members : [Friend]  = []
    
    init(friend: Friend){
        title = friend.fullName
        thumbnail = friend.avatar
        members.append(friend)
    }
    
    init(title: String, thumbnail: URL? = nil, messages: [Message], members: [Friend]) {
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
    static let stubList : [Conversation] = [
        .init(title: "John Fish",
              thumbnail:  URL(string: AvatarURL.john.rawValue),
              messages: [Message.stub1],
              members: [Friend.john]),
        .init(title: "Daniel Bourke", thumbnail: URL(string: AvatarURL.daniel.rawValue),
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub2,],
              members: [Friend.daniel]),
        .init(title: "Maya Angelou",
              thumbnail:URL(string: AvatarURL.angelou.rawValue),
              messages: [.stub5],
              members: [Friend.angelou]
              ),
        .init(title: "John Fish", thumbnail:  URL(string: AvatarURL.john.rawValue), messages: [Message.stub1],
              members: [Friend.john]),
        .init(title: "Daniel Bourke", thumbnail: URL(string: AvatarURL.daniel.rawValue),
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4,],
              members: [Friend.daniel]),
        .init(title: "Maya Angelou", messages: [.stub5],
              members: [Friend.angelou])

    ]
}

enum AvatarURL : String{
    case daniel = "https://images.ctfassets.net/aq13lwl6616q/6c2gnlGPDAGGaH0fXFjwtH/e64fdec463625b7912d9867cf1404f2d/Daniel.jpg?w=800&q=50"
    case john = "https://i.ytimg.com/vi/K64XpLVoXTI/maxresdefault.jpg"
    case angelou = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTCbrsbyP-wTfmJVN4K-PLlGIsr954Z_dyA9WrUeRxLvB8eJi7RghXXiyaHDpKG0e5kIo&usqp=CAU"
}
