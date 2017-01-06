//
//  GradientView.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

//A view that has a gradient background
@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.clear {
        didSet{ layoutSubviews() }
    }
    @IBInspectable var bottomColor: UIColor = UIColor.black {
        didSet { layoutSubviews() }
    }
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0) {
        didSet { layoutSubviews() }
    }
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0) {
        didSet { layoutSubviews() }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).startPoint = startPoint
        (layer as! CAGradientLayer).endPoint = endPoint
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
