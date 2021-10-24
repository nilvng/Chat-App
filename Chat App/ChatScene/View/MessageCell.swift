//
//  MessageCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class MessageCell: UITableViewCell {

    var message : Message?
    static let identifier = "MessageCell"
    var inboundConstraint : NSLayoutConstraint!
    var outboundConstraint : NSLayoutConstraint!
    var continuousConstraint : NSLayoutConstraint!

    
    let messageBodyLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    let timestampLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    var bubbleImageView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var avatarView : AvatarView = {
        let view = AvatarView(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(bubbleImageView)
        contentView.addSubview(messageBodyLabel)

        setupMessageBody()
        setupBubbleBackground()
        }
    
    
    func configure(with model: Message, bubbleImage : UIImage, lastContinuousMess: Bool = false){
        message = model
        messageBodyLabel.text = model.content
        bubbleImageView.image = bubbleImage

        // align bubble based on whether the sender is the user themselves
        
        if model.sender == Friend.me {
            // sent message will align to the right and it's green bubble
            inboundConstraint?.isActive = false
            outboundConstraint?.isActive = true
            avatarView.removeFromSuperview()
        } else {
            // received message will align to the left and it's white bubble
            outboundConstraint?.isActive = false
            inboundConstraint?.isActive = true
            if lastContinuousMess{
                setupAvatarView()
                avatarView.update(url: model.sender.avatar, text: model.sender.firstName)
            } else {
                avatarView.removeFromSuperview()
            }
        }
        if !lastContinuousMess {
            continuousConstraint.constant = -bubbleVPadding + 3
        }
    }
    var bubbleVPadding : CGFloat = 14
    var bubbleHPadding : CGFloat = 18

    
    func setupMessageBody(){
        messageBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.outboundConstraint =  messageBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bubbleHPadding)
        self.inboundConstraint = messageBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: bubbleHPadding + 40)
        self.continuousConstraint = messageBodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bubbleVPadding)

        let constraints : [NSLayoutConstraint] = [
            messageBodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: bubbleVPadding),
            continuousConstraint,
            outboundConstraint,
            inboundConstraint,
            messageBodyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
        ]
        messageBodyLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate(constraints)

    }
    
    func setupBubbleBackground(){
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            bubbleImageView.topAnchor.constraint(equalTo: messageBodyLabel.topAnchor, constant: -bubbleVPadding * 3/4),
            bubbleImageView.leadingAnchor.constraint(equalTo: messageBodyLabel.leadingAnchor, constant: -bubbleHPadding * 2/3),
            bubbleImageView.bottomAnchor.constraint(equalTo:  messageBodyLabel.bottomAnchor, constant: bubbleVPadding * 3/4),
            bubbleImageView.trailingAnchor.constraint(equalTo: messageBodyLabel.trailingAnchor, constant: bubbleHPadding * 2/3),
        ]
        
        NSLayoutConstraint.activate(constraints)
        }
    
    func setupAvatarView(){
        contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            avatarView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            avatarView.widthAnchor.constraint(equalToConstant: 33),
            avatarView.heightAnchor.constraint(equalToConstant: 33)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTimestampLabel(){
        contentView.addSubview(timestampLabel)
        timestampLabel.translatesAutoresizingMaskIntoConstraints  = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
