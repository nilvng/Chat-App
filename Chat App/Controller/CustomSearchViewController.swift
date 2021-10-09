//
//  SearchViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class CustomSearchController : UITableViewController {

    
    lazy var searchField : UITextField = {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 320, height: 70))
        field.backgroundColor = .white
        field.tintColor = .black
        field.borderStyle = .roundedRect
        field.placeholder = "Search"
        return field
    }()
        
    var currentSearchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = searchField        
        
        searchField.delegate = self
        
        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)
        tableView.rowHeight = 80

        filteredItems = items

        tableView.separatorStyle  = .none
    }
    
    let items : [Conversation] = Conversation.stubList
    var filteredItems : [Conversation] = []

    var isFiltering: Bool {
      return currentSearchText != ""
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        let msgVC = MessagesViewController()
        
        var selected = filteredItems[indexPath.row]

        msgVC.configure(conversation: selected){ messages in
            
            selected.messages = messages
            
            print("update conversation list!!!\n \(messages)")
        }

        navigationController?.pushViewController(msgVC, animated: true)
    }

}

extension CustomSearchController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let text = textField.text, text != "" else {
            return
        }
        let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        filterItemForSearchKey(trimText)

    }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // only update when it truly changes
            if cleanText != originalText{
                
                print("search \(cleanText)")
                
                filterItemForSearchKey(cleanText)
            }
        }
        return true
    }
    
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
      self.filteredItems = self.items.filter { (item: Conversation) -> Bool in
          return item.title.lowercased().contains(key.lowercased())
      }
      tableView.reloadData()
  }
}

