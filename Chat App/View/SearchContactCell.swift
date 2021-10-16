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
        
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    let thumbnail : TextCircleView = {
        let image = TextCircleView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnail)
        setupThumbnail()
        setupTitleLabel()
    }
    
    func configure (friend : Friend){
        titleLabel.text = friend.fullName
        thumbnail.update(url: friend.avatar, text: friend.firstName)
    }
    
    // MARK: Design Cell
    
    private var verticalPadding : CGFloat = 7
    private var horizontalPadding : CGFloat = 10
    
    func setupThumbnail() {
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        
        let width : CGFloat = 55
        let height : CGFloat = 55
        
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
            titleLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor,constant: -5),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 14)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



