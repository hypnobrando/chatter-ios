//
//  +UITextField.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class TextField : UITextField {
    
    let DEFAULT_FONTSIZE = CGFloat(17.0)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, placeholder: String) {
        super.init(frame: frame)
        
        borderStyle = UITextBorderStyle.roundedRect
        font = UIFont.systemFont(ofSize: DEFAULT_FONTSIZE)
        self.placeholder = placeholder
        autocorrectionType = .no
        keyboardType = .default
        clearButtonMode = .whileEditing
        contentVerticalAlignment = .center
    }
}
