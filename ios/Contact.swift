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
        firstName = "Galt"
        lastName = "MacDermot"
        id = 0
    }
    
    func fullName () -> String {
        return firstName + " " + lastName
    }
}
