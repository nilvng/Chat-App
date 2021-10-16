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
    
    var button : UIButton = {
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
    
    init() {
        super.init(frame:.zero)
        alignment = .center
        distribution = .equalSpacing
        axis  = .horizontal
        backgroundColor = .brown
        
        spacing = 196
        addArrangedSubview(titleLabel)
        addArrangedSubview(button)
        

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitleLabel(){
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
}
