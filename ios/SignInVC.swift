//
//  SignIn.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class SignInVC: ChatterVC, UITextFieldDelegate {
    
    let TOP_MARGIN : CGFloat = 25.0
    let LEFT_MARGIN : CGFloat  = 55.0
    let LABEL_HEIGHT : CGFloat  = 40.0
    let LABEL_SPACE : CGFloat  = 20.0
    
    var logo = UIImageView()
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
        logo = UIImageView(image: UIImage(named: "key-hand-off"))
        logo.frame = CGRect(x: LEFT_MARGIN, y: TOP_MARGIN, width: view.frame.width - 2 * LEFT_MARGIN, height: view.frame.width - 2 * LEFT_MARGIN)
        firstName = TextField(frame: CGRect(x: LEFT_MARGIN, y: logo.frame.maxY + LABEL_SPACE, width: view.frame.width - 2 * LEFT_MARGIN, height: LABEL_HEIGHT), placeholder: "first name...")
        lastName = TextField(frame: CGRect(x: firstName.frame.origin.x, y: firstName.frame.maxY + LABEL_SPACE, width: firstName.frame.width, height: firstName.frame.height), placeholder: "last name...")
        firstName.delegate = self
        lastName.delegate = self
        submit = UIButton(frame: CGRect(x: LEFT_MARGIN, y: lastName.frame.maxY + LABEL_SPACE, width: lastName.frame.width, height: lastName.frame.height))
        submit.backgroundColor = BlueColor
        submit.setTitle("Submit", for: .normal)
        submit.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(logo)
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
            
        // Transition to next vc.
        let pin = PinVC()
        pin.completionHandler = {
            (newPin: String) -> Void in
            
            // Send data to backend.
            pin.pushSpinner(message: "", frame: pin.view.frame)
            API.createUser(firstName: self.firstName.text!, lastName: self.lastName.text!, apnToken: apnToken, completionHandler: {
                (response, contact) -> Void in
                pin.removeSpinner()
                
                if response != URLResponse.Success {
                    // Do shit.
                    self.pushAlertView(title: "Error", message: "Check your internet connection.")
                    return
                }
                
                // Cache the user info.
                Cache.cacheUser(contact: contact!)
                
                let nav = UINavigationController()
                let home = HomeVC()
                nav.viewControllers = [home]
                Cache.setPin(pin: newPin)
                pin.present(nav, animated: true, completion: nil)
            })
        }

        self.present(pin, animated: true, completion: nil)
        
    }
    
    // UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

}
