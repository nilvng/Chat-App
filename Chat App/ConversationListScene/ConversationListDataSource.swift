//
//  ConversationListDataSource.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit
class ConversationListDataSource :NSObject {
    var items : [Conversation]! = ChatManager.shared.chatList{
        didSet {
            filteredItems = items
        }
    }
    var filteredItems : [Conversation] = []

    // sorting conversation from the latest to oldest
    func sortByLatest() -> Bool{
        var tmp : [Conversation] = items
        tmp.sort(by: {$0 > $1})
        if tmp != items {
            print("List order changes")
            items = tmp
        }
        return tmp != items
    }
}

extension ConversationListDataSource : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        
        cell.configure(model: filteredItems[indexPath.row])
        return cell
        
    }
}
