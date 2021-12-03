//
//  File.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/7/21.
//

import UIKit

protocol SearchItemDataSource : UITableViewDataSource {
    func setupData(friends: [Friend])
    func setupData(friendContacts: [FriendContact])
    func getItem(at index: IndexPath) -> Friend
    func filterItemBy(key: String)
    func clearSearch()
}

class ComposeMsgController : UIViewController {
    
    lazy var searchField : UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search..."
        return bar
    }()
        
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.rowHeight = 75
        tv.separatorStyle = .none
        return tv
    }()
        
    var dataSource : IndexedContactDataSource!
    var currentSearchText : String = ""
    
    var isFiltering: Bool {
      return currentSearchText != ""
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
           
        view.backgroundColor = .white
        setupSearchField()
        setupTableView()
        
        PhonebookManager.shared.delegate = self
        
    }
    func setupSearchField(){
        
        view.addSubview(searchField)
        searchField.delegate = self
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchField.heightAnchor.constraint(equalToConstant: 40)
                                        ])
        //searchField.layer.cornerRadius = 15
        //searchField.layer.masksToBounds = true
        searchField.searchTextField.backgroundColor = .white
        //searchField.layer.borderWidth = 1.0
        //searchField.layer.borderColor = UIColor.zaloBlue?.cgColor
    }
    
    func setupTableView(){
        view.addSubview(tableView)
        

        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewContactCell")


        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 7).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.dataSource = IndexedContactDataSource()
        self.dataSource.setupData(friendContacts: Array(PhonebookManager.shared.getContactList().values))
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.reloadData()
    }
    
    
}

// MARK: TableViewDelegate

extension ComposeMsgController : UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        
        // first row when user have not searched for any friend : add new contact
        if indexPath.section == 0 && !isFiltering{
            print("Navigate to Add Contact view")
            return
        }
        
       // let row = !isFiltering ? indexPath.row - 1 : indexPath.row
        let msgVC = MessagesViewController()
        
        let selectedContact = dataSource.getItem(at: indexPath)
        // Check if the user has chat with the selected friend before
        let currentConversation = Conversation.stubList.first(where: { conv in
            return conv.members.contains(selectedContact)
        })
        // conversation exist
        if let selected = currentConversation {
            msgVC.configure(conversation: selected)
        } else {
        // brand new conversation
            let selected = Conversation(friend: selectedContact)
            msgVC.configure(conversation: selected){ messages in
                if messages != selected.messages{
                    var addedItem = selected
                    addedItem.messages = messages
                    print("New conversation callback: \(selected.id)")
                    ChatManager.shared.addChat(addedItem)
                }
            }
        }
        let presentingVC = self.presentingViewController as? UINavigationController
        presentingVC?.pushViewController(msgVC, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
}

extension ComposeMsgController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            dataSource.clearSearch()
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let originalText = searchBar.searchTextField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: text)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("search \(cleanText)")
            // only update when it truly changes
            if cleanText != currentSearchText{
                filterItemForSearchKey(cleanText)
            }
        }
        return true
    }
    
    
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
        if key == ""{
            dataSource.clearSearch()
        } else{
            dataSource.filterItemBy(key: key)
        }
        tableView.reloadData()
  }
}

//MARK: Phonebook Delegate

extension ComposeMsgController: PhonebookManagerDelegate{
    func refreshViewWith(data: [String: FriendContact]){
        // refreshing view only when data has been changed
        if self.dataSource.items.count == 0 {
            DispatchQueue.main.async {
                print("Refresh table.")
                //self.dataSource.items = data.compactMap { $0.value }
                self.tableView.reloadData()
            }
            return

        }
        for e in self.dataSource.items {
            if data[e.uid] == nil {
                
                DispatchQueue.main.async {
                    print("Refresh table.")
                    //self.dataSource.items = data.compactMap { $0.value }
                    self.tableView.reloadData()
                }
                return

                }
            }
        }
    func contactListRefreshed(contacts: [String : FriendContact]) {
        // update with the refreshed contact list
        refreshViewWith(data: contacts)
    }
    func newContactAdded(contact: FriendContact){
 
        DispatchQueue.main.async {
            // update data source
//            self.dataSource.items.append(contact)
//            let index = self.dataSource.items.count - 1 // add new contact to the end of list
//            let indexPath = IndexPath(row: index, section: 0)
//            // refresh table
//            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    func contactDeleted(_ contact: FriendContact){

    }
    func contactUpdated(_ contact: FriendContact){

    }
}
