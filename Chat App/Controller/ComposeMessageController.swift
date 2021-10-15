//
//  File.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/7/21.
//

import UIKit

class ComposeMessageController : UIViewController {

    var photoStore = PhotoStore()
    
    lazy var searchField : UISearchBar = {
        let bar = UISearchBar()
        return bar
    }()
        
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.rowHeight = 75
        tv.separatorStyle = .none
        return tv
    }()
        
    var currentSearchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.zaloBlue
        
        setupSearchField()
        setupTableView()
        
        filteredItems = items

    }
    
    let items : [Friend] = Friend.stubList
    var filteredItems : [Friend] = []

    var isFiltering: Bool {
      return currentSearchText != ""
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
        searchField.layer.cornerRadius = 15
        searchField.layer.masksToBounds = true
        searchField.searchTextField.backgroundColor = .white

    }
    
    func setupTableView(){
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewContactCell")


        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 7).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    }
}

extension ComposeMessageController : UITableViewDelegate, UITableViewDataSource{
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        
        // first row when user have not searched for any friend : add new contact
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard indexPath.row > 0 else {
            return
        }
        
        let targetRow = indexPath.row - 1
        
        let selected = items[targetRow]
        guard let url = selected.avatar else {
            return
        }
        photoStore.fetchImage(url: url){ res in
            guard let convIndex = self.items.firstIndex(of: selected),
                case let .success(image) = res else {
                    return
            }
            let indexPath = IndexPath(item: convIndex, section: 0)

            // When the request finishes, only update the cell if it's still visible
            if let cell = self.tableView.cellForRow(at: indexPath)
                                                         as? ConversationCell {
                cell.updateAvatar(displaying: image)
            }

        }
    }

}

extension ComposeMessageController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.searchTextField.text, text != "" else {
            return
        }
        let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        filterItemForSearchKey(trimText)

    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let originalText = searchBar.searchTextField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: text)
            
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


