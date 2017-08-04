//
//  Message.swift
//  ios
//
//  Created by Brandon Price on 8/4/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation

class Message {
    var message : String
    var timeStamp : Date
    var user : Contact
    
    init() {
        message = ""
        timeStamp = Date()
        user = Contact()
    }
    
    init(user: Contact, message: String, timeStamp: Date) {
        self.user = user
        self.message = message
        self.timeStamp = timeStamp
    }
    
    class func deserialize(json: [String:Any], user: Contact) -> Message {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        let parsedTimetamp = String((json["timestamp"] as! String).characters.dropLast(3))
        let date = dateFormatter.date(from: parsedTimetamp)!
        return Message(user: user, message: json["message"] as! String, timeStamp: date)
    }
        
}
