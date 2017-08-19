//
//  Chats.swift
//  ios
//
//  Created by Brandon Price on 8/4/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation

class Chat {
    var id : String
    var users : [Contact]
    var messages : [Message]
    var title : String
    
    init() {
        id = ""
        users = [Contact]()
        messages = [Message]()
        title = ""
    }
    
    init(id: String, users: [Contact], messages: [Message], title: String) {
        self.id = id
        self.users = users
        self.messages = messages
        self.title = title
    }
    
    class func deserialize(json: [String:Any]) -> Chat {
        
        var users = [Contact]()
        
        if let jsonUsers = json["users"] as? [[String:Any]] {
            users = jsonUsers.map({
                jsonUser -> Contact in
                Contact.deserialize(json: jsonUser)
            })
        }
        
        
        var messages = [Message]()
        if let messageJson = json["messages"] as? [[String:Any]] {
            messages = messageJson.map({
                messageJson -> Message in
                return Message.deserialize(json: messageJson, user: users.first(where: {
                    $0.id == messageJson["user_id"] as! String
                })!)
            })

        }
        
        let title = json["title"] as? String
        
        return Chat(id: json["_id"] as! String, users: users, messages: messages, title: title == nil ? "" : title!)
    }
    
    func getNamesExceptFor(user: Contact) -> String {
        var names = ""
        
        for messageUser in users {
            if messageUser.id != user.id {
                names += messageUser.fullName() + ", "
            }
        }
        
        return String(names.characters.dropLast(2))
    }
    
    func ChatNameGivenUser(user: Contact) -> String {
        if title == "" {
            return getNamesExceptFor(user: user)
        }
        
        return title
    }
}
