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
        table.rowHeight = 86
        return table
    }()
    
    var addButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.navigation_button_plus, for: .normal)
        button.sizeToFit()
        button.setImage(UIImage.navigation_button_plus_selected, for: .selected)
        button.backgroundColor = UIColor.complementZaloBlue
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
        sc.searchBar.searchTextField.delegate = self
        
        sc.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search a Friend", attributes: [NSAttributedString.Key.foregroundColor : UIColor.trueLightGray!])

        return sc
    }()
    
    func changePlaceholderColor(_ color : UIColor){
//        guard let sbTextFieldLabel : AnyClass = NSClassFromString("UISearchBarTextFieldLabel"),
//              let field = searchController.searchBar.searchTextField else{
//            return
//        }
//
//        for subview in field.subviews where subview.isKind(of: sbTextFieldLabel){
//            (subview as! UILabel).textColor = color
//        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
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
        
//        navigationItem.rightBarButtonItems = [ UIBarButtonItem(customView: searchButton)]
//
//        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)

    }
    
    func setupTableView(){
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
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
            blurEffectView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20),
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("view did appear...")
 
        navigationController?.navigationBar.barStyle = .black

        searchController.searchBar.searchTextField.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.zaloBlue
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(.white))
        
    }

}

extension ConversationListController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // navigate to conversation detail view
        let messagesViewController = MessagesViewController()
        
        var selected = conversationList[indexPath.row]
        
        messagesViewController.configure(conversation: selected){ messages in
            
            selected.messages = messages
            
            self.conversationList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)

            
            self.conversationList.insert(selected, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)

        }

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
  extension ConversationListController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("text field editing..")
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.searchTextField.tintColor = .black
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(UIColor.darkGray))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchController.searchBar.searchTextField.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.zaloBlue
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(.white))

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        let searchText = (searchController.searchBar.text ?? "")
        self.currentSearchText = searchText
    }
 }

extension UISearchBar {
    func setLeftIcon(_ image : UIImage){
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        searchTextField.leftView = imageView
    }
}
