//
//  MessageCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessageCell: UITableViewCell {

    static let identifier = "MessageCell"
    var inboundConstraint : NSLayoutConstraint?
    var outboundConstraint : NSLayoutConstraint?
    
    let messageBody : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let bubleBackground : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bubleBackground)
        contentView.addSubview(messageBody)
        setupMessageBody()
        setupBubbleBackground()
    }
    
    func configure(model: Message){
        messageBody.text = model.content
        // align bubble based on whether the sender is the user themselves
        if model.sender == Friend.me {
            // sent message will align to the right and it's green bubble
            inboundConstraint?.isActive = false
            outboundConstraint?.isActive = true
            bubleBackground.backgroundColor = UIColor.babyBlue
        } else {
            // received message will align to the left and it's white bubble
            outboundConstraint?.isActive = false
            inboundConstraint?.isActive = true
            bubleBackground.backgroundColor = UIColor.trueLightGray
            
        }
    }
    
    func setupMessageBody(){
        messageBody.translatesAutoresizingMaskIntoConstraints = false
        let marginGuide = contentView
        
        self.outboundConstraint =  messageBody.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        self.inboundConstraint = messageBody.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)

        let constraints : [NSLayoutConstraint] = [
            messageBody.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant: 32),
            messageBody.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor, constant: -16),
            messageBody.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            inboundConstraint!,
            outboundConstraint!
        ]
        
        NSLayoutConstraint.activate(constraints)
        messageBody.setContentHuggingPriority(.defaultLow, for: .horizontal)

    }
    
    func setupBubbleBackground(){
        bubleBackground.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            bubleBackground.topAnchor.constraint(equalTo: messageBody.topAnchor, constant: -16),
            bubleBackground.leadingAnchor.constraint(equalTo: messageBody.leadingAnchor, constant: -16),
            bubleBackground.bottomAnchor.constraint(equalTo:  messageBody.bottomAnchor, constant: 16),
            bubleBackground.trailingAnchor.constraint(equalTo: messageBody.trailingAnchor, constant: 16),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
