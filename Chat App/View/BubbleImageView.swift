//
//  BubbleImageView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/10/21.
//

import Foundation

//
//  BubbleChatView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/1/21.
//

import UIKit

class BubbleImageView: UIImageView {

    var bubbleColor : UIColor?
    var bubbleSize : CGSize?
    var radius : CGFloat? = 30
    var corners : UIRectCorner = .allCorners
    
    init() {
        super.init(frame: .zero)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(){
        drawBubble()
    }
    
    func drawBubble(){
        let theSize = (bubbleSize != nil) ? bubbleSize : self.frame.size
        let width = theSize!.width
        let height = theSize!.height
        
        let renderer = UIGraphicsImageRenderer(size: theSize!)
        let im = renderer.image { _ in
            let path = UIBezierPath(
                roundedRect: CGRect(x: 0, y: 0, width: width, height: height),
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius!, height: 0))
            self.bubbleColor?.setFill()
            path.fill()
        }
        self.image = im
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
