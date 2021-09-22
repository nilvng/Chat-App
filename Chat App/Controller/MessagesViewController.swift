//
//  MessagesViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate {
    
    var messageList : [Message] = []
    var inputContent : String = ""
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.keyboardDismissMode = .interactive
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
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 3, leading: 2, bottom: 3, trailing: 2)
        view.addArrangedSubview(inputField)
        view.addArrangedSubview(submitButton)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    var inputField : UITextField = {
        let view = UITextField()
        view.backgroundColor = UIColor(named: "trueLightGray")
        view.layer.cornerRadius = 10
        return view
    }()

    var submitButton : UIButton = {
        let button = UIButton()
        UIImageView(image: btn_)
        button.setImage(UIImage(named: "btn_send_forboy"), for: .normal)
        button.setImage(UIImage(named: "btn_send_forboy_disable"), for: .disabled)

        button.layer.cornerRadius = 30

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
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.frame = view.layer.bounds

        inputField.delegate  = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get{
            inputStackViewContainer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 77)
            inputStackViewContainer.backgroundColor = .white
            return inputStackViewContainer
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidAppear(notification: NSNotification){
        guard ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height)! > 200 && tableView.contentInset.bottom == 0 else {
            return
        }
        print("show up")
        let height : CGFloat = 300
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height + 3, right: 0)
        let lastindex = IndexPath(row: messageList.count - 1, section: 0)
        tableView.scrollToRow(at: lastindex, at: .bottom, animated: true)

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
        messageList.append(Message.newMessage(content: self.inputContent))
        textField.text = ""
        tableView.reloadData()
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


extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
