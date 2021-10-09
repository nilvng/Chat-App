//
//  BubbleChatView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/1/21.
//

import UIKit

class BubbleChatView: UIImageView {

    var bubbleColor : UIColor?{
        didSet{
            drawBubble()
        }
    }
    var radius : CGFloat? = 12
    var corners : UIRectCorner = UIRectCorner()
    
    init() {
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawBubble()
    }
    
    func drawBubble(isInbound: Bool = true){
        let renderer = UIGraphicsImageRenderer(size: self.frame.size)
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 15)
            self.bubbleColor?.setFill()
            path.fill()
        }
        self.image = im
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
