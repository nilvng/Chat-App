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
}

extension Conversation : Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool{
        return lhs.id == rhs.id
    }
}

extension Conversation {
    static let stubList : [Conversation] = [
        .init(title: "John Fish", thumbnail: URL(string: "https://flic.kr/p/Ly28LR"), messages: [Message.stub1]),
        .init(title: "Daniel Bourke", thumbnail: URL(string: "https://images.ctfassets.net/aq13lwl6616q/6c2gnlGPDAGGaH0fXFjwtH/e64fdec463625b7912d9867cf1404f2d/Daniel.jpg?w=800&q=50"),
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub2,]),
        .init(title: "Maya Angelou", thumbnail:URL(string: "https://flic.kr/p/gdim7T"), messages: [.stub5]),
        .init(title: "John Fish", thumbnail:  URL(string: "https://flic.kr/p/Ly28LR"), messages: [Message.stub1]),
        .init(title: "Daniel Bourke", thumbnail: URL(string: "https://flic.kr/p/2m734Nn"),
              messages: [ Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4, Message.stub1, Message.stub2, Message.stub3, Message.stub4,]),
        .init(title: "Maya Angelou", messages: [.stub5]),

    ]
}
