//
//  MessagesViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

enum accentColorMode {
    case light
    case dark
}

class MessagesViewController: UIViewController, UITableViewDelegate {

    typealias MessageChangedAction = ([Message]) -> Void
    var action : MessageChangedAction?
    
    // MARK: Properties
    var conversation : Conversation!
    var theme : Theme!
    var mode : accentColorMode = .light
    
    
    // MARK: View Properties
    var chatTitleLabel : UILabel!
    var menuButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chat_menu, for: .normal)
        return button
    }()
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        table.alwaysBounceVertical = false
        return table
    }()
    
    var backgroundImageView : UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    var chatBarView : ChatbarView = {
        return ChatbarView()
    }()
    var chatBarBottomConstraint : NSLayoutConstraint!

    
    // MARK: Configure
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(conversation: Conversation, action : MessageChangedAction? = nil){
        self.conversation = conversation
        self.theme = conversation.theme
        self.action = action
        
        // configure the theme of chat window
        backgroundImageView.image = theme.backgroundImage
        backgroundImageView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.backgroundView = backgroundImageView

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupNavigationBar()
//        setupTableView()
//        setupChatbarView()
//        setupObserveKeyboard()
        setupObserveKeyboard()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        tableView.addGestureRecognizer(tapGesture)
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceVertical = false

        chatBarView.delegate = self

        }
    
    override func loadView() {
        super.loadView()
        setupNavigationBar()
        setupTableView()
        setupChatbarView()
    }
    

    
    // MARK: AutoLayout setups
    
    func setupObserveKeyboard(){
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillHideNotification, object: nil)
    
}
    
    func setupNavigationBar(){
        navigationItem.rightBarButtonItem = nil

        chatTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        chatTitleLabel.textColor  = mode == .light ? UIColor.black : UIColor.white
        chatTitleLabel.font = UIFont.systemFont(ofSize: 19)
        
        navigationItem.titleView = chatTitleLabel
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.chat_menu,
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed))
    }
    
    var tableInset : CGFloat = 100
    
    func setupTableView(){

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.insetsContentViewsToSafeArea = true
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setupChatbarView(){

        
        view.addSubview(chatBarView)
        chatBarView.translatesAutoresizingMaskIntoConstraints = false

        let margin = view.safeAreaLayoutGuide
        chatBarBottomConstraint = chatBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            chatBarView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            chatBarView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            chatBarBottomConstraint!,
            chatBarView.heightAnchor.constraint(lessThanOrEqualToConstant: 140),
            chatBarView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ])
        
        chatBarView.configure(accent: theme.accentColor)


    }
    
    
    @objc func handleKeyboardMoving(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue? else {
            return
        }
        let moveUp = notification.name == UIResponder.keyboardWillShowNotification
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.keyboardMoved(keyboardFrame: keyboardFrame, moveUp: moveUp, animateDuration: animateDuration)
        
    }
    


    // MARK: Navigation
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unobserveKeyboard()
        
        if action != nil {
            action?(conversation!.messages)
        } else{
            ChatManager.shared.updateChat(newItem: conversation)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableInset = chatBarView.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatTitleLabel.text = conversation.title
        navigationController?.navigationBar.barTintColor = .white
        //tableInset = chatBarView.bounds.size.height
        DispatchQueue.main.async {
            print(self.tableInset)
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableInset), animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = theme.accentColor
        
        NSLog("Csc appeared")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    // MARK: Actions
    
    func unobserveKeyboard(){
        NotificationCenter.default.removeObserver(self)

    }
    
    @objc func menuButtonPressed(){
        let menuViewController = MsgMenuController()
        menuViewController.configure(conversation){
            ChatManager.shared.deleteChat(self.conversation)
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(menuViewController, animated: true)
    }
    
    func scrollToLastMessage(animated: Bool = true){

        guard conversation!.messages.count > 0 else {
            return
        }
        DispatchQueue.main.async {
            let lastindex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: lastindex, at: .bottom, animated: animated)
        }
    }

    
    @objc func handleTap(){
        view.endEditing(true)
    }
 
    var lastPage : Int = 0

}

// MARK: TableViewController
extension MessagesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.conversation!.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let reverseIndex = conversation!.messages.count - indexPath.row - 1
        let message =  conversation!.messages[reverseIndex]
        
        var isLastContinuous = true
        
        if reverseIndex + 1 < conversation.messages.count {
            let laterMessage = conversation!.messages[reverseIndex + 1]
            isLastContinuous = laterMessage.sender != message.sender
        }
        
        cell.configure(with: message, lastContinuousMess: isLastContinuous)
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updatesBubble(givenIndices: [indexPath])
        
    }
    
    // MARK: Update bubbles
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // change bubble gradient as scrolling
        //let ideaRatio = UIScreen.main.bounds.size.height / 17
        let ideaRatio : CGFloat = 37
        let lag : CGFloat = scrollView.isTracking ? 23 : ideaRatio
        let currentPage = (Int) (scrollView.contentOffset.y / lag)
        
        print( "table offset \(scrollView.contentOffset.y)")
        if (currentPage != lastPage){
            lastPage = currentPage
            self.updatesBubble()
        }
    }
    
    func updatesBubble(givenIndices: [IndexPath]? = nil){
       var indices = givenIndices
        DispatchQueue.main.async {
            if indices == nil {
                indices = self.tableView.indexPathsForVisibleRows
                guard indices != nil else {
                    print("no cell!")
                    return
                }

            }
            
            for i in indices!{
                guard let cell = self.tableView.cellForRow(at: i) as? MessageCell else{
                    //print("no cell for that index")
                    continue
                }
                
                let pos = self.tableView.rectForRow(at: i)
                let relativePos = self.tableView.convert(pos, to: self.tableView.superview)
                
                cell.updateGradient(currentFrame: relativePos, theme: self.theme)
            }
        }
    }
    
    // MARK: Animate bubbles
}

// MARK: Chatbar Delegate
extension MessagesViewController : ChatBarDelegate {
    func adjustHeight(amount: CGFloat) {
        print("everyday \(chatBarView.frame.height) - \(tableInset)")
        
        if (-tableInset != tableView.contentOffset.y){
            DispatchQueue.main.async {
                print(self.tableInset)
                self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableInset), animated: false)
            }
        }
    }
    
    func keyboardMoved(keyboardFrame: NSValue, moveUp: Bool, animateDuration: Double) {
        print("keyboard height:\(keyboardFrame.cgRectValue.height)")
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0

        chatBarBottomConstraint?.constant = -scalingValue
        
        let inset : CGFloat = self.tableInset
        
        UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.tableView.contentInset.top = moveUp ? scalingValue + inset : inset
            self?.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.scrollToLastMessage()
        })

    }
    
    func messageSubmitted(message: String) {
        conversation?.messages.append(Message.newMessage(content: message))

        tableView.reloadData()
        
        updatesBubble()
    }
}
