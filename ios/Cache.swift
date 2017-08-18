//
//  Cache.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation
import UIKit

class Cache {
    static var defaults = UserDefaults.standard
    
    static func loadUser() -> Contact {
        let user = Contact()
        
        if let firstName = defaults.string(forKey: "first_name") {
            user.firstName = firstName
        }
        if let lastName = defaults.string(forKey: "last_name") {
            user.lastName = lastName
        }
        if let id = defaults.string(forKey: "id") {
            user.id = id
        }
        if let apnToken = defaults.string(forKey: "apn_token") {
            user.apnToken = apnToken
        }
        
        return user
    }
    
    static func cacheUser(contact: Contact) {
        defaults.set(contact.firstName, forKey: "first_name")
        defaults.set(contact.lastName, forKey: "last_name")
        defaults.set(contact.id, forKey: "id")
        if contact.apnToken != "" {
            defaults.set(contact.apnToken, forKey: "apn_token")
        }
        defaults.synchronize()
    }
    
    static func cacheApnToken(token: String) {
        if token != "" {
            defaults.set(token, forKey: "apn_token")
        }
    }
    
    static func clear() {
        defaults.removeObject(forKey: "first_name")
        defaults.removeObject(forKey: "last_name")
        defaults.removeObject(forKey: "id")
        defaults.synchronize()
    }
    
    static func chatKey(chatId: String) -> String? {
        return defaults.string(forKey: "Key: \(chatId)")
    }
    
    static func setChatKey(chatId: String, key: String) {
        defaults.set(key, forKey: "Key: \(chatId)")
        defaults.synchronize()
    }
    
    static func getPin() -> String? {
        return defaults.string(forKey: "pin")
    }
    
    static func setPin(pin: String) {
        defaults.set(pin, forKey: "pin")
        defaults.synchronize()
    }
    
    static func removePin(){
        defaults.removeObject(forKey: "pin")
        defaults.synchronize()
    }
    
    static func addNewNotification(chatId: String) {
        if var notificationsDict = defaults.value(forKey: "Notifications") as? [String : Int] {
            notificationsDict[chatId] = 1
            defaults.set(notificationsDict, forKey: "Notifications")
        } else {
            defaults.set([chatId: 1], forKey: "Notifications")
        }

        defaults.synchronize()
        
        UIApplication.shared.applicationIconBadgeNumber = getNotificationsCount()
    }
    
    static func removeNotifications(chatId: String) {
        if var notificationsDict = defaults.value(forKey: "Notifications") as? [String : Int] {
            notificationsDict[chatId] = 0
            defaults.set(notificationsDict, forKey: "Notifications")
        } else {
            defaults.set([chatId: 0], forKey: "Notifications")
        }
        
        defaults.synchronize()
        
        UIApplication.shared.applicationIconBadgeNumber = getNotificationsCount()
    }
    
    static func getNotificationsCount() -> Int {
        if let notificationsDict = defaults.value(forKey: "Notifications") as? [String : Int] {
            var count = 0
            for (_, value) in notificationsDict {
                count += value
            }
            
            return count
        }
        
        return 0
    }
}
