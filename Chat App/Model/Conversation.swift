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
    
    var theme : Theme = .basic
    
    // new conversation
    init(friend: Friend){
        title = friend.fullName
        thumbnail = friend.avatar
        members.append(friend)
    }
    
    init(title: String, thumbnail: String? = nil, messages: [Message], members: [Friend], theme: Theme = .basic) {
        self.title = title
        self.thumbnail = thumbnail
        self.messages = messages
        self.members = members
        self.theme = theme
    }
    
}

extension Conversation : Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool{
        return lhs.id == rhs.id
    }
    static func > (lhs: Conversation, rhs: Conversation) -> Bool{
        // Assume Conversation always has at least 1 message
        return lhs.messages.first!.timestamp > rhs.messages.first!.timestamp
    }
}

extension Conversation {
    init(friend: Friend, messages: [Message], repeated: Int? = nil, theme: Theme = .basic){
        self.init(friend: friend)
        self.messages = messages
        self.theme = theme
        if repeated != nil {
            generateMsg(amount: repeated!)
        }
    }

    static let stubList : [Conversation] = [
        .init(friend: Friend.john,
              messages: [Message.stub1],
              repeated: 10),
        .init(friend: Friend.daniel,
              messages: [ Message.stub1, Message.stub2, Message.stub3],
              repeated: 20,
              theme: .sunset),
        .init(friend: Friend.angelou,
              messages: [.stub5],
              repeated: 40,
              theme: .earthy
        ),
        .init(friend: Friend.john,
              messages: [Message.stub1],
              repeated: 200,
              theme: Theme.sunset),
        .init(friend: Friend.daniel,
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4,],
              theme: .earthy),
        .init(title: "My group",
              messages: [.stub5],
              members: [Friend.angelou])

    ]
    
    mutating func generateMsg(amount: Int){
        
        messages += Message.myOnly.repeated(count: amount)
    }
}

enum AvatarURL : String{
    case daniel = "https://images.ctfassets.net/aq13lwl6616q/6c2gnlGPDAGGaH0fXFjwtH/e64fdec463625b7912d9867cf1404f2d/Daniel.jpg?w=800&q=50"
    case john = "https://i.ytimg.com/vi/K64XpLVoXTI/maxresdefault.jpg"
    case angelou = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTCbrsbyP-wTfmJVN4K-PLlGIsr954Z_dyA9WrUeRxLvB8eJi7RghXXiyaHDpKG0e5kIo&usqp=CAU"
}

extension Array {

    func repeated(count: Int) -> Array<Element> {
        assert(count > 0, "count must be greater than 0")

        var result : Array<Element> = []
        for _ in 0 ..< count - 1 {
            result += self
        }

        return result
    }

}
