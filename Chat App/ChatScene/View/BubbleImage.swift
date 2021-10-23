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

class BubbleFactory {
    var middleBubble = UIImage()
    var lastBubble = UIImage()
    var onlyBubble = UIImage()
    var firstBubble = UIImage()
    
    init() {
        firstBubble = drawBubble(corners: [.bottomRight, .topRight, .topLeft])
        middleBubble = drawBubble(corners: [.bottomRight, .topRight])
        lastBubble = drawBubble(corners: [.bottomRight, .topRight, .bottomLeft])
        onlyBubble = drawBubble(corners: [.allCorners])

    }
    
    func drawBubble(corners: UIRectCorner, radius : CGFloat = 13) -> UIImage{
        let edge = 40
        let size = CGSize(width: edge, height: edge)
        let renderer = UIGraphicsImageRenderer(size: size)
        let im = renderer.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: radius)
            UIColor.orange.setFill()
            path.fill()
        }
        let resizable_im = im.resizableImage(withCapInsets: UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius), resizingMode: .stretch)
        return resizable_im.withRenderingMode(.alwaysTemplate)

    }
}

class BubbleImageView: UIImageView {

    var bubbleColor : UIColor?
    var bubbleSize : CGSize?
    var radius : CGFloat! = 20
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
