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
        table.backgroundColor = .yellow
//        table.keyboardDismissMode = .interactive // used for input accessory view
        table.allowsSelection = false
        return table
    }()
    
    lazy var inputStackViewContainer : UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .red
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 7
        view.distribution = .fill
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 3, trailing: 2)
        view.addArrangedSubview(inputField)
        view.addArrangedSubview(submitButton)
        return view
    }()
    
    var inputContainerBottomConstraint : NSLayoutConstraint?
    
    var inputHeight : CGFloat = 55
    
    var inputField : UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "trueLightGray")
        field.borderStyle = .roundedRect
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true // TODO: hardcoded!!!
        return field
    }()

    var submitButton : UIButton = {
        let button = UIButton()
        button.setImage(.btn_send_forboy, for: .normal)
        button.setImage(.btn_send_forboy_disabled, for: .disabled)
        
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
        
        configureTableView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        tableView.addGestureRecognizer(tapGesture)
        
        configureInputFieldContainer()

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
        tableView.backgroundColor = .yellow

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
    
    func configureInputFieldContainer(){
        // styling inputContainer
        view.addSubview(inputStackViewContainer)

        inputStackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        let margin = view.safeAreaLayoutGuide
        inputContainerBottomConstraint = inputStackViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            inputStackViewContainer.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            inputStackViewContainer.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            inputContainerBottomConstraint!,
            ])
        
        // declare actions
        inputField.delegate  = self
        submitButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)

        cell.configure(model: messageList[indexPath.row])

        return cell
        
    }
    
    
}
