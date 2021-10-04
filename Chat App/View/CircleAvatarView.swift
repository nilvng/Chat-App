//
//  RoundedImageView.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/2/21.
//

import UIKit

class CircleAvatarView: UIImageView {

    var path : UIBezierPath!

    init(username: String? = nil) {
        super.init(frame: CGRect()) // workaround
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCircleMask()
    }
    
    
    func setupCircleMask(){
        self.drawCricle()
        let layer = CAShapeLayer()
        layer.path = self.path.cgPath
        self.layer.mask = layer
    }
    
    func drawCricle(){
        self.path = UIBezierPath(ovalIn: CGRect(x: self.frame.size.width/2 - self.frame.size.height/2,
                                                y: 0.0,
                                                width: self.frame.size.height,
                                                height: self.frame.size.height))
        
    }
            
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
