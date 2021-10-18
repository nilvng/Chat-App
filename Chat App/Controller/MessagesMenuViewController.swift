//
//  MessagesMenuViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/17/21.
//

import UIKit

class MessagesMenuViewController : UIViewController{
    
    typealias DeleteAction = () -> Void
    
    var deleteAction : DeleteAction?
    
    let deleteButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    
    fileprivate func setupDeleteButton() {
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.setTitle("Delete Conversation", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)

    }
    
    fileprivate func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc func deleteButtonPressed() {
        deleteAction?()
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTitleLabel()
        setupDeleteButton()
    }
    
    func configure(_ model: Conversation, deleteAction: @escaping ()-> Void){
        titleLabel.text = model.title
        self.deleteAction = deleteAction
    }
}
