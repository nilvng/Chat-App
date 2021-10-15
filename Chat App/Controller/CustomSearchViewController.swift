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
    
    let items : [Friend] = Friend.stubList
    var filteredItems : [Friend] = []

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        
        // first row when user have not searched for any friend : add new contact
        print(isFiltering)
        if indexPath.row == 0 && !isFiltering{
            print("Navigate to Add Contact view")
            return
        }
        
        let row = !isFiltering ? indexPath.row - 1 : indexPath.row
        
        
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
        let presentingVC = self.presentingViewController as? UINavigationController
        presentingVC?.pushViewController(msgVC, animated: true)
        self.dismiss(animated: false, completion: nil)
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

