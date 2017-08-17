//
//  ChatInfoVCViewController.swift
//  ios
//
//  Created by Brandon Price on 8/16/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class ChatInfoVC: ChatterVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let LEFT_MARGIN : CGFloat = 45.0
    let SPACE : CGFloat = 15.0
    let BUTTON_HEIGHT : CGFloat = 45.0
    
    var nameTextField = UITextField()
    var saveButton = UIButton()
    var addUserButton = UIButton()
    var table = UITableView()
    var chat = Chat()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField = UITextField(frame: CGRect(x: LEFT_MARGIN, y: navigationController!.navigationBar.frame.maxY + SPACE, width: view.frame.width - 2.0 * LEFT_MARGIN, height: BUTTON_HEIGHT))
        if chat.title != "" {
            nameTextField.text = chat.title
        }
        nameTextField.placeholder = "No Title"
        nameTextField.borderStyle = .roundedRect
        nameTextField.textAlignment = .center
        nameTextField.delegate = self
        saveButton = UIButton(frame: CGRect(x: nameTextField.frame.origin.x, y: nameTextField.frame.maxY + SPACE, width: nameTextField.frame.width, height: nameTextField.frame.height))
        saveButton.backgroundColor = BlueColor
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        addUserButton = UIButton(frame: CGRect(x: saveButton.frame.origin.x, y: saveButton.frame.maxY + SPACE, width: nameTextField.frame.width, height: nameTextField.frame.height))
        addUserButton.backgroundColor = BlueColor
        addUserButton.setTitle("Add User", for: .normal)
        addUserButton.addTarget(self, action: #selector(addUserButtonPressed), for: .touchUpInside)
        table = UITableView(frame: CGRect(x: 0.0, y: addUserButton.frame.maxY + SPACE, width: view.frame.width, height: view.frame.height - (addUserButton.frame.maxY + SPACE)))
        table.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table.delegate = self
        table.dataSource = self
        table.allowsSelection = false
        
        view.addSubview(nameTextField)
        view.addSubview(saveButton)
        view.addSubview(addUserButton)
        view.addSubview(table)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        table.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addUserButtonPressed(sender: UIButton!) {
        let connectVC = ConnectVC()
        connectVC.chatType = .ExistingChat
        connectVC.existingChat = chat
        
        navigationController!.pushViewController(connectVC, animated: true)
    }
    
    func saveButtonPressed(sender: UIButton!) {
        let textFieldText = nameTextField.text == nil ? "" : nameTextField.text!
        
        pushSpinner(message: "", frame: view.frame)
        API.patchChat(userId: Cache.loadUser().id, chatId: chat.id, title: textFieldText, completionHandler: {
            (response) in
            self.removeSpinner()
            
            if response != URLResponse.Success {
                print(response)
                self.pushAlertView(title: "Error", message: "Check your internet connection.")
                return
            }
            
            let prevVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! ChatVC
            prevVC.chat.title = textFieldText
            prevVC.title = prevVC.chat.ChatNameGivenUser(user: Cache.loadUser())
            self.navigationController!.popViewController(animated: true)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = chat.users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.name.text = user.id == Cache.loadUser().id ? "You" : user.fullName()
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func willMove(toParentViewController parent: UIViewController?) {
        nameTextField.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
