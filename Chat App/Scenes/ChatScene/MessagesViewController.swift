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
    
    // Float bubble
    var floatBubble : UILabel = {
        let view = UILabel(frame: CGRect(x: 160, y: 531, width: 100, height: 30))
        view.backgroundColor = .clear
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.sizeToFit()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        return view
    }()
    
    var bbBgView : UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure
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
        setupTableView()
        setupChatbarView()
        setupFloatBb()
        edgesForExtendedLayout = []
        }
    
    override func loadView() {
        super.loadView()

        
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
    
    var tableInset : CGFloat = 30
    
    func setupTableView(){
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
                
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)

    }
    // MARK: setup float bb
    var bbFlyConstraint : NSLayoutConstraint!
    var bbSnapConstraint : NSLayoutConstraint!
    var bbStretchConstraint : NSLayoutConstraint!
    
    func setupFloatBb(){
        
        view.addSubview(bbBgView)
        view.addSubview(floatBubble)
        
        chatBarView.layoutIfNeeded() // layout chat bar so that we can align text field frame with float bb
        
        floatBubble.isHidden = true
        floatBubble.translatesAutoresizingMaskIntoConstraints = false
        bbFlyConstraint = floatBubble.bottomAnchor.constraint(equalTo: chatBarView.bottomAnchor,
                                                              constant: -BubbleConstant.vPadding)
        
        self.bbSnapConstraint = floatBubble.widthAnchor.constraint(lessThanOrEqualToConstant: BubbleConstant.maxWidth)
        self.bbStretchConstraint = floatBubble.widthAnchor.constraint(
            equalToConstant: (chatBarView.textView.frame.size.width + chatBarView.submitButton.frame.width))
        
        let cs : [NSLayoutConstraint] = [
            bbFlyConstraint,
            bbStretchConstraint,
            floatBubble.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -BubbleConstant.hPadding),
            floatBubble.heightAnchor.constraint(greaterThanOrEqualToConstant: 25)

        ]
        
        bbBgView.translatesAutoresizingMaskIntoConstraints = false

        let constraints : [NSLayoutConstraint] = [
            bbBgView.topAnchor.constraint(equalTo: floatBubble.topAnchor,
                                          constant: -BubbleConstant.vPadding + BubbleConstant.contentVPadding + 2),
            bbBgView.leadingAnchor.constraint(equalTo: floatBubble.leadingAnchor,
                                              constant: -BubbleConstant.hPadding + BubbleConstant.contentHPadding),
            bbBgView.bottomAnchor.constraint(equalTo:  floatBubble.bottomAnchor,
                                             constant: BubbleConstant.vPadding - BubbleConstant.contentVPadding - 2),
            bbBgView.trailingAnchor.constraint(equalTo: floatBubble.trailingAnchor,
                                               constant: BubbleConstant.hPadding - BubbleConstant.contentHPadding),
        ] // WEIRD
        NSLayoutConstraint.activate(cs)
        NSLayoutConstraint.activate(constraints)
        
        bbBgView.isHidden = true
        bbBgView.image =  BackgroundFactory.shared.getBackground(config: outgoingBubbleConfig)

    }
    
    func setupChatbarView(){

        view.addSubview(chatBarView)
        chatBarView.translatesAutoresizingMaskIntoConstraints = false

        let margin = view.safeAreaLayoutGuide
        chatBarBottomConstraint = chatBarView.bottomAnchor.constraint(equalTo: margin.bottomAnchor)

        NSLayoutConstraint.activate([
            chatBarView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            chatBarView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            chatBarBottomConstraint!,
            chatBarView.heightAnchor.constraint(lessThanOrEqualToConstant: 140),
            chatBarView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            ])
        chatBarView.configure(accent: theme.accentColor)

    }
    
    // MARK: Handle keyboard
    @objc func handleKeyboardMoving(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?, keyboardFrame.cgRectValue.height > 0 else {
            return
        }
        let moveUp = notification.name == UIResponder.keyboardWillShowNotification
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        print("\(keyboardFrame.cgRectValue.height) height - \(tableInset)")
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0
        self.chatBarBottomConstraint.constant = moveUp ? -keyboardFrame.cgRectValue.height : 0
        let inset = tableInset

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

        tableInset = chatBarView.frame.height + 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatTitleLabel.text = conversation.title
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
    var newMessAnimation : Bool = false
    var outgoingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = .none
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()
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
        
        var isLastContinuous = false
        
        if reverseIndex - 1 >= 0 {
            let laterMessage = conversation!.messages[reverseIndex - 1]
            isLastContinuous = laterMessage.sender != message.sender
        }
        
        if (isLastContinuous){ print("last continuous \(message.content) - \(reverseIndex)")}
        
        cell.configure(with: message, lastContinuousMess: isLastContinuous)
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // update gradient color of visible bubbles
        updatesBubble(givenIndices: [indexPath])
        
        // sent message? -> animate bubble
        guard newMessAnimation else {return;}
        DispatchQueue.main.async {
            self.animateFloatBb()
        }
        newMessAnimation = false
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
    
    // MARK: Animate Bubble
    
    fileprivate func animateFloatBb() {
        // show float bubble
        self.bbBgView.isHidden = false
        self.floatBubble.isHidden = false

        self.view.layoutIfNeeded()

        // animate float bubble
        
        let bbRect = tableView.convert(tableView.rectForRow(at: IndexPath(row: 0, section: 0)), to: self.view)
        // get gradient color
        self.bbBgView.tintColor = theme.gradientImage.getPixelColor(pos: CGPoint(x:100 , y: bbRect.maxY))
                                                      
        UIView.animate(withDuration: 0.26, delay: 0.02, options: .curveEaseOut, animations: { [weak self] in
            // move to cell
            self?.bbFlyConstraint.constant = bbRect.maxY - (self?.floatBubble.frame.maxY ?? 0) - 13
            // shrink
            self?.bbStretchConstraint.isActive = false
            self?.bbSnapConstraint.isActive = true
            self?.view.layoutIfNeeded()
        }, completion: { c in
            print("done animation")

            self.floatBubble.isHidden = true
            self.bbBgView.isHidden = true
            self.bbSnapConstraint.isActive = false
            self.bbStretchConstraint.isActive = true

            self.bbFlyConstraint.constant = -BubbleConstant.contentVPadding
        })
    }
}

// MARK: Chatbar Delegate
extension MessagesViewController : ChatbarDelegate {
    func adjustHeight(amount: CGFloat) {
        print("adjust height")
        if (-tableInset != tableView.contentOffset.y){
            print("scroll table as user typing text")
            DispatchQueue.main.async {
                self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableInset), animated: true)
            }
        }
    }
    
    func messageSubmitted(message: String) {
        print("msg submit")
        
        newMessAnimation = true
        
        conversation?.messages.insert((Message.newMessage(content: message)), at: 0)
        
        floatBubble.text = message

        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        
        updatesBubble()
    }
}
