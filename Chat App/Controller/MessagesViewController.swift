//
//  MessagesViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate {

    typealias MessageChangedAction = ([Message]) -> Void
    
    var actionDelegate : MessageChangedAction?
    
    var conversation : Conversation? {
        didSet{
           navigationItem.title = conversation?.title
        }
    }
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        return table
    }()
    
    var chatBarView : ChatbarView!
    
    var chatBarBottomConstraint : NSLayoutConstraint?
    var incomingBubbleImage : UIImage = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 120))
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0,width: 200, height: 120), cornerRadius: 15)
            UIColor.trueLightGray?.setFill()
            path.fill()
        }
        return im
    }()
    
    var outgoingBubbleImage : UIImage = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 120))
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0,width: 200, height: 120), cornerRadius: 15)
            UIColor.babyBlue?.setFill()
            path.fill()
        }
        return im
    }()


    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(conversation: Conversation, action : MessageChangedAction? = nil){
        self.conversation = conversation
        self.actionDelegate = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        setupTableView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        tableView.addGestureRecognizer(tapGesture)
        
        setupChatbarView()
        
    }
    
    func setupTableView(){
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        tableView.contentInset = UIEdgeInsets(top: 55, left: 0, bottom: 0, right: 0)

    }
    
    func setupChatbarView(){
        chatBarView = ChatbarView()
        chatBarView.delegate = self
        
        view.addSubview(chatBarView)
        chatBarView.translatesAutoresizingMaskIntoConstraints = false

        let margin = view.safeAreaLayoutGuide
        chatBarBottomConstraint = chatBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)

        NSLayoutConstraint.activate([
            chatBarView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            chatBarView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            chatBarBottomConstraint!,
            chatBarView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ])

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
                
        actionDelegate?(conversation!.messages)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        print("tapping..")
        view.endEditing(true)
    }
}


extension MessagesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.conversation!.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let reverseIndex = conversation!.messages.count - indexPath.row - 1
        let message =  conversation!.messages[reverseIndex]
        
        let bubble = message.sender == Friend.me ? outgoingBubbleImage : incomingBubbleImage
        cell.configure(with: message, bubbleImage: bubble)

        cell.transform = CGAffineTransform(scaleX: 1, y: -1)

        
        return cell
        
    }
    
    
}

extension MessagesViewController : ChatBarDelegate {
    func keyboardMoved(keyboardFrame: NSValue, moveUp: Bool, animateDuration: Double) {
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0

        chatBarBottomConstraint?.constant = -scalingValue
        
        UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.contentInset.top = moveUp ? scalingValue + 23 : 55 // TODO: hardcoded!!!
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.scrollToLastMessage()
        })

    }
    
    func messageSubmitted(message: String) {
        conversation?.messages.append(Message.newMessage(content: message))
        tableView.reloadData()
        scrollToLastMessage()
    }
}
