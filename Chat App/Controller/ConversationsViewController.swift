//
//  ViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationsViewController: UIViewController {
    
    var conversationList : [Conversation] = Conversation.stubList
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .singleLine
        table.rowHeight = 80
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Let's Chat"
        navigationController?.navigationBar.barTintColor = .white
        //navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]


        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
    }


}

extension ConversationsViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // navigate to conversation detail view
        let messagesViewController = MessagesViewController()
        messagesViewController.messageList = conversationList[indexPath.row].messages
        navigationController?.pushViewController(messagesViewController, animated: true)
    }
}

extension ConversationsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.conversationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as! ConversationCell
        
        cell.configure(model: conversationList[indexPath.row])
        return cell
        
    }
    
    
}

