//
//  Conversation.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

struct Conversation {
    var title : String
    var thumbnail : UIImage?
    var messages : [Message] = []
}

extension Conversation {
    static let stubList : [Conversation] = [
        .init(title: "John Fish", thumbnail: UIImage(named: "stub1"), messages: [Message.stub1]),
        .init(title: "Daniel Bourke", thumbnail: UIImage(named: "stub2"),
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4,]),
        .init(title: "Maya Angelou", thumbnail: UIImage(named: "default"), messages: [Message(sender: Friend.me, content: "let them know how much you care", timestamp: Date())]),
    ]
}
