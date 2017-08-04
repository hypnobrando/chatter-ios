//
//  Connect.swift
//  ios
//
//  Created by Brandon Price on 8/3/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit
import BluetoothKit

class Connect: UIViewController, UITableViewDataSource, UITableViewDelegate, BKPeripheralDelegate, BKCentralDelegate, BKAvailabilityObserver {
    
    let SERVICE_UUID = UUID(uuidString: "F9EBC788-4B19-4D78-93CA-1E55091782B1")!
    let CHARACTERISTIC_UUID = UUID(uuidString: "9739A28B-6096-4606-9F29-473A65862C85")!
    var BT_LOCAL_NAME = ""
    
    
    var table = UITableView()
    var remotePeripherals = [BKRemotePeripheral]()
    var peripheral = BKPeripheral()
    var central = BKCentral()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup the view.
        table = UITableView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height))
        table.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table.dataSource = self
        table.delegate = self
        
        // Setup bluetooth.
        BT_LOCAL_NAME = cache().user.fullName()
        peripheral.delegate = self
        broadcastBT()
        central.delegate = self
        central.addAvailabilityObserver(self)
        
        view.addSubview(table)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remotePeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let remotePeripheral = remotePeripherals[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.name.text = remotePeripheral.name!
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let remotePeripheral = remotePeripherals[indexPath.row]
        central.connect(remotePeripheral: remotePeripheral, completionHandler: {
            remotePeripheral, error in
            if error != nil {
                // Handle error.
            }

            // If no error, you're ready to receive data!)
        })
    }

    // Bluetooth Peripheral Delegate
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        return
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        return
    }
    
    // Bluetooth Central Delegate
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        return
    }
    
    // Bluetooth Availability Observer Delegate
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        return
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        return
    }
    
    // Bluetooth Methods
    
    func broadcastBT() {
        do {
            let configuration = BKPeripheralConfiguration(dataServiceUUID: SERVICE_UUID, dataServiceCharacteristicUUID: 	CHARACTERISTIC_UUID, localName: BT_LOCAL_NAME)
            try peripheral.startWithConfiguration(configuration)
        } catch let error {
            // TODO - Handle error.
            print(error)
            return
        }
    }
    
    func listenBT() {
        do {
            let configuration = BKConfiguration(dataServiceUUID: SERVICE_UUID, dataServiceCharacteristicUUID: CHARACTERISTIC_UUID)
            try central.startWithConfiguration(configuration)
            // Once the availability observer has been positively notified, you're ready to discover and connect to peripherals.
        } catch let error {
            // TODO - Handle error.
            print(error)
            return
        }
        
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
            // Handle current "available" discoveries, [BKDiscovery].
            // This is where you'd ie. update a table view.
            
            if changes.count == 0 {
                return
            }
            
            self.remotePeripherals = discoveries.map({
                (discovery) -> BKRemotePeripheral in
                return discovery.remotePeripheral
            })
            
            self.table.reloadData()
            
        }, stateHandler: { newState in
            // Handle newState, BKCentral.ContinuousScanState.
            // This is where you'd ie. start/stop an activity indicator.
            
            
        }, duration: 3, inBetweenDelay: 3, errorHandler: { error in
            // Handle error.
            
        })
    }
}
