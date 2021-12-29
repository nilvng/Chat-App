//
//  BubbleContainer.swift
//  Chat App
//
//  Created by LAP11353 on 26/11/2021.
//

import UIKit

class BubbleContainer : UIView {
    let messageBodyLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.backgroundColor = .clear
        return label
    }()
    
    var bubbleImageView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    func setupBubbleBackground(){

        }
    func setupMessageBody(){

    }


}
