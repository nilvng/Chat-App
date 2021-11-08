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
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        button.layer.shadowOpacity = 1.0
        return button
    }()
    
    lazy var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private lazy var searchController: UISearchController = {
        let resultController =  ConversationSearchResultController()
        let sc = UISearchController(searchResultsController:resultController)
        sc.searchResultsUpdater = resultController
        sc.delegate = self
        sc.searchBar.searchTextField.delegate = self
        sc.definesPresentationContext = true
        sc.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Searching...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.trueLightGray!])
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
                    let itemToDelete = self.dataSource.items[indexPath.row]
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
        dataSource.items = ChatManager.shared.chatList
        let _ = dataSource.sortByLatest()
        
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

        view.addSubview(composeButton)

        composeButton.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            composeButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10),
            composeButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20),
            composeButton.heightAnchor.constraint(equalToConstant: 66),
            composeButton.widthAnchor.constraint(equalToConstant: 66),
        ])
        composeButton.layer.cornerRadius = 33
        composeButton.addTarget(self, action: #selector(composeButtonPressed), for: .touchUpInside)

    }
        
    @objc func composeButtonPressed(){
        print("Compose message...")
        let cmc = ComposeMessageController()
        self.present(cmc, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
        navigationController?.navigationBar.barStyle = .black


        // refresh table if row orders changes due to new messages, etc..
        if dataSource.sortByLatest(){
            tableView.reloadData()
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.zaloBlue

    }

}

extension ConversationListController : ChatManagerDelegate {
    func conversationDeleted(_ item: Conversation) {
        guard let indexToDelete = dataSource.items.firstIndex(where: {$0 == item}) else {
            print("Warning: cannot find conversation to delete")
            return
        }
        // update data source
        dataSource.items.remove(at: indexToDelete)
        // animate
        let pathToDelete = IndexPath(row: indexToDelete, section: 0)
        tableView.deleteRows(at: [pathToDelete], with: .automatic)
    }
    
    func conversationAdded(_ item: Conversation) {
        // update data source
        dataSource.items.insert(item, at: 0)
        // animate
        let path = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [path], with: .automatic)

    }
    
    func conversationUpdated(_ item: Conversation) {
        guard let indexToUpdate = dataSource.items.firstIndex(where: {$0 == item}) else {
            print("Warning: cannot find conversation to update")
            return
        }
        // if the conversation has already on top -> don't animate row
        if indexToUpdate == 0 {
            // update data source
            dataSource.items[indexToUpdate] = item
        } else {
            let indexPath = IndexPath(row: indexToUpdate, section: 0)
            self.dataSource.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)

            
            self.dataSource.items.insert(item, at: 0)
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
        
        var selected = dataSource.items[indexPath.row]
        
        messagesViewController.configure(conversation: selected){ messages in
            
            guard selected.messages != messages else { return }
            print("yes, new message")
            selected.messages = messages

            
            self.dataSource.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)

            
            self.dataSource.items.insert(selected, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
            ChatManager.shared.updateChat(newItem: selected)

        }

        navigationController?.pushViewController(messagesViewController, animated: true)

    }

}
// MARK: - UISearchResult Updating and UISearchControllerDelegate  Extension
  extension ConversationListController: UISearchControllerDelegate, UISearchTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("text field editing..")
        searchController.searchBar.placeholder = ""
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.searchTextField.tintColor = .black
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(UIColor.darkGray))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchController.searchBar.placeholder = "Searching..."
        searchController.searchBar.searchTextField.backgroundColor = UIColor.zaloBlue
        searchController.searchBar.setLeftIcon(UIImage.navigation_search_selected!.withTintColor(.white))
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
