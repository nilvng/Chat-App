//
//  MessagesViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate {
    
    var conversation : Conversation?
    
    var messageList : [Message] = []
    var inputContent : String = ""
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
//        table.keyboardDismissMode = .interactive // used for input accessory view
        table.allowsSelection = false
        return table
    }()
    
    lazy var inputStackViewContainer : UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .white
        view.axis = .horizontal
        view.alignment = .fill
        view.spacing = 7
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 3, trailing: 2)
        view.addArrangedSubview(inputField)
        view.addArrangedSubview(submitButton)
        return view
    }()
    
    var inputContainerBottomConstraint : NSLayoutConstraint?
    
    var inputField : UITextField = {
        let view = UITextField()
        view.backgroundColor = UIColor(named: "trueLightGray")
        view.layer.cornerRadius = 10
        return view
    }()

    var submitButton : UIButton = {
        let button = UIButton()
        button.setImage(.btn_send_forboy, for: .normal)
        button.setImage(.btn_send_forboy_disabled, for: .disabled)
        button.layer.cornerRadius = 30

        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = conversation?.title
        
        view.addSubview(tableView)
        view.addSubview(inputStackViewContainer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        
        configureInputFieldContainer()
        configureTableView()

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
//
//    override var inputAccessoryView: UIView? {
//        get{
//            inputStackViewContainer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
//            inputStackViewContainer.backgroundColor = .white
//            return inputStackViewContainer
//        }
//    }
//
//    override var canBecomeFirstResponder: Bool{
//        true
//    }
//
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputStackViewContainer.topAnchor),
        ])
    }
    
    func configureInputFieldContainer(){
        // styling inputContainer
        inputStackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainerBottomConstraint = inputStackViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            inputStackViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputStackViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputStackViewContainer.heightAnchor.constraint(equalToConstant: 65),
            inputContainerBottomConstraint!
        ])
        
        // declare actions
        inputField.delegate  = self
        submitButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToLastMessage()
        
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
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
//            self.scrollToLastMessage()
        })
    }
    
    func scrollToLastMessage(){
        let lastindex = IndexPath(row: messageList.count - 1, section: 0)
        tableView.scrollToRow(at: lastindex, at: .bottom, animated: true)

    }

    @objc func sendMessage(){
        print("sending message..")
        messageList.append(Message.newMessage(content: self.inputContent))
        inputField.text = ""
        tableView.reloadData()
        scrollToLastMessage()
    }
    
    @objc func handleTap(){
        print("tapping..")
        view.endEditing(true)
    }
}

extension MessagesViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanValue = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // only update when it truly changes
            if cleanValue != originalText{
                inputContent = cleanValue
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

extension MessagesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        
        cell.configure(model: messageList[indexPath.row])
        return cell
        
    }
    
    
}
