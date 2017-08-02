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
    var id : Int
    
    init() {
        firstName = ""
        lastName = ""
        id = -1
    }
    
    init(firstName: String, lastName: String, id: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
    }
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
    
    func stringID() -> String {
        return String(id)
    }
}
