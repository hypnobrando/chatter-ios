//
//  SignIn.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class SignIn: UIViewController, UITextFieldDelegate {
    
    let TOP_MARGIN = CGFloat(100.0)
    let LEFT_MARGIN = CGFloat(45.0)
    let LABEL_HEIGHT = CGFloat(40.0)
    let LABEL_SPACE = CGFloat(20.0)
    
    var firstName = UITextField()
    var lastName = UITextField()
    var submit = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup main view.
        view.backgroundColor = UIColor.white
        
        // Setup views.
        firstName = TextField(frame: CGRect(x: LEFT_MARGIN, y: TOP_MARGIN, width: view.frame.width - 2 * LEFT_MARGIN, height: LABEL_HEIGHT), placeholder: "first name...")
        lastName = TextField(frame: CGRect(x: firstName.frame.origin.x, y: firstName.frame.origin.y + firstName.frame.height + LABEL_SPACE, width: firstName.frame.width, height: firstName.frame.height), placeholder: "last name...")
        firstName.delegate = self
        lastName.delegate = self
        submit = UIButton(frame: CGRect(x: LEFT_MARGIN, y: lastName.frame.origin.y + lastName.frame.height + LABEL_SPACE, width: lastName.frame.width, height: lastName.frame.height))
        submit.backgroundColor = UIColor.blue
        submit.setTitle("Submit", for: .normal)
        submit.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(firstName)
        self.view.addSubview(lastName)
        self.view.addSubview(submit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitButtonTapped(sender: UIButton!) {
        
        // Send data to backend.
        API.createUser(firstName: firstName.text!, lastName: lastName.text!, completion_handler: {
            (response, contact) -> Void in
            
            if response != URLResponse.Success {
                // Do shit.
                print(response)
                return
            }
            
            // Cache the user info.
            self.saveCacheToAppDelegate(cache: Cache.cacheUser(contact: Contact(firstName: self.firstName.text!, lastName: self.lastName.text!, id: "")))
            
            // Transition to next vc.
            let nav = UINavigationController()
            let home = Home()
            nav.viewControllers = [home]
            self.present(nav, animated: true, completion: nil)
        })
    }
    
    // UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

}
