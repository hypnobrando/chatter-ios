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
    var key = ""
    
    var table = UITableView()
    var button = Button()
    var discoveries = [BKDiscovery]()
    var peripheral = BKPeripheral()
    var central = BKCentral()
    var remoteCentral : BKRemoteCentral? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup the view.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        view.backgroundColor = UIColor.white
        let navBarHeight = navigationController!.navigationBar.frame.height + navigationController!.navigationBar.frame.origin.y
        table = UITableView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + navBarHeight, width: view.frame.width, height: view.frame.height - BUTTON_HEIGHT - navBarHeight))
        table.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table.dataSource = self
        table.delegate = self
        button = Button(frame: CGRect(x: view.frame.origin.x, y: table.frame.maxY, width: view.frame.width, height: BUTTON_HEIGHT))
        button.backgroundColor = BlueColor
        button.setTitle("Search", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        button.currentState = ButtonStates.Idle.hashValue
        
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
    
    func back(sender: UIBarButtonItem) {
        goToMainMenu()
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
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // 1 - Central
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let discovery = discoveries[indexPath.row]
        pushSpinner(message: "", frame: table.frame)
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
    
    // Bluetooth Remote Peripheral Delegate
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        // Parse data.
        let dataString = String(data: data, encoding: String.Encoding.utf8)!
        let components = dataString.components(separatedBy: " ")
        let type = components[0]
        
        switch type {
        
        // 4a - Central
        case "user_id_and_key":
            let remoteUserId = components[1]
            let key = components[2]
            handleUserIdAndKey(remoteUserId: remoteUserId, key: key, remotePeer: remotePeer)
            
        // 5a - Peripheral
        case "chat_id":
            let chatId = components[1]
            handleChatId(chatId: chatId)
            
        case "disconnect":
            table.deselectRow(at: table.indexPathForSelectedRow!, animated: true)
            
        default:
            print("what the heck?")
        }
    }
    
    // 4b - Central
    func handleUserIdAndKey(remoteUserId: String, key: String, remotePeer: BKRemotePeer) {
        // Create new chat.
        API.createChat(userIds: [remoteUserId, Cache.loadUser().id], completionHandler: {
            (response, chat) in
            
            if response != URLResponse.Success {
                print(response)
                return
            }
            
            let dataString = "chat_id \(chat!.id)"
            
            // Send chat id to peripheral.
            self.central.sendData(dataString.data(using: .utf8)!, toRemotePeer: remotePeer, completionHandler: {
                (data, peer, error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                // Cache chat id and key.
                Cache.setChatKey(chatId: chat!.id, key: key)
                
                // Go back to main menu.
                self.removeSpinner()
                self.goToMainMenu()
            })
        })
    }
    
    // 5b - Peripheral
    func handleChatId(chatId: String) {
        // Cache chat id.
        Cache.setChatKey(chatId: chatId, key: self.key)
        
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
        pushSpinner(message: "", frame: table.frame)
        button.backgroundColor = UIColor.red
        button.setTitle("Connect to \(name)?", for: .normal)
        button.currentState = ButtonStates.ReadyToConnect.hashValue
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
        
        switch button.currentState {
        case ButtonStates.Idle.hashValue:
            
            // User wants to start searching so lets do it baby.
            button.setTitle("Stop", for: .normal)
            button.currentState = ButtonStates.Searching.hashValue
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
                
            }, duration: 3, inBetweenDelay: 3, errorHandler: { error in
                // Handle error.
                print(error)
            })
            
        case ButtonStates.Searching.hashValue:
            
            // User wants to stop searching..
            central.interruptScan()
            button.setTitle("Search", for: .normal)
            button.currentState = ButtonStates.Idle.hashValue
            
        // 3 - Peripheral
        case ButtonStates.ReadyToConnect.hashValue:
            
            // Generate key for chat.
            self.key = Encryption.createKey().key
            
            // Generate data that will be sent to central.
            let dataString = "user_id_and_key \(Cache.loadUser().id) \(key)"
            
            // Send data baby.
            peripheral.sendData(dataString.data(using: .utf8)!, toRemotePeer: self.remoteCentral!, completionHandler: {
                (data, remotePeer, error) -> Void in
                if error != nil {
                    print(error)
                    return
                }
                remotePeer.delegate = self
            })
            
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
}

enum ButtonStates {
    case Idle
    case Searching
    case ReadyToConnect
}
