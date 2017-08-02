//
//  ContactCell.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    let LEFT_MARGIN : CGFloat = 20.0
    
    var name: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Setup view.
        name.textColor = UIColor.black
        selectionStyle = UITableViewCellSelectionStyle.default
        
        contentView.addSubview(name)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        name.frame = CGRect(x: LEFT_MARGIN, y: frame.origin.y, width: frame.width, height: frame.height)
    }
}
