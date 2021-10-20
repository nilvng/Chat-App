//
//  ViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationListController: UIViewController, UIGestureRecognizerDelegate {
    
    var currentSearchText : String = ""
    
    var dataSource : ConversationListDataSource!
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.rowHeight = 86
        return table
    }()
    
    var composeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.navigation_button_plus, for: .normal)
        button.setImage(UIImage.navigation_button_plus_selected, for: .selected)
        button.sizeToFit()

        button.backgroundColor = UIColor.complementZaloBlue
        button.layer.cornerRadius = 33

        return button
    }()
    
    lazy var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private lazy var searchController: UISearchController = {
        let resultController =  ResultsTableController()
        let sc = UISearchController(searchResultsController:resultController)
        sc.searchResultsUpdater = resultController
        sc.delegate = self
        sc.searchBar.searchTextField.delegate = self
        
        sc.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search a Friend", attributes: [NSAttributedString.Key.foregroundColor : UIColor.trueLightGray!])

        return sc
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        ChatManager.shared.delegate = self
        
        setupNavigationBar()
        setupTableView()
        setupComposeButton()
        setupLongPressGesture()
        
    }
    
    func setupLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 1.0 // 1 second press
        longPress.delegate = self
        tableView.addGestureRecognizer(longPress)

    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath.row)
                let configView = ConversationConfigViewController()
                configView.configure {
                    let itemToDelete = self.dataSource.conversationList[indexPath.row]
                    ChatManager.shared.deleteChat(itemToDelete)
                }
                configView.modalPresentationStyle = UIModalPresentationStyle.custom
                configView.transitioningDelegate = self
                self.present(configView, animated: true, completion: nil)
            }
        }
    }

    private func setupNavigationBar(){
        navigationItem.title = "Chats"
        navigationItem.backButtonDisplayMode = .minimal

        if #available(iOS 11.0, *) {

            self.navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
   

        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController.searchBar
            navigationItem.titleView?.layoutSubviews()
        }//
    }
    
    func setupTableView(){
        dataSource = ConversationListDataSource()
        dataSource.reloadDataSource()
        
        view.addSubview(tableView)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    }
    
    func setupComposeButton(){

        blurEffectView.tintColor = .clear
        blurEffectView.contentView.addSubview(composeButton)
        view.addSubview(blurEffectView)

        composeButton.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            // blurEffect constraints
            blurEffectView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10),
            blurEffectView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20),
            blurEffectView.heightAnchor.constraint(equalToConstant: 90),
            blurEffectView.widthAnchor.constraint(equalToConstant: 90),
//            // addButton constraints
            composeButton.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor, constant: 10),
            composeButton.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor, constant: 10),
            composeButton.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor, constant: -10),
            composeButton.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor, constant: -10),
        ])
        
        composeButton.addTarget(self, action: #selector(composeButtonPressed), for: .touchUpInside)

    }
        
    @objc func composeButtonPressed(){
        print("Compose message...")
        let cmc = ComposeMessageController()
        self.present(cmc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("view will appear...")
 
        navigationController?.navigationBar.barStyle = .black

        searchController.searchBar.searchTextField.tintColor = .white
        searchController.searchBar.searchTextField.backgroundColor = UIColor.zaloBlue
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(.white))
        
    }

}

extension ConversationListController : ChatManagerDelegate {
    func conversationDeleted(_ item: Conversation) {
        guard let indexToDelete = dataSource.conversationList.firstIndex(where: {$0 == item}) else {
            print("Warning: cannot find conversation to delete")
            return
        }
        // update data source
        dataSource.conversationList.remove(at: indexToDelete)
        // animate
        let pathToDelete = IndexPath(row: indexToDelete, section: 0)
        tableView.deleteRows(at: [pathToDelete], with: .automatic)
    }
    
    func conversationAdded(_ item: Conversation) {
        // update data source
        dataSource.conversationList.insert(item, at: 0)
        // animate
        let path = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [path], with: .automatic)

    }
    
    func conversationUpdated(_ item: Conversation) {
        guard let indexToUpdate = dataSource.conversationList.firstIndex(where: {$0 == item}) else {
            print("Warning: cannot find conversation to update")
            return
        }
        // if the conversation has already on top -> don't animate row
        if indexToUpdate == 0 {
            // update data source
            dataSource.conversationList[indexToUpdate] = item
        } else {
            let indexPath = IndexPath(row: indexToUpdate, section: 0)
            self.dataSource.conversationList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)

            
            self.dataSource.conversationList.insert(item, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
}

extension ConversationListController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}

class HalfSizePresentationController: UIPresentationController {
    let blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return effectView
    }()
    var tapGesture : UITapGestureRecognizer!
    var swipeGesture : UISwipeGestureRecognizer!
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setupTapDismissGesture()
        setupSwipeDismissGesture()
    }
    
    func setupTapDismissGesture(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGesture)
    }
    
    func setupSwipeDismissGesture(){
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.dismiss))
        swipeGesture.direction = .down
        self.presentedView?.addGestureRecognizer(swipeGesture)
    }

    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        print(bounds)
        return CGRect(x: 0, y: bounds.height / 2, width: bounds.width, height: bounds.height / 2)
    }
    
    @objc func dismiss(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView.alpha = 0.4
        }, completion:  nil)
    }
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.layer.masksToBounds = true
        presentedView!.layer.cornerRadius = 10
    }
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }

}

extension ConversationListController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        // navigate to conversation detail view
        let messagesViewController = MessagesViewController()
        
        var selected = dataSource.conversationList[indexPath.row]
        
        messagesViewController.configure(conversation: selected){ messages in
            
            guard selected.messages != messages else { return }
            print("yes, new message")
            selected.messages = messages

            
            self.dataSource.conversationList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)

            
            self.dataSource.conversationList.insert(selected, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
            ChatManager.shared.updateChat(newItem: selected)

        }

        navigationController?.pushViewController(messagesViewController, animated: true)

    }

}
// MARK: - UISearchResult Updating and UISearchControllerDelegate  Extension
  extension ConversationListController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("text field editing..")
        searchController.searchBar.placeholder = ""
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(UIColor.darkGray))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchController.searchBar.placeholder = "Search a Friend"
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
