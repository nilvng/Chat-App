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
    
    var searchField : UITextField = {
        let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        textfield.placeholder = "search..."
        textfield.textColor = .white

        return textfield
    }()
    
    var xbutton : UIBarButtonItem?
    
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
        searchField.delegate = self
        navigationItem.titleView = searchField
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .zaloBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setupNavigationBar(){
        // two navigation icon: search, user preference menu
        let button = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                       style: .plain, target: self, action: #selector(searchButtonPressed))
        let xbtn = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: (#selector(cancelSearchPressed)))
        navigationItem.leftBarButtonItem = button
        xbutton = xbtn

    }
    // MARK: Setup Data source
    func setupTableView(){
        dataSource = ConversationListDataSource()
        dataSource.configure(conversations: ChatManager.shared.chatList)
        let _ = dataSource.sortByLatest()
        
        view.addSubview(tableView)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
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
    fileprivate func clearSearchField() {
        searchField.text = ""
        dataSource.clearSearch()
        tableView.reloadData()
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc func cancelSearchPressed(){
        print("cancel")
        clearSearchField()
    }
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
        searchField.resignFirstResponder()
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

// MARK: Searching
extension ConversationListController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
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
            clearSearchField()
        } else{
            dataSource.filterItemBy(key: key)
            navigationItem.rightBarButtonItem = xbutton
        }
        tableView.reloadData()
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
        dataSource.insertNewItem(item)
        // animate
        let path = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [path], with: .automatic)

    }
    
    func conversationUpdated(_ item: Conversation) {
        guard let indexToUpdate = dataSource.getIndexOfItem(item) else {
            print("Warning: cannot find conversation to update")
            return
        }
        dataSource.updateItem(item, at: indexToUpdate)
        
        // if the conversation has already on top -> don't animate row
        if indexToUpdate > 0 {
            
            let indexPath = IndexPath(row: indexToUpdate, section: 0)
            
            tableView.performBatchUpdates({
                self.dataSource.moveToRecentFrom(index: indexToUpdate)
                self.tableView.deleteRows(at: [indexPath], with: .none)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }, completion: nil)

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
        
        var selected = dataSource.getItem(at: indexPath)
        
        messagesViewController.configure(conversation: selected){ messages in
            
            guard selected.messages != messages else { return }
            print("yes, new message")
            selected.messages = messages

            ChatManager.shared.updateChat(newItem: selected)

        }
        NSLog("Open csc")
        navigationController?.pushViewController(messagesViewController, animated: true)

    }
    
    // MARK: Animate Compose btn
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        var goingUp: Bool
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        /// `Velocity` is 0 when user is not dragging.
        if (velocity == 0){
            goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        } else {
            goingUp = velocity < 0
        }
        
        if goingUp && composeButton.alpha > 0 {
            composeButton.fadeOut(duration: 0.2, delay: 0)
        } else {
            composeButton.fadeIn(duration: 0.2, delay: 0)
        }
    }
    
}
extension UIView {

  func fadeIn(duration: TimeInterval = 0.5,
              delay: TimeInterval = 0.0,
              completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
    UIView.animate(withDuration: duration,
                   delay: delay,
                   options: UIView.AnimationOptions.curveEaseOut,
                   animations: {
      self.alpha = 1.0
    }, completion: completion)
  }

  func fadeOut(duration: TimeInterval = 0.5,
               delay: TimeInterval = 0.0,
               completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
    UIView.animate(withDuration: duration,
                   delay: delay,
                   options: UIView.AnimationOptions.curveEaseOut,
                   animations: {
      self.alpha = 0.0
    }, completion: completion)
  }
}
