//
//  ConversationCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/21/21.
//

import UIKit

class ConversationCell : UITableViewCell {
    
    // MARK: Properties
    
    static let identifier  = "ConversationCell"
        
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.textAlignment = .left
        return label
    }()
    private let lastMessageLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    private let timestampLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.tintColor = .gray
        label.textAlignment = .left
        return label

    }()
    private let thumbnail : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        return image
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(thumbnail)

    }
    
    func configure (model : Conversation){
        titleLabel.text = model.title
        thumbnail.image = model.thumbnail
        // don't have any messages in this conversation -> shouldn't become a cell
        guard let lastMsg = model.messages.last else {
            return
        }
        lastMessageLabel.text = lastMsg.content
        timestampLabel.text = dateFormatter.string(from: lastMsg.timestamp)
        }
    // MARK: Design Cell
    
    private var verticalPadding : CGFloat = 7
    private var horizontalPadding : CGFloat = 7

    override func layoutSubviews() {
        setupThumbnail()
        setupTitleLabel()
        setupLastMessageLabel()
        setupTimestampLabel()
    }
    
    
    
    func setupThumbnail() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        
        let width : CGFloat = 65
        let height : CGFloat = 65
        
        let constraints : [NSLayoutConstraint] = [
            thumbnail.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            thumbnail.widthAnchor.constraint(equalToConstant: width),
            thumbnail.heightAnchor.constraint(equalToConstant: height)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            titleLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor,constant: -11),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 7)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupLastMessageLabel() {
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            lastMessageLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor,constant:11),
            lastMessageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor)
        ]
        lastMessageLabel.setContentHuggingPriority(.init(250), for: .vertical)
        lastMessageLabel.setContentCompressionResistancePriority(.init(249), for: .vertical)
        lastMessageLabel.setContentCompressionResistancePriority(.init(249), for: .horizontal)

        NSLayoutConstraint.activate(constraints)
    }

    func setupTimestampLabel() {
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
                
        let constraints : [NSLayoutConstraint] = [
            timestampLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ]
        timestampLabel.setContentCompressionResistancePriority(.init(252), for: .horizontal)

        NSLayoutConstraint.activate(constraints)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



