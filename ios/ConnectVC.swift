//
//  Connect.swift
//  ios
//
//  Created by Brandon Price on 8/3/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit
import BluetoothKit

class ConnectVC: ChatterVC, UITableViewDataSource, UITableViewDelegate, BKPeripheralDelegate, BKCentralDelegate, BKAvailabilityObserver, BKRemotePeerDelegate {
    
    let SERVICE_UUID = UUID(uuidString: "2F6D474A-C5C5-4E39-837D-00C98A87E458")!
    let CHARACTERISTIC_UUID = UUID(uuidString: "EBB708B1-154D-4F9A-AF0A-B4CF1B05D5DF")!
    var BT_LOCAL_NAME = "Chatter Peripheral"
    let BUTTON_HEIGHT : CGFloat = 50.0
    
    var state = ButtonState.CentralIdle
    
    var table = UITableView()
    var button = Button()
    var discoveries = [BKDiscovery]()
    var peripheral = BKPeripheral()
    var central = BKCentral()
    var remoteCentral : BKRemoteCentral? = nil
    
    var connectedPeripherals = [(BKRemotePeer, String)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup the view.
        view.backgroundColor = UIColor.white
        let navBarHeight = navigationController!.navigationBar.frame.height + navigationController!.navigationBar.frame.origin.y
        table = UITableView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + navBarHeight, width: view.frame.width, height: view.frame.height - BUTTON_HEIGHT - navBarHeight))
        table.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table.allowsMultipleSelection = true
        table.dataSource = self
        table.delegate = self
        button = Button(frame: CGRect(x: view.frame.origin.x, y: table.frame.maxY, width: view.frame.width, height: BUTTON_HEIGHT))
        button.backgroundColor = BlueColor
        button.setTitle("Search", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        // Setup bluetooth.
        BT_LOCAL_NAME = Cache.loadUser().fullName()
        peripheral.delegate = self
        broadcastBT()
        central.delegate = self
        central.addAvailabilityObserver(self)
        listenBT()
        
        // Add subviews
        view.addSubview(button)
        view.addSubview(table)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let discovery = discoveries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.name.text = discovery.localName
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // 1 - Central
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        button.setTitle("Connect", for: .normal)
        button.backgroundColor = UIColor.red
        state = .CentralReadyToConnect
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        
        if tableView.indexPathsForSelectedRows == nil || tableView.indexPathsForSelectedRows!.count == 0 {
            button.setTitle("Stop", for: .normal)
            button.backgroundColor = BlueColor
            state = .CentralSearching
        }
    }
    
    // Bluetooth Remote Peripheral Delegate
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        // Parse data.
        let dataString = String(data: data, encoding: String.Encoding.utf8)!
        let components = dataString.components(separatedBy: " ")
        let type = components[0]
        
        switch type {
        
        // 4a - Central
        case "user_id":
            let remoteUserId = components[1]
            handleUserId(remoteUserId: remoteUserId, remotePeer: remotePeer)
            
        // 5a - Peripheral
        case "chat_id_and_key":
            let chatId = components[1]
            let key = components[2]
            handleChatIdAndKey(chatId: chatId, key: key)
            
        case "disconnect":
            table.deselectRow(at: table.indexPathForSelectedRow!, animated: true)
            
        default:
            print("what the heck?")
        }
    }
    
    // 4b - Central
    func handleUserId(remoteUserId: String, remotePeer: BKRemotePeer) {
        connectedPeripherals.append((remotePeer, remoteUserId))
        
        if connectedPeripherals.count < table.indexPathsForSelectedRows!.count {
            print("Waiting for more...")
            return
        }
        
        // Create new chat.
        var userIds = connectedPeripherals.map({
            (remotePeer, userId) -> String in
            return userId
        })
        userIds.append(Cache.loadUser().id)
        
        API.createChat(userIds: userIds, completionHandler: {
            (response, chat) in
            
            if response != URLResponse.Success {
                self.pushAlertView(title: "Error", message: "Check your internet connection.")
                return
            }
            
            let key = Encryption.createKey().key
            let dataString = "chat_id_and_key \(chat!.id) \(key)"
            
            // Send chat id to peripheral.
            for (peer, _) in self.connectedPeripherals {
                self.central.sendData(dataString.data(using: .utf8)!, toRemotePeer: peer, completionHandler: {
                    (data, peer, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                })
            }
            
            // Cache chat id and key.
            Cache.setChatKey(chatId: chat!.id, key: key)
            
            // Go back to main menu.
            self.removeSpinner()
            self.goToMainMenu()
        })
    }
    
    // 5b - Peripheral
    func handleChatIdAndKey(chatId: String, key: String) {
        // Cache chat id.
        Cache.setChatKey(chatId: chatId, key: key)
        
        removeSpinner()
        
        // Go back to main menu.
        self.goToMainMenu()
    }

    // Bluetooth Peripheral Delegate
    
    // 2 - Peripheral
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        // Find which user this is.
        
        let connectedDiscovery = discoveries.first(where: {
            (discovery) -> Bool in
            discovery.remotePeripheral.identifier == remoteCentral.identifier
        })
        
        if connectedDiscovery == nil {
            peripheral.sendData("disconnect".data(using: .utf8)!, toRemotePeer: remoteCentral, completionHandler: nil)
            return
        }

        let name = connectedDiscovery!.localName!
        
        // Ask user if they want to send data.
        button.backgroundColor = UIColor.red
        button.setTitle("Connect to \(name)?", for: .normal)
        state = .PeripheralAskingToConnect
        self.remoteCentral = remoteCentral
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("remoteCentralDidDisconnect")
        return
    }
    
    // Bluetooth Central Delegate
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("remotePeripheralDidDisconnect")
        return
    }
    
    // Bluetooth Availability Observer Delegate
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        if availability != BKAvailability.available {
            print("Please turn on bluetooth.")
            return
        }
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        return
    }
    
    // Bluetooth Methods
    
    func broadcastBT() {
        do {
            let configuration = BKPeripheralConfiguration(dataServiceUUID: SERVICE_UUID, dataServiceCharacteristicUUID: CHARACTERISTIC_UUID, localName: BT_LOCAL_NAME)
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
    }
    
    func buttonClicked(sender: UIButton!) {
        
        switch state {
        case ButtonState.CentralIdle:
            
            // User wants to start searching so lets do it baby.
            button.setTitle("Stop", for: .normal)
            state = .CentralSearching
            central.scanContinuouslyWithChangeHandler({
                (changes, discoveries) in
                // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
                // Handle current "available" discoveries, [BKDiscovery].
                // This is where you'd ie. update a table view.
                print(changes, discoveries)
                
                if changes.count == 0 {
                    return
                }
                
                // Reload table data.
                self.discoveries = discoveries.filter({
                    (discovery) -> Bool in
                    discovery.localName != nil
                })
                self.table.reloadData()
                
            }, stateHandler: { newState in
                // Handle newState, BKCentral.ContinuousScanState.
                // This is where you'd ie. start/stop an activity indicator.
                print(newState)
                
            }, duration: 1, inBetweenDelay: 1, errorHandler: { error in
                // Handle error.
                print(error)
            })
            
        case ButtonState.CentralSearching:
            
            // User wants to stop searching..
            if let selectedIndexPaths = table.indexPathsForSelectedRows {
                for indexPath in selectedIndexPaths {
                    table.deselectRow(at: indexPath, animated: true)
                    let cell = table.cellForRow(at: indexPath)!
                    cell.accessoryType = .none
                }
            }
            
            central.interruptScan()
            removeSpinner()
            button.setTitle("Search", for: .normal)
            button.backgroundColor = BlueColor
            state = .CentralIdle
            
        // 3 - Peripheral
        case ButtonState.PeripheralAskingToConnect:
            
            // Generate data that will be sent to central.
            let dataString = "user_id \(Cache.loadUser().id)"
            
            // Send data baby.
            pushSpinner(message: "", frame: table.frame)
            peripheral.sendData(dataString.data(using: .utf8)!, toRemotePeer: self.remoteCentral!, completionHandler: {
                (data, remotePeer, error) -> Void in
                if error != nil {
                    print(error)
                    return
                }
                remotePeer.delegate = self
            })
            
        case ButtonState.CentralReadyToConnect:
            state = .CentralSearching
            button.setTitle("Stop", for: .normal)
            
            let selectedDiscoveries = table.indexPathsForSelectedRows!.map({
                indexPath -> BKDiscovery in
                return self.discoveries[indexPath.row]
            })
            
            pushSpinner(message: "", frame: table.frame)
            for discovery in selectedDiscoveries {
                central.connect(remotePeripheral: discovery.remotePeripheral, completionHandler: {
                    (remotePeripheral, error) in
                    if error != nil {
                        // Handle error.
                        print(error)
                        return
                    }
                    // If no error, you're ready to receive data!
                    remotePeripheral.delegate = self
                })
            }
            
        default:
            print("what the heck?")
        }
    }
    
    // 6
    func goToMainMenu() {
        do {
            try central.stop()
            try peripheral.stop()
        } catch let error {
            print(error)
        }

        navigationController!.popViewController(animated: true)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        do {
            try central.stop()
            try peripheral.stop()
        } catch let error {
            print(error)
        }
    }
}

enum ButtonState {
    case CentralIdle
    case CentralSearching
    case CentralReadyToConnect
    case CentralConnecting
    case PeripheralAskingToConnect
}
