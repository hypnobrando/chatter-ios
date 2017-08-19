//
//  contacts.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation

class Contact {
    var firstName : String
    var lastName : String
    var id : String
    var apnToken : String
    
    init() {
        firstName = ""
        lastName = ""
        id = ""
        apnToken = ""
    }
    
    init(firstName: String, lastName: String, id: String, apnToken: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.apnToken = apnToken
    }
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
    
    func stringID() -> String {
        return String(id)
    }
    
    class func deserialize(json: [String:Any]) -> Contact {
        var firstName = ""
        var lastName = ""
        var id = ""
        var apnToken = ""
        
        if let jsonFirstName = json["first_name"] as? String {
            firstName = jsonFirstName
        }
        
        if let jsonLastName = json["last_name"] as? String {
            lastName = jsonLastName
        }
        
        if let jsonId = json["_id"] as? String {
            id = jsonId
        }
        
        if let jsonApnToken = json["apn_token"] as? String {
            apnToken = jsonApnToken
        }
        
        return Contact(firstName: firstName, lastName: lastName, id: id, apnToken: apnToken)
    }
    
    func isEmpty() -> Bool {
        return id == ""
    }
}
