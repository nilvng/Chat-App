//
//  ConversationListDataSource.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/13/21.
//

import UIKit
class ConversationListDataSource :NSObject {
    
    var items : [Conversation]!

    var filteredItems : [Conversation] = []

    var isFiltering: Bool = false
    
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
    
    func moveToRecentFrom(index: Int){
        let item = items[index]
        var i = index - 1
        while i > 0 {
            items[i+1] = items[i]
            i -= 1
        }
        items[i] = item
    }
    
    func configure(conversations: [Conversation]){
        items = conversations
        filteredItems = conversations
    }
}
// MARK: Searching
extension ConversationListDataSource{
    func updateItem(_ item: Conversation, at i: Int){
        filteredItems[i] = item
        print("update in filtered at\(i)")
        guard let iOfItems = items.firstIndex(where: { $0.id == item.id}) else {
            print("Conflict updateItem: filter != items")
            return
        }
        print("update in items at\(iOfItems)")
        items[iOfItems] = item
    }
    
    func insertNewItem(_ item: Conversation){
        items.insert(item, at: 0)
        if !isFiltering {
            let index : Int = 0 // WARNING: [TBD] Insert new item may contains search key
            print("insert to filterec")
            filteredItems.insert(item, at: index)
        }
    }
    
    func getIndexOfItem(_ item: Conversation) -> Int? {
        let i = filteredItems.firstIndex(where: { $0.id == item.id})
        return i
    }
    
    func getItem(at index: IndexPath) -> Conversation{
        return filteredItems[index.row]
    }
    
    func filterItemBy(key: String){
        guard key != "" else {
            self.clearSearch()
            return
        }
        isFiltering = true
        self.filteredItems = self.items.filter { item in
            return item.title.lowercased().contains(key.lowercased())
        }
        
        }
    
    func clearSearch(){
        print("clear search.")
        isFiltering = false
        filteredItems = items
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
