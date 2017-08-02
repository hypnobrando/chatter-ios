//
//  Cache.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation

class Cache {
    var user = Contact()
    private var defaults = UserDefaults.standard
    
    init () {
        if let firstName = defaults.string(forKey: "first_name") {
            user.firstName = firstName
        }
        if let lastName = defaults.string(forKey: "last_name") {
            user.lastName = lastName
        }
        if let id = defaults.string(forKey: "id") {
            user.id = Int(id)!
        }
    }
}
