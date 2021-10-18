//
//  ComposeMessageDataSource.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/16/21.
//

import UIKit
struct Section {
    let letter : String
    let names : [Friend]
}
class IndexedContactDataSource: NSObject {
    var items : [Friend] = Friend.stubList
    var sections = [Section]()
    var filteredItems : [Friend] = []
    var isFiltering : Bool = false
    
    override init() {
        let groupedDictionary = Dictionary(grouping: items, by: {String($0.firstName.prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections = keys.map{ Section(letter: $0, names: groupedDictionary[$0]!) }
    }
    
    func sort
}

extension IndexedContactDataSource : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredItems.count
        }

        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first row when user have not searched for any friend : add new contact
        if indexPath.row == 0 && !isFiltering{
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
            cell.titleLabel.text = "New Contact"
            cell.thumbnail.image = UIImage(named: "NewContact")
            cell.thumbnail.backgroundColor = UIColor.babyBlue
            return cell
        }
        

        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        let friend: Friend
        if isFiltering {
            friend = filteredItems[indexPath.row]
        } else {
            friend = items[indexPath.row - 1]
        }
        cell.configure(model: friend)

        return cell
    }

}
