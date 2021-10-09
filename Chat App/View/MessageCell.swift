//
//  MessageCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessageCell: UITableViewCell {

    var message : Message?{
        didSet{
            messageBodyLabel.text = message?.content

            if message?.sender == Friend.me {
                // sent message will align to the right and it's green bubble
                inboundConstraint.isActive = false
                outboundConstraint.isActive = true
                bubleBackground.bubbleColor = UIColor.babyBlue
            } else {
                // received message will align to the left and it's white bubble
                outboundConstraint.isActive = false
                inboundConstraint.isActive = true
                bubleBackground.bubbleColor = UIColor.trueLightGray
                
            }
        }
    }
    
    static let identifier = "MessageCell"
    var inboundConstraint : NSLayoutConstraint!
    var outboundConstraint : NSLayoutConstraint!
    
    let messageBodyLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private var bubleBackground = BubbleChatView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bubleBackground)
        contentView.addSubview(messageBodyLabel)

        setupMessageBody()
        setupBubbleBackground()

    }
        
    func configure(model: Message){
        messageBodyLabel.text = model.content
        // align bubble based on whether the sender is the user themselves

        if model.sender == Friend.me {
            // sent message will align to the right and it's green bubble
            inboundConstraint.isActive = false
            outboundConstraint.isActive = true
            bubleBackground.bubbleColor = UIColor.babyBlue
        } else {
            // received message will align to the left and it's white bubble
            outboundConstraint.isActive = false
            inboundConstraint.isActive = true
            bubleBackground.bubbleColor = UIColor.trueLightGray
            
        }
    }
    
    func setupMessageBody(){
        messageBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.outboundConstraint =  messageBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28)
        self.inboundConstraint = messageBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28)

        let constraints : [NSLayoutConstraint] = [
            messageBodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            messageBodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            outboundConstraint,
            messageBodyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 210),
        ]
        
        NSLayoutConstraint.activate(constraints)

    }
    
    func setupBubbleBackground(){
        bubleBackground.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            bubleBackground.topAnchor.constraint(equalTo: messageBodyLabel.topAnchor, constant: -14),
            bubleBackground.leadingAnchor.constraint(equalTo: messageBodyLabel.leadingAnchor, constant: -14),
            bubleBackground.bottomAnchor.constraint(equalTo:  messageBodyLabel.bottomAnchor, constant: 14),
            bubleBackground.trailingAnchor.constraint(equalTo: messageBodyLabel.trailingAnchor, constant: 14),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
