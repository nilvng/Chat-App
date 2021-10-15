//
//  DefaultAvatarView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/3/21.
//

import UIKit

class TextCircleAvatarView: CircleView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(image: UIImage?, text: String?){
        // check if contact has image, or else create an image of their first letter name
        if let avatar = image{
            self.image = avatar
        } else {
            let firstCharacter = String((text?.first)!) as NSString
            self.drawText(text: firstCharacter)
        }

    }
    
    func drawText(text: NSString){
        let renderer = UIGraphicsImageRenderer(size: self.frame.size)
        let colorImage = UIImage(named: "bg_color")!
        let im = renderer.image { _ in
            // text attributes
            let textColor       = UIColor.white
            let textStyle       = NSMutableParagraphStyle()
            textStyle.alignment = NSTextAlignment.center
            let textFont        = UIFont(name: "Helvetica", size: self.frame.size.width / 3)!
            let attributes      = [NSAttributedString.Key.font:textFont,
                            NSAttributedString.Key.paragraphStyle:textStyle,
                            NSAttributedString.Key.foregroundColor:textColor]
            
            colorImage.draw(in: CGRect(origin: CGPoint.zero, size: colorImage.size))

            //vertically center (depending on font)
            let text_h      = textFont.lineHeight
            let text_y      = (self.frame.size.height-text_h)/2
            let text_rect   = CGRect(x: 0, y: text_y, width: self.frame.size.width, height: text_h)
            text.draw(in: text_rect.integral, withAttributes: attributes)
        }
        self.image = im
    }
    
}
