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
    var radius : CGFloat! = 15
    var corners : UIRectCorner = .allCorners
    
    init() {
        super.init(frame: .zero)
    }
    
    func configure(isIncoming: Bool){
        let im = isIncoming ? incomingBubbleImage() : outgoingBubbleImage()
        self.image = im.resizableImage(withCapInsets: UIEdgeInsets(top: self.radius, left: radius, bottom: radius, right: radius), resizingMode: .stretch)
    }
    
    func drawBubble(){
        let theSize = (bubbleSize != nil) ? bubbleSize : self.frame.size
        let width = theSize!.width
        let height = theSize!.height
        
        let renderer = UIGraphicsImageRenderer(size: theSize!)
        let im = renderer.image { _ in
            self.image?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        self.image = im
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func incomingBubbleImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.frame.size)
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
            UIColor.trueLightGray?.setFill()
            path.fill()
        }
        return im
    }
    
    func outgoingBubbleImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.frame.size)
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
            UIColor.babyBlue?.setFill()
            path.fill()
        }
        return im
    }

}
