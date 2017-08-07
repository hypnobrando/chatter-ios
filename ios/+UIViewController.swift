//
//  +UIViewController.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func apnToken() -> String {
        return (UIApplication.shared.delegate as! AppDelegate).apnToken
    }
    
    func cache() -> Cache {
        return (UIApplication.shared.delegate as! AppDelegate).cache
    }
    
    func saveCacheToAppDelegate(cache: Cache) {
        (UIApplication.shared.delegate as! AppDelegate).cache = cache
    }
    
    func pushNotificationReceived(payload: [String:Any]) {
        print(payload)
    }
}
