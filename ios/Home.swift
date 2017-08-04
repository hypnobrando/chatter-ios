//
//  ViewController.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class Home: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let BOTTOM_MARGIN : CGFloat = 50.0
    
    var contacts = [Contact]()
    var table = UITableView()
    var connectButton = UIButton()
    var settingsButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up background.
        navigationController?.navigationBar.topItem?.title = "Home"
        view.backgroundColor = UIColor.lightGray
        
        // Setup views.
        table = UITableView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height - BOTTOM_MARGIN))
        table.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table.dataSource = self
        table.delegate = self
        
        connectButton = UIButton(frame: CGRect(x: view.frame.origin.x, y: view.frame.maxY - BOTTOM_MARGIN, width: view.frame.width / 2.0, height: BOTTOM_MARGIN))
        connectButton.backgroundColor = UIColor.blue
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        
        settingsButton = UIButton(frame: CGRect(origin: CGPoint(x: view.frame.width / 2.0, y: connectButton.frame.origin.y), size: connectButton.frame.size))
        settingsButton.backgroundColor = view.backgroundColor
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        
        // Get information from backend.
        contacts = getContacts()
        
        // Add views.
        view.addSubview(table)
        view.addSubview(connectButton)
        view.addSubview(settingsButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getContacts() -> [Contact] {
        return [Contact(firstName: "Galt", lastName: "MacDermot", id: "1"), Contact(firstName: "Jacob", lastName: "Kim", id: "2")]
    }
    
    func connectButtonPressed(sender: UIButton!) {
        let connect = Connect()
        navigationController?.pushViewController(connect, animated: true)
    }
    
    func settingsButtonPressed(sender: UIButton!) {
        print("SETTINGS BUTTON CLICKED")
    }
    
    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.name.text = contact.fullName()
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = Chat()
        chat.incomingContact = contacts[indexPath.row]
        navigationController?.pushViewController(chat, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

