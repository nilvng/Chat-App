//
//  UIView+Chat.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/27/21.
//

import UIKit

extension UIView {
    func setGradientBackground(){
        let startColor = UIColor(red: 162/255, green: 48/255, blue: 237/255, alpha: 1)
        let endColor = UIColor(red: 25/255, green: 0, blue: 135/255, alpha: 1)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
