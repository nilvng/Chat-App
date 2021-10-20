//
//  DefaultAvatarView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/3/21.
//

import UIKit

class TextCircleAvatarView: CircleAvatarView {

    override init(username: String? = nil) {
        super.init(username: username)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func createTextLayer(name: String, backgrounColorString: String? = "default_bg_color") {
        
        self.backgroundColor = UIColor(named: backgrounColorString!)
        
        let firstLetter = name.first!
        
        let textLayer = CATextLayer()
        textLayer.string = "\(firstLetter)"
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.font = UIFont(name: "Avenir", size: 25.0)
        textLayer.fontSize = 25.0
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.frame = CGRect(x: 0.0, y: self.frame.size.height / 3 - 5,
                                 width: self.frame.size.width, height: 36)
        textLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(textLayer)
    }
}
