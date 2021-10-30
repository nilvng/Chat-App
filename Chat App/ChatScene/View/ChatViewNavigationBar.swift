//
//  ChatViewNavigationBar.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/16/21.
//

import UIKit

class ChatViewNavigationBar: UIStackView {
    var title : String! {
        didSet{
            titleLabel.text = title
        }
    }
    
    var backButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.back_button, for: .normal)
        button.sizeToFit()
        return button
    }()

    var menuButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chat_menu, for: .normal)
        return button
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    var spacer : UIView = {
        let spacer = UIView()
        let constraint = spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.width)
        constraint.isActive = true
        constraint.priority = .defaultLow
        return spacer
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        axis  = .horizontal
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(spacer)
        addArrangedSubview(menuButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
