//
//  File.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/7/21.
//

import UIKit

class ComposeMessageController : UIViewController {

    lazy var searchField : UISearchBar = {
        let bar = UISearchBar()
        return bar
    }()
        
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.rowHeight = 80
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
    
    let items : [Conversation] = Conversation.stubList
    var filteredItems : [Conversation] = []

    var isFiltering: Bool {
      return currentSearchText != ""
    }
    
    func setupSearchField(){
        
        view.addSubview(searchField)
        searchField.delegate = self
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchField.heightAnchor.constraint(equalToConstant: 50)
                                        ])
        searchField.searchTextField.backgroundColor = .white

    }
    
    func setupTableView(){
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)

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

        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            self.filteredItems = self.items.filter { (item: Conversation) -> Bool in
                return item.title.lowercased().contains(key.lowercased())
            }
        }
        tableView.reloadData()
  }
}


