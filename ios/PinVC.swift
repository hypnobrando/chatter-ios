//
//  pinVC.swift
//  ios
//
//  Created by Brandon Price on 8/10/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class PinVC: ChatterVC, UITextFieldDelegate {

    let LEFT_MARGIN : CGFloat = 45.0
    let TOP_MARGIN : CGFloat = 160.0
    let TEXTFIELD_HEIGHT : CGFloat = 60.0

    var textField = UITextField()
    var completionHandler : ((String) -> Void?)? = nil
    var placeholder = "enter pin..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = BlueColor
        textField = UITextField(frame: CGRect(x: LEFT_MARGIN, y: TOP_MARGIN, width: view.frame.width - 2.0 * LEFT_MARGIN, height: TEXTFIELD_HEIGHT))
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 56.0)
        textField.isSecureTextEntry = true
        textField.tintColor = UIColor.clear
        textField.textColor = UIColor.white
        textField.keyboardAppearance = .alert
        textField.delegate = self
        let placeholderAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 16.0) // Note the !
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes:placeholderAttributes)
        let disablerView = UIView(frame: textField.frame)
        disablerView.backgroundColor = UIColor.clear
        
        // Add subviews.
        view.addSubview(textField)
        view.addSubview(disablerView)
        
        // Open keyboard.
        textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        
        if newLength == 4 {
            checkPin(pin: textField.text! + string)
        }
        
        return newLength <= 4
    }
    
    func checkPin(pin: String) {
        let currentPin = Cache.getPin()
        
        if currentPin == nil {
            if completionHandler != nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500), execute: {
                    self.completionHandler!(pin)
                })
            }
            return
        }
        
        if currentPin! == pin {
            if self.completionHandler != nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500), execute: {
                    self.completionHandler!(pin)
                })
            }
            return
        }
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
