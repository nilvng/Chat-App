//
//  ChatManager.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/16/21.
//

import Foundation

protocol ChatManagerDelegate {
    func conversationDeleted(_ item: Conversation)
    func conversationAdded(_ item: Conversation)
    func conversationUpdated(_ item: Conversation)
}

class ChatManager {
    
    var delegate : ChatManagerDelegate?
    
    var chatList : [Conversation] = Conversation.stubList
    var friendList : [Friend] = Friend.stubList
    
    static let shared = ChatManager()
    
    private init(){}
    
    func addChat(_ item: Conversation){
        print("Manager: add conversation")
        chatList.append(item)
        delegate?.conversationAdded(item)
    }
    
    func getChatIndex(_ item: Conversation) -> Int?{
        return chatList.firstIndex(where: {$0.id == item.id})
    }
    
    func deleteChat(_ item: Conversation){
        print("Manager: delete conversation")
        guard let itemIndexToDelete = getChatIndex(item)else {
            print("Error: delete non exist item")
            return
        }
        
        chatList.remove(at: itemIndexToDelete)
        print("Item is deleted:\(item.title)")
        delegate?.conversationDeleted(item)
    }
    
    func updateChat(newItem: Conversation){
        print("Manager: update conversation")
        guard let itemIndexToUpdate = getChatIndex(newItem)else {
            print("Error: update non exist item")
            return
        }

        chatList[itemIndexToUpdate] = newItem
        delegate?.conversationUpdated(newItem)
    }

}
