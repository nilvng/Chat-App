//
//  ViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationListController: UIViewController {
    
    var conversationList : [Conversation] = Conversation.stubList
    var currentSearchText : String = ""

    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.rowHeight = 100
        return table
    }()
    
    var addButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.navigation_button_plus, for: .normal)
        button.sizeToFit()
        button.setImage(UIImage.navigation_button_plus_selected, for: .selected)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 33
        return button
    }()
    
    lazy var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    var searchButton : UIButton = {
        let searchButton = UIButton()
        searchButton.setImage(UIImage.navigation_search, for: .normal)
        searchButton.setImage(UIImage.navigation_search_selected, for: .selected)

        return searchButton
    }()

    
    private lazy var searchController: UISearchController = {
        let resultController =  ResultsTableController()
        let sc = UISearchController(searchResultsController:resultController)
        sc.searchResultsUpdater = resultController
        sc.delegate = self
        sc.searchBar.placeholder = "Search a Friend"
        sc.searchBar.autocapitalizationType = .allCharacters
        
        let scb = sc.searchBar
        scb.searchBarStyle = .minimal
        scb.isTranslucent = false
        scb.tintColor = UIColor.white
        scb.barTintColor = UIColor.white

        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            //textfield.textColor = // Set text color
            if let backgroundview = textfield.subviews.first {

                // Background color
                backgroundview.backgroundColor = UIColor.white

                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;

            }
        }
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
        
        setupAddButton()

        
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
        navigationItem.rightBarButtonItems = [ UIBarButtonItem(customView: searchButton)]
        
        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)

    }
    
    func setupAddButton(){
        blurEffectView.tintColor = .clear
        blurEffectView.contentView.addSubview(addButton)
        view.addSubview(blurEffectView)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            // blurEffect constraints
            blurEffectView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10),
            blurEffectView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -30),
            blurEffectView.heightAnchor.constraint(equalToConstant: 90),
            blurEffectView.widthAnchor.constraint(equalToConstant: 90),
//            // addButton constraints
            addButton.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor, constant: 10),
            addButton.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor, constant: 10),
            addButton.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor, constant: -10),
            addButton.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor, constant: -10),
        ])
        
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)

    }
    
    @objc func addButtonPressed(){
        print("Add Contact...")
        let searchVC = CustomSearchController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func searchButtonPressed(){
        print("Searching...")
        let searchVC = CustomSearchController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
  
    }

}

extension ConversationListController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // navigate to conversation detail view
        let messagesViewController = MessagesViewController()
        messagesViewController.conversation = conversationList[indexPath.row]
        messagesViewController.messageList = conversationList[indexPath.row].messages
        navigationController?.pushViewController(messagesViewController, animated: true)

    }
}

extension ConversationListController : UITableViewDataSource {
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
  extension ConversationListController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        let searchText = (searchController.searchBar.text ?? "")
        self.currentSearchText = searchText
    }
 }

