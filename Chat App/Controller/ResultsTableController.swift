//
//  ResultsTableController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class ResultsTableController: UITableViewController {
    
    let items = Conversation.stubList
    var filteredItems : [Conversation] = []
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        let converation: Conversation
        if isFiltering {
            converation = filteredItems[indexPath.row]
        } else {
            converation = items[indexPath.row]
        }
        cell.configure(model: converation)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        let msgVC = MessagesViewController()
        
        var selected = filteredItems[indexPath.row]

        msgVC.configure(conversation: selected){ messages in
            
            selected.messages = messages
            
            print("update conversation list!!!\n \(messages)")
        }
        
        present(msgVC, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        self.filteredItems = self.items.filter { (item: Conversation) -> Bool in
            return item.title.lowercased().contains(key.lowercased())
        }
        tableView.reloadData()
    }
  }
