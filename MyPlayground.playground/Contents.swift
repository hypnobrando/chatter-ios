//
//  Encryption.swift
//  ios
//
//  Created by Brandon Price on 8/4/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation
import CryptoSwift

class Encryption {
    
    var key : String
    var iv : String
    
    init() {
        key = ""
        iv = ""
    }
    /*
     init(chat: Chat, cache: Cache) {
     if let key = cache.chatKey(chatId: chat.id) {
     self.key = key
     } else {
     key = ""
     }
     
     if let iv = cache.chatIV(chatId: chat.id) {
     self.iv = iv
     } else {
     iv = ""
     }
     }*/
    
    init(key: String, iv: String) {
        self.key = key
        self.iv = iv
    }
    
    class func createKey(chat: Chat, uuids: [String]) -> Encryption {
        let uuidComb = uuids.reduce("", { (s1, s2) -> String in s1 + s2 })
        let iv = uuidComb.md5()
        let key = randomStringWithLength(i: Int(arc4random() * 90 + 10))
        
        return Encryption(key: key, iv: iv)
    }
    
    func encrypt(message: String) -> String {
        var encrypted = ""
        do {
            let res = try Blowfish(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).encrypt(Array(message.utf8))
            encrypted = res.toBase64()!
        } catch {}
        return encrypted
    }
    
    func decrypt(message: String) -> String {
        var decrypted = ""
        do {
            let res = try Blowfish(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).decrypt(Array(message.utf8))
            decrypted = res.toBase64()!
        } catch {}
        return decrypted
    }
    
    class func randomStringWithLength(i: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()?><,.=-+[]}{|`~:;'"
        
        var randomString = ""
        
        for _ in 0 ..< i {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString += String(letters.character(at: Int(rand)))
        }
        
        return randomString as String
    }
}
