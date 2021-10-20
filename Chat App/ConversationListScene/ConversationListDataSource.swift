//
//  ConversationListDataSource.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit
class ConversationListDataSource :NSObject {
    var conversationList : [Conversation] = ChatManager.shared.chatList
    
    // sorting conversation from the latest to oldest
    func reloadDataSource(){
        conversationList.sort(by: {$0 > $1})
    }
}
extension ConversationListDataSource : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.conversationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        
        cell.configure(model: conversationList[indexPath.row])
        return cell
        
    }
}
