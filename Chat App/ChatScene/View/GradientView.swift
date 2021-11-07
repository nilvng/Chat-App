//
//  GradientView.swift
//  Chat App
//
//  Created by Nil Nguyen on 11/3/21.
//

import UIKit

class GradientView: UIView {

    var gradientLayer : CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    internal var cgColorGradient: [CGColor]? {
        guard let startColor = startColor, let endColor = endColor else {
            return nil
        }
        
        return [startColor.cgColor, endColor.cgColor]
    }
    
    @IBInspectable var startColor: UIColor? {
            didSet { gradientLayer.colors = cgColorGradient }
        }

        @IBInspectable var endColor: UIColor? {
            didSet { gradientLayer.colors = cgColorGradient }
        }

        @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0) {
            didSet { gradientLayer.startPoint = startPoint }
        }

    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0) {
            didSet { gradientLayer.endPoint = endPoint }
        }
    
    @IBInspectable var locations: [NSNumber] = [0.0, 1.0] {
        didSet { gradientLayer.locations = locations }
        }

}
