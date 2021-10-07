//
//  SearchContactCell.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/4/21.
//

import UIKit

class SearchContactCell : UITableViewCell {
    
    // MARK: Properties
    
    static let identifier  = "SearchContactCell"
        
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.textAlignment = .left
        return label
    }()
    private let thumbnail : TextCircleAvatarView = {
        let image = TextCircleAvatarView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
        return image
    }()
    
    var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnail)
        contentView.addSubview(separatorLine)

    }
    
    func configure (model : Conversation){
        

        titleLabel.text = model.title
        
        // check if contact has image, or else create an image of their first letter name
        if let avatar = model.thumbnail{
            thumbnail.image = avatar
        } else {
            thumbnail.createTextLayer(name: model.title)
        }
     
        }
    // MARK: Design Cell
    
    private var verticalPadding : CGFloat = 7
    private var horizontalPadding : CGFloat = 10

    override func layoutSubviews() {
        setupThumbnail()
        setupTitleLabel()
        setupSeparatorLine()
    }
    
    
    
    func setupThumbnail() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        
        let width : CGFloat = 68
        let height : CGFloat = 68
        
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
            titleLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor,constant: -14),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 14)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupSeparatorLine(){
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



