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
    
    var inputContent : String = ""
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        return table
    }()
    
    lazy var inputStackViewContainer : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .bottom
        view.spacing = 7
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.backgroundColor = .white
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2, leading: 3, bottom: 5, trailing:3)
        view.addArrangedSubview(inputField)
        view.addArrangedSubview(submitButton)
        return view
    }()
    
    var inputContainerBottomConstraint : NSLayoutConstraint?
    
    var inputHeight : CGFloat = 55
    
    var inputField : UITextView = {
        let tview = UITextView()
//        tview.backgroundColor = UIColor(named: "trueLightGray")
        tview.isScrollEnabled = false
        tview.contentInsetAdjustmentBehavior = .automatic
        tview.font = UIFont(name: "Arial", size: 16)
        return tview
    }()

    var submitButton : UIButton = {
        let button = UIButton()
        button.setImage(.btn_send_forboy, for: .normal)
        button.setImage(.btn_send_forboy_disabled, for: .disabled)
        return button
    }()
    
    var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
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
        
        setupInputContainer()

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func setupInputContainer(){
        // styling inputContainer
        inputStackViewContainer.addSubview(separatorLine)
        view.addSubview(inputStackViewContainer)
        

        inputStackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        inputContainerBottomConstraint = inputStackViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        let margin = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            inputStackViewContainer.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            inputStackViewContainer.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            inputContainerBottomConstraint!,
            separatorLine.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -5),
                separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.7)
            ])
        
        // declare actions
        inputField.delegate  = self
        submitButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        actionDelegate?(conversation!.messages)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func handleKeyboardNotification(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue? else {
            return
        }
        print("Keyboard is moving...")
        
        let moveUp = notification.name == UIResponder.keyboardDidShowNotification
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0

        inputContainerBottomConstraint?.constant = -scalingValue
        
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.contentInset.top = moveUp ? scalingValue + 23 : self.inputHeight // TODO: hardcoded!!!
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.scrollToLastMessage()
        })
    }
    
    func scrollToLastMessage(animated: Bool = true){
        DispatchQueue.main.async {
            let lastindex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: lastindex, at: .bottom, animated: animated)
        }
    }

    @objc func sendMessage(){
        print("sending message..")
        conversation?.messages.append(Message.newMessage(content: self.inputContent))
        inputField.text = ""
        tableView.reloadData()
        scrollToLastMessage()
    }
    
    @objc func handleTap(){
        print("tapping..")
        view.endEditing(true)
    }
}

extension MessagesViewController : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let originalText = textView.text {
            
            // Send message
            if text == "\n" {
                if  let msg = textView.text ,msg != ""{
                    sendMessage()
                }
                return false
            }
            
            // Usual edit message
            let title = (originalText as NSString).replacingCharacters(in: range, with: text)
            
            ///  remove leading and trailing whitespace
            let cleanValue = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            /// only update when it truly changes
            if cleanValue != originalText{
                inputContent = cleanValue
            }
        }
        return true

    }

}

extension MessagesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.conversation!.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let reverseIndex = conversation!.messages.count - indexPath.row - 1
        cell.message = conversation!.messages[reverseIndex]

        cell.transform = CGAffineTransform(scaleX: 1, y: -1)

        
        return cell
        
    }
    
    
}
