//
//  ViewController.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class HomeVC: ChatterVC, UITableViewDataSource, UITableViewDelegate {
    
    let BOTTOM_MARGIN : CGFloat = 50.0
    
    var chats = [Chat]()
    var table = UITableView()
    var connectButton = UIButton()
    var settingsButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up background.
        navigationController?.navigationBar.topItem?.title = "Chatter"
        
        // Setup views.
        table = UITableView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height - BOTTOM_MARGIN))
        table.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table.dataSource = self
        table.delegate = self
        
        connectButton = UIButton(frame: CGRect(x: view.frame.origin.x, y: view.frame.maxY - BOTTOM_MARGIN, width: view.frame.width / 2.0, height: BOTTOM_MARGIN))
        connectButton.backgroundColor = BlueColor
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        
        settingsButton = UIButton(frame: CGRect(origin: CGPoint(x: view.frame.width / 2.0, y: connectButton.frame.origin.y), size: connectButton.frame.size))
        settingsButton.backgroundColor = UIColor.lightGray
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        
        // Add views.
        view.addSubview(table)
        view.addSubview(connectButton)
        view.addSubview(settingsButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Get information from backend.
        getChats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getChats() {
        pushSpinner(message: "", frame: table.frame)
        
        // Make request to backend to get all of the user's chats.
        API.getUsersChats(userId: Cache.loadUser().id, completionHandler: {
            (response, chats) -> Void in
            
            self.removeSpinner()
            
            if response != URLResponse.Success {
                self.pushAlertView(title: "Error", message: "Check your internet connection.")
                return
            }

            self.chats = chats!
            self.table.reloadData()
        })
    }
    
    func connectButtonPressed(sender: UIButton!) {
        let connect = ConnectVC()
        navigationController?.pushViewController(connect, animated: true)
    }
    
    func settingsButtonPressed(sender: UIButton!) {
        let settings = SettingsVC()
        navigationController?.pushViewController(settings, animated: true)
    }
    
    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.loadChat(chat: chat, user: Cache.loadUser())
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatVC()
        chatVC.chat = chats[indexPath.row]
        navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            pushAlertActionView(title: "Are you sure?", message: "This action cannot be undone.", handler: {
                _ in
                
                let chat = self.chats[indexPath.row]
                self.pushSpinner(message: "", frame: self.table.frame)
                API.removeUserFromChat(userId: Cache.loadUser().id, chatId: chat.id, completionHandler: {
                    (response) in
                    self.removeSpinner()
                    
                    if response != URLResponse.Success {
                        self.pushAlertView(title: "Error", message: "Check your internet connection.")
                    }
                    
                    Cache.removeNotifications(chatId: chat.id)
                    self.chats.remove(at: indexPath.row)
                    self.table.reloadData()
                })
            })
        }
    }
}

