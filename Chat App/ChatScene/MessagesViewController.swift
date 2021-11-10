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
    
    var actionDelegate : MessageChangedAction?
    var conversation : Conversation!
    var theme : Theme = .earthy
    var mode : accentColorMode = .light
    
    var chatTitleLabel : UILabel!

    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        return table
    }()
    
    var backgroundImageView : UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    
    var chatBarView : ChatbarView!
    
    var chatBarBottomConstraint : NSLayoutConstraint?

    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(conversation: Conversation, action : MessageChangedAction? = nil){
        self.conversation = conversation
        self.actionDelegate = action
        
        // configure the theme of chat window
        backgroundImageView.image = theme.backgroundImage
        backgroundImageView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.backgroundView = backgroundImageView

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                     
        setupNavigationBar()
        setupTableView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        tableView.addGestureRecognizer(tapGesture)
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceVertical = false


        setupChatbarView()
        setupObserveKeyboard()
        
 
    }
    
    func setupObserveKeyboard(){
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardDidShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillHideNotification, object: nil)
    
}
    
    var menuButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chat_menu, for: .normal)
        return button
    }()
    
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
    
    func setupTableView(){
        

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        //tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

    }
    
    func setupChatbarView(){
        chatBarView = ChatbarView()
        chatBarView.delegate = self
        
        view.addSubview(chatBarView)
        chatBarView.translatesAutoresizingMaskIntoConstraints = false

        let margin = view.safeAreaLayoutGuide
        chatBarBottomConstraint = chatBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            chatBarView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            chatBarView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            chatBarBottomConstraint!,
            chatBarView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ])
        
        chatBarView.configure(accent: theme.accentColor)


    }
    
    
    @objc func handleKeyboardMoving(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue? else {
            return
        }
        let moveUp = notification.name == UIResponder.keyboardDidShowNotification
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.keyboardMoved(keyboardFrame: keyboardFrame, moveUp: moveUp, animateDuration: animateDuration)
        
    }
    
    func unobserveKeyboard(){
        NotificationCenter.default.removeObserver(self)

    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unobserveKeyboard()
        actionDelegate?(conversation!.messages)
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
        updatesBubble()
    }
    
    @objc func menuButtonPressed(){
        let menuViewController = MessagesMenuViewController()
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
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let lag : CGFloat = scrollView.isTracking ? 23 : 53
        
        let currentPage = (Int) (scrollView.contentOffset.y / lag);
        if (currentPage != lastPage){
            lastPage = currentPage
            self.updatesBubble()
        }
    }
    
    func updatesBubble(){
        
        DispatchQueue.main.async {
        guard let indices = self.tableView.indexPathsForVisibleRows else {
            print("no cell!")
            return
        }
                    
        for i in indices{
            guard let cell = self.tableView.cellForRow(at: i) as? MessageCell else{
                print("no cell for that index")
                return
            }

            let pos = self.tableView.rectForRow(at: i)
            let relativePos = self.tableView.convert(pos, to: self.tableView.superview)
            
            cell.updateGradient(currentFrame: relativePos, theme: self.theme)
        }
        }
    }
    
}

extension MessagesViewController : ChatBarDelegate {
    func keyboardMoved(keyboardFrame: NSValue, moveUp: Bool, animateDuration: Double) {
        print(keyboardFrame.cgRectValue.height)
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0

        chatBarBottomConstraint?.constant = -scalingValue
        
        UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.contentInset.top = moveUp ? scalingValue + 23 : 25 // TODO: hardcoded!!!
            self.view.layoutIfNeeded()
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
