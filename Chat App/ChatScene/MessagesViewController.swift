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
        
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
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
        setupNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        tableView.addGestureRecognizer(tapGesture)

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        chatBarView.delegate = self

        setupObserveKeyboard()

        edgesForExtendedLayout = []
        tableView.contentSize = CGSize(width: tableView.frame.width, height: tableView.frame.height)
        }
    
    override func loadView() {
        super.loadView()

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
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
                
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)

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
            //chatBarView.heightAnchor.constraint(lessThanOrEqualToConstant: 140),
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
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0
        self.chatBarBottomConstraint.constant = moveUp ? -keyboardFrame.cgRectValue.height : 0
        let inset = tableInset > 0 ? tableInset : 0
        UIView.animate(withDuration: animateDuration, animations: { [weak self] in
            self?.tableView.contentInset.top = moveUp ? scalingValue + inset : inset
            self?.view.layoutIfNeeded()
        }, completion: {  [self]_ in
            if (self.conversation.messages.count) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: .bottom, animated: true)
            }
        })

        
    }
    


    // MARK: Navigation
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unobserveKeyboard()
        
        if action != nil {
            action?(conversation!.messages)
        } else{
            // default action: update chat
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = theme.accentColor
        
        NSLog("Csc appeared")

        
        guard conversation.messages.count > 0 else {return}
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)

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
        let reverseIndex = indexPath.row
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
        let ideaRatio = UIScreen.main.bounds.size.height / 17
        let lag : CGFloat = scrollView.isTracking ? 18 : ideaRatio
        let currentPage = (Int) (scrollView.contentOffset.y / lag)
        
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
extension MessagesViewController : ChatbarDelegate {
    func adjustHeight(amount: CGFloat) {
        print("everyday \(tableView.contentOffset.y) - \(tableInset)")
        
        if (-tableInset != tableView.contentOffset.y){
            DispatchQueue.main.async {
                print(self.tableInset)
                self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableInset), animated: false)
            }
        }
    }
    
    func messageSubmitted(message: String) {
        conversation?.messages.insert((Message.newMessage(content: message)), at: 0)

        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        
        updatesBubble()
    }
}
