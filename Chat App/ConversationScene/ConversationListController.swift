//
//  ViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationListController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: Properties
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
        return button
    }()
    
    lazy var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    

    override func viewDidLoad() {
        super.viewDidLoad()

        ChatManager.shared.delegate = self
        
        setupNavigationBar()
        setupTableView()
        setupComposeButton()
        setupLongPressGesture()
        
    }


    // MARK: AutoLayout setups
    private func setupTitle(){
        let chatTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        chatTitleLabel.textColor  = .white
        chatTitleLabel.font = UIFont.systemFont(ofSize: 25)
        chatTitleLabel.text = "Let's chat"
        navigationItem.titleView = chatTitleLabel
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .zaloBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        //navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupNavigationBar(){
        // two navigation icon: search, user preference menu
        let buttons = [
                       UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                       style: .plain, target: self, action: #selector(searchButtonPressed)),
                       ]
        navigationItem.rightBarButtonItems = buttons
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
        let cmc = ComposeMsgController()
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
    
    // MARK: Actions
    
    @objc func searchButtonPressed(){
        let searchvc = SearchViewController()
        navigationController?.pushViewController(searchvc, animated: true)
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
                print("Long press row: \(indexPath.row)")
                let configView = ConvConfigController()
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
    
    // MARK: Navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTitle()
        }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
}
}

// MARK: ChatManagerDelegate
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

// MARK: Edit Menu Delegate

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

// MARK: TableViewDelegate
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
        NSLog("Open csc")
        navigationController?.pushViewController(messagesViewController, animated: true)

    }

}
