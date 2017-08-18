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
    
    class func deserialize(json: [String:String]) -> Contact {
        return Contact(firstName: json["first_name"]!, lastName: json["last_name"]!, id: json["_id"]!, apnToken: json["apn_token"]!)
    }
    
    func isEmpty() -> Bool {
        return id == ""
    }
}
