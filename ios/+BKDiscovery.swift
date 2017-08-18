//
//  +BKDiscovery.swift
//  ios
//
//  Created by Brandon Price on 8/17/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation
import BluetoothKit

extension BKDiscovery {
    
    func getUsersName() -> String {
        var name = "User"
        
        if self.localName != nil && self.localName != "" && self.localName != "iPhone" {
            name = self.localName!
        }
        
        if self.remotePeripheral.name != nil && self.remotePeripheral.name != "" && self.remotePeripheral.name != "iPhone" {
            name = self.remotePeripheral.name!
        }
        
        return name
    }
}
