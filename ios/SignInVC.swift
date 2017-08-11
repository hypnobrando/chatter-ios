//
//  SignIn.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class SignInVC: UIViewController, UITextFieldDelegate {
    
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
        Cache.removePin()
        
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
        
        if firstName.text == nil || firstName.text == "" || lastName.text == nil || lastName.text == "" {
            // TODO - warn user.
            pushAlertView(title: "Error", message: "Please enter your full name")
            return
        }
        
        let apnToken = Cache.loadUser().apnToken

        if apnToken == "" {
            // TODO - warn user.
            pushAlertView(title: "Error", message: "Please enable push notifications")
            return
        }
        
        // Send data to backend.
        API.createUser(firstName: firstName.text!, lastName: lastName.text!, apnToken: apnToken, completionHandler: {
            (response, contact) -> Void in
            
            if response != URLResponse.Success {
                // Do shit.
                self.pushAlertView(title: "Error", message: "Check your internet connection \(response), \(self.firstName.text!), \(self.lastName.text!), \(apnToken)")
                return
            }
            
            // Cache the user info.
            Cache.cacheUser(contact: contact!)
            
            // Transition to next vc.
            let pin = PinVC()
            pin.completionHandler = {
                (newPin: String) -> Void in
                let nav = UINavigationController()
                let home = HomeVC()
                nav.viewControllers = [home]
                Cache.setPin(pin: newPin)
                pin.present(nav, animated: true, completion: nil)
            }

            self.present(pin, animated: true, completion: nil)
        })
    }
    
    // UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

}
