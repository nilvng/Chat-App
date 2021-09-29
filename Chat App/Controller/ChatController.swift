//
//  ChatController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/29/21.
//

import UIKit

class ChatController: UIViewController {
    
    
    var msgList : [Int] = [1,2,3,4,5,6,7,8,9,10,11,12]
    
    private let tableView : UITableView = {
        let tableview = UITableView()
        tableview.rowHeight = 80
        return tableview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //setupBottomView()
        // Do any additional setup after loading the view.
    }
    
    func setupTableView(){
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
        tableView.backgroundColor = .yellow

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
    }
    
    func setupBottomView(){
        let theview = UIStackView()
        let inputfield = UITextField()
        inputfield.frame = CGRect(x: 0, y: 0, width: 300, height: 80)
        theview.backgroundColor = .red
        
        theview.addArrangedSubview(inputfield)
        view.addSubview(theview)

        theview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            theview.leftAnchor.constraint(equalTo: view.leftAnchor),
            theview.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        
    }
}

extension ChatController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as UITableViewCell
        cell.textLabel?.text = "Count \(msgList[indexPath.row])"
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList.count
    }
}

extension ChatController : UITableViewDelegate {
    
}
