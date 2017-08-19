//
//  ContactCell.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    let BlueColor = UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    let LEFT_MARGIN : CGFloat = 20.0
    let RIGHT_MARGIN : CGFloat = 0.0
    let HEIGHT_MARGIN : CGFloat = 15.0
    var numUnreadLabel = UILabel()
    
    var name : UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Setup view.
        name.textColor = .black
        selectionStyle = UITableViewCellSelectionStyle.default
        name.frame = CGRect(x: LEFT_MARGIN, y: contentView.frame.origin.y, width: contentView.frame.width - contentView.frame.height - RIGHT_MARGIN - LEFT_MARGIN, height: contentView.frame.height)
        
        contentView.addSubview(name)
        numUnreadLabel.removeFromSuperview()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func loadChat(chat: Chat, user: Contact) {
        name.text = chat.ChatNameGivenUser(user: user)
        
        numUnreadLabel.removeFromSuperview()
        let numUnread = Cache.getNotificationsCountFor(chatId: chat.id)
        
        if  numUnread == 0 {
            name.textColor = .black
        } else {
            name.textColor = .black
            
            numUnreadLabel = UILabel(frame: CGRect(x: contentView.frame.maxX, y: name.frame.origin.y + HEIGHT_MARGIN / 2.0, width: contentView.frame.height - HEIGHT_MARGIN, height: contentView.frame.height - HEIGHT_MARGIN))
            numUnreadLabel.text = String(describing: numUnread)
            numUnreadLabel.textAlignment = .center
            numUnreadLabel.textColor = .white
            numUnreadLabel.backgroundColor = .red
            numUnreadLabel.layer.masksToBounds = true
            numUnreadLabel.layer.cornerRadius = numUnreadLabel.frame.width / 2.0
            contentView.addSubview(numUnreadLabel)
        }
    }
}
