//
//  ViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationsViewController: UIViewController {
    
    var conversationList : [Conversation] = Conversation.stubList
    var currentSearchText : String = ""

    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .singleLine
        table.rowHeight = 80
        return table
    }()
    
    var addButton : UIButton = {
        let searchButton = UIButton()
        searchButton.setImage(UIImage.navigation_button_plus, for: .normal)
        searchButton.setImage(UIImage.navigation_button_plus_selected, for: .selected)

        return searchButton
    }()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search a Friend"
        sc.searchBar.searchTextField.backgroundColor = .white
        sc.searchBar.backgroundColor = .clear
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
    }

    private func setupNavigationBar(){
        navigationItem.title = "Chats"

        if #available(iOS 11.0, *) {

            self.navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false

        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController.searchBar
            navigationItem.titleView?.layoutSubviews()
        }//
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: addButton)]
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    @objc func addButtonPressed(){
        print("Add Contact...")

    }
}

extension ConversationsViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // navigate to conversation detail view
        let messagesViewController = MessagesViewController()
        messagesViewController.messageList = conversationList[indexPath.row].messages
        messagesViewController.conversation = conversationList[indexPath.row]
        navigationController?.pushViewController(messagesViewController, animated: true)
    }
}

extension ConversationsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.conversationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        
        cell.configure(model: conversationList[indexPath.row])
        return cell
        
    }
    
    
}
// MARK: - UISearchResult Updating and UISearchControllerDelegate  Extension
  extension ConversationsViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        let searchText = (searchController.searchBar.text ?? "")
        self.currentSearchText = searchText
    }
 }

