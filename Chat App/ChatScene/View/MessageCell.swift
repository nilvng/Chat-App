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
        label.backgroundColor = .clear
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
    
    var incomingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = UIColor.lightGray
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()
    
    var outgoingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = .none
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bubbleImageView)
        contentView.addSubview(messageBodyLabel)
        contentView.addSubview(avatarView)

        setupMessageBody()
        setupAvatarView()
        setupBubbleBackground()
        
        }
    
    
    func configure(with model: Message, lastContinuousMess: Bool = false){
        message = model
        messageBodyLabel.text = model.content

        // align bubble based on whether the sender is the user themselves
    
        if model.sender == Friend.me {
            // get bubble
           bubbleImageView.image = BackgroundFactory.shared.getBackground(config: outgoingBubbleConfig)
            // sent message will align to the right
            inboundConstraint?.isActive = false
            outboundConstraint?.isActive = true
            // remove avatar view as message is sent by me
            avatarView.isHidden = true
            // bubble will have color so, text color = .white
            messageBodyLabel.textColor = .white
        } else {
            // get the bubble image
            bubbleImageView.image = BackgroundFactory.shared.getBackground(config: incomingBubbleConfig)
            // received message will align to the left
            outboundConstraint?.isActive = false
            inboundConstraint?.isActive = true
            messageBodyLabel.textColor = .black
            bubbleImageView.backgroundColor = .none
            // show avatar view if is the last continuous message a friend sent
            avatarView.isHidden = !lastContinuousMess
            if lastContinuousMess{
                avatarView.update(url: model.sender.avatar, text: model.sender.firstName)
            }
        }
            // continuous message would be closer to each other
            continuousConstraint.constant = !lastContinuousMess ? -bubbleVPadding + 4 : -bubbleVPadding
    }
    var bubbleVPadding : CGFloat = 14
    var bubbleHPadding : CGFloat = 18

    
    
    func updateGradient(currentFrame: CGRect, theme: Theme){
        
        guard message?.sender == Friend.me else {
            return
        }
        
        let screenHeight = UIScreen.main.bounds.size.height
        let currentY = currentFrame.minY
        
        let normalize = (currentY) / (screenHeight)
        let maxNormal = min(1, max(0, normalize))

        let differenceRed : CGFloat = theme.startRgb.red -  theme.endRgb.red
        let differenceGreen : CGFloat = theme.startRgb.green -  theme.endRgb.green
        let differenceBlue : CGFloat = theme.startRgb.blue -  theme.endRgb.blue


        
        let color = UIColor(red: (theme.startRgb.red + differenceRed * (1 - maxNormal)) / 255,
                             green: (theme.startRgb.green - differenceGreen * (1 - maxNormal)) / 255,
                             blue: (theme.startRgb.blue - differenceBlue * (1 - maxNormal)) / 255,
                             alpha: 1.0)

        bubbleImageView.backgroundColor = color
    }
    
    
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
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            avatarView.bottomAnchor.constraint(equalTo: messageBodyLabel.bottomAnchor),
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
