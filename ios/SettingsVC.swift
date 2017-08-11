//
//  SettingsVC.swift
//  ios
//
//  Created by Brandon Price on 8/9/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class SettingsVC: ChatterVC {
    
    let LEFT_MARGIN : CGFloat = 45.0
    let TOP_MARGIN : CGFloat = 100.0
    let BUTTON_HEIGHT : CGFloat = 45.0
    
    var deleteAccountButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        deleteAccountButton = UIButton(frame: CGRect(x: LEFT_MARGIN, y: TOP_MARGIN, width: view.frame.width - 2 * LEFT_MARGIN, height: BUTTON_HEIGHT))
        deleteAccountButton.backgroundColor = BlueColor
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonPressed), for: .touchUpInside)
        
        view.addSubview(deleteAccountButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteAccountButtonPressed(sender: UIButton!) {
        pushSpinner(message: "", frame: view.frame)
        API.deleteUser(userId: Cache.loadUser().id, completionHandler: {
            response -> Void in
            self.removeSpinner()
            
            if response != URLResponse.Success {
                print(response)
                return
            }
            
            Cache.clear()
            let signInVC = SignInVC()
            self.present(signInVC, animated: true, completion: nil)
        })
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
