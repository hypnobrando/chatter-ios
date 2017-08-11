//
//  ChatterVC.swift
//  ios
//
//  Created by Brandon Price on 8/11/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import UIKit

class ChatterVC: UIViewController {
    
    let BlueColor = UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Status bar
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Background
        view.backgroundColor = UIColor.white
        
        // Navigation bar
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 21.0), NSForegroundColorAttributeName: UIColor.white]
        navBarAppearance.barTintColor = BlueColor
        navBarAppearance.tintColor = UIColor.white
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.tintColor = UIColor.white
    }
}
