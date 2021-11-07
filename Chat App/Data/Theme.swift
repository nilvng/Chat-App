//
//  Theme.swift
//  Chat App
//
//  Created by Nil Nguyen on 11/7/21.
//

import UIKit

struct Theme {
    var startRgb : RGB
    var endRgb : RGB
}

struct RGB {
    var red : CGFloat
    var green : CGFloat
    var blue : CGFloat
}


extension Theme {
    static let basic = Theme(startRgb: .init(red: 34, green: 148, blue: 251),
                             endRgb: .init(red: 150, green: 34, blue: 251))
    static let halfEarthy = Theme(startRgb: RGB(red: 253, green: 187, blue: 45), endRgb: RGB(red: 154, green: 190, blue: 112))
    static let earthy = Theme(startRgb: RGB(red: 253, green: 187, blue: 45), endRgb: RGB(red: 34, green: 193, blue: 195))
}
