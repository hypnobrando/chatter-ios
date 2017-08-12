//
//  SettingsVC.swift
//  ios
//
//  Created by Brandon Price on 8/9/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class SettingsVC: ChatterVC, UITextFieldDelegate {
    
    let LEFT_MARGIN : CGFloat = 45.0
    let TOP_MARGIN : CGFloat = 100.0
    let BUTTON_HEIGHT : CGFloat = 45.0
    let GAP : CGFloat = 10.0
    
    var firstName = UITextField()
    var lastName = UITextField()
    var saveButton = UIButton()
    var deleteAccountButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        firstName = UITextField(frame: CGRect(x: LEFT_MARGIN, y: TOP_MARGIN, width: view.frame.width - 2 * LEFT_MARGIN, height: BUTTON_HEIGHT))
        firstName.text = Cache.loadUser().firstName
        firstName.borderStyle = .roundedRect
        firstName.textAlignment = .center
        firstName.delegate = self
        lastName = UITextField(frame: CGRect(x: firstName.frame.minX, y: firstName.frame.maxY + GAP, width: firstName.frame.width, height: firstName.frame.height))
        lastName.text = Cache.loadUser().lastName
        lastName.borderStyle = .roundedRect
        lastName.textAlignment = .center
        lastName.delegate = self
        saveButton = UIButton(frame: CGRect(x: firstName.frame.minX, y: lastName.frame.maxY + 4.0 * GAP, width: firstName.frame.width, height: firstName.frame.height))
        saveButton.backgroundColor = BlueColor
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveAccountButtonPressed), for: .touchUpInside)
        deleteAccountButton = UIButton(frame: CGRect(x: firstName.frame.minX, y: saveButton.frame.maxY + 2.0 * GAP, width: firstName.frame.width, height: firstName.frame.height))
        deleteAccountButton.backgroundColor = UIColor.red
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonPressed), for: .touchUpInside)
        
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(saveButton)
        view.addSubview(deleteAccountButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveAccountButtonPressed(send: UIButton!) {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        self.pushSpinner(message: "", frame: self.view.frame)
        API.patchUser(userId: Cache.loadUser().id, firstName: firstName.text!, lastName: lastName.text!, completionHandler: {
            (response, user) -> Void in
            self.removeSpinner()
            
            if response != URLResponse.Success {
                self.pushAlertView(title: "Couldn't save the user information at this time", message: "Please try again later.")
                return
            }
            
            Cache.cacheUser(contact: user!)
        })
    }
    
    func deleteAccountButtonPressed(sender: UIButton!) {
        pushAlertActionView(title: "Delete", message: "Are you sure you want to delete your account?") {
            (UIAlertAction) in
            self.pushSpinner(message: "", frame: self.view.frame)
            API.deleteUser(userId: Cache.loadUser().id, completionHandler: {
                response -> Void in
                self.removeSpinner()
                
                if response != URLResponse.Success {
                    self.pushAlertView(title: "Error", message: "Check your internet connection.")
                    return
                }
                
                Cache.clear()
                let signInVC = SignInVC()
                self.present(signInVC, animated: true, completion: nil)
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
