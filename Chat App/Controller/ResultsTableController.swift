//
//  ResultsTableController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class ResultsTableController: UITableViewController {
    
    let items = Friend.stubList
    var filteredItems : [Friend] = []
    var currentSearchText : String = ""

    var isFiltering: Bool {
      return currentSearchText != ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)
        tableView.separatorStyle  = .none
        tableView.rowHeight = 84
        self.filteredItems = items
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredItems.count
        }

        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first row when user have not searched for any friend : add new contact

        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        let friend: Friend
        if isFiltering {
            friend = filteredItems[indexPath.row]
        } else {
            friend = items[indexPath.row]
        }
        cell.configure(friend: friend)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let msgVC = MessagesViewController()
        let selected = filteredItems[row]
        
        // Check if the user has chat with the selected friend before
        var conversation = Conversation.stubList.first(where: { conv in
            return conv.members.contains(selected)
        }) ?? Conversation(friend: selected)
        
        msgVC.configure(conversation: conversation){ messages in
            if messages != conversation.messages{
                conversation.messages = messages
                print("update conversation list!!!\n \(messages)")
            }
        }
        let navigationVC = UINavigationController(rootViewController: msgVC)
        self.present(navigationVC, animated: true, completion: nil) // NOT DONE
    }

}
// MARK: - UISearchResult Updating and UISearchControllerDelegate  Extension
  extension ResultsTableController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        let searchText = (searchController.searchBar.text ?? "")
        
        filterItemForSearchKey(searchText)
    
    }
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
        if key == ""{
            self.filteredItems = self.items
        } else{
            self.filteredItems = self.items.filter { item in
                return item.fullName.lowercased().contains(key.lowercased())
            }
        }
        tableView.reloadData()
  }
  }
