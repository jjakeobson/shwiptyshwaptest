//
//  RoundButton.swift
//  devsocial
//
//  Created by Jake Jacobson on 8/15/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: SHADOW_GRAY).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        imageView?.contentMode = .ScaleAspectFit
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
    }

}
