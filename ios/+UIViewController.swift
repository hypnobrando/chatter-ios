//
//  +UIViewController.swift
//  ios
//
//  Created by Brandon Price on 8/2/17.
//  Copyright © 2017 Brandon Price. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func pushNotificationReceived(payload: [String:Any]) {
        print(payload)
    }
    
    func pushAlertView(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func pushAlertActionView(title: String, message: String, handler: @escaping ((UIAlertAction) -> Void)) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: handler))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func pushSpinner(message: String, frame: CGRect) {
        let spinnerView = Spinner(frame: frame)
        spinnerView.backgroundColor = UIColor.clear
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.frame = CGRect(x: spinnerView.bounds.midX - spinner.frame.width / 2.0, y: spinnerView.bounds.midY - spinner.frame.height / 2.0, width: spinner.frame.width, height: spinner.frame.height)
        spinner.startAnimating()
        
        spinnerView.addSubview(spinner)
        view.addSubview(spinnerView)
    }
    
    func removeSpinner() {
        _ = view.subviews.map({
            (subView) -> Void in
            if let spinner = subView as? Spinner {
                spinner.removeFromSuperview()
            }
        })
    }
}
