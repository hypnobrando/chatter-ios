//
//  Cache.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation

class Cache {
    var loaded = false
    var user = Contact()
    private var defaults = UserDefaults.standard
    
    init () {}
    
    init(contact: Contact) {
        user = contact
        loaded = true
    }
    
    static func loadUser() -> Cache {
        let cache = Cache()
        
        if let firstName = cache.defaults.string(forKey: "first_name") {
            cache.user.firstName = firstName
        }
        if let lastName = cache.defaults.string(forKey: "last_name") {
            cache.user.lastName = lastName
        }
        if let id = cache.defaults.string(forKey: "id") {
            cache.user.id = Int(id)!
            cache.loaded = true
        }
        
        return cache
    }
    
    static func cacheUser(contact: Contact) -> Cache {
        let cache = Cache(contact: contact)
        cache.defaults.setValue(contact.firstName, forKey: "first_name")
        cache.defaults.setValue(contact.lastName, forKey: "last_name")
        cache.defaults.setValue(String(contact.id), forKey: "id")
        cache.defaults.synchronize()
        
        return cache
    }
    
    func clear() {
        defaults.removeObject(forKey: "first_name")
        defaults.removeObject(forKey: "last_name")
        defaults.removeObject(forKey: "id")

        loaded = false
        user = Contact()
    }
}
