//
//  Encryption.swift
//  ios
//
//  Created by Brandon Price on 8/4/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation
import AES256CBC

class Encryption {
    
    var key : String
    
    init() {
        key = ""
    }
    
    init(chat: Chat, cache: Cache) {
        if let key = cache.chatKey(chatId: chat.id) {
            self.key = key
        } else {
            key = ""
        }
    }
    
    init(key: String) {
        self.key = key
    }
    
    class func createKey() -> Encryption {
        let key = randomStringWithLength(i: 32)
        return Encryption(key: key)
    }
    
    func encrypt(message: String) -> String {
        return AES256CBC.encryptString(message, password: key)!
    }
    
    func decrypt(message: String) -> String {
        return AES256CBC.decryptString(message, password: key)!
    }
    
    class func randomStringWithLength(i: Int) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()?><,.=-+[]}{|`~:;'"
        
        var randomString = ""
        
        for _ in 0 ..< i {
            let length = letters.characters.count
            let rand = Int(arc4random_uniform(UInt32(length)))
            randomString += String(Array(letters.characters)[rand])
        }
        
        return randomString as String
    }
}
