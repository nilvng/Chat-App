//
//  ResultsTableController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class ConversationSearchResultController: UITableViewController {
    
    var items = Conversation.stubList {
        didSet{
            filteredItems = items
        }
    }
    var filteredItems : [Conversation] = []
    var currentSearchText : String = ""

    var isFiltering: Bool {
      return currentSearchText != ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        tableView.separatorStyle  = .none
        tableView.rowHeight = 84
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return filteredItems.count
        }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first row when user have not searched for any friend : add new contact

        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell

        cell.configure(model: filteredItems[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let msgVC = MessagesViewController()
        let conversation = filteredItems[row]
        
        msgVC.configure(conversation: conversation){ messages in
            guard conversation.messages != messages else { return }
            print("yes, new message")
            self.filteredItems[row].messages = messages

            ChatManager.shared.updateChat(newItem: self.filteredItems[row])
        }
        self.presentingViewController?.navigationController?.pushViewController(msgVC, animated: true)
        self.dismiss(animated: false, completion: nil)
//        let navigationVC = UINavigationController(rootViewController: msgVC)
//        self.present(navigationVC, animated: true, completion: nil) // NOT DONE
    }

}
// MARK: - UISearchResult Updating and UISearchControllerDelegate  Extension
  extension ConversationSearchResultController: UISearchResultsUpdating, UISearchControllerDelegate {
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
                return item.title.lowercased().contains(key.lowercased())
            }
        }
        tableView.reloadData()
  }
  }
