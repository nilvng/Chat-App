//
//  SearchableItemDataSource.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/21/21.
//

import UIKit

class UnorderedSearchDataSource : NSObject {
    var items: [Friend]! {
        didSet {
            filteredItems = items
        }
    }
    private var filteredItems : [Friend] = []
    
    func getItem(at index: IndexPath) -> Friend{
        return filteredItems[index.row]
    }
}

extension UnorderedSearchDataSource : UITableViewDataSource {
    
    func filterItemBy(key: String){
        guard key != "" else {
            self.clearSearch()
            return
        }
        self.filteredItems = self.items.filter { item in
            return item.fullName.lowercased().contains(key.lowercased())
        }
    }
    
    func clearSearch(){
        filteredItems = items
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        let friend = filteredItems[indexPath.row]
        cell.configure(friend: friend)

        return cell
    }

}
