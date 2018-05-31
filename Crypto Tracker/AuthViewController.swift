//
//  AuthViewController.swift
//  Crypto Tracker
//
//  Created by Hisham Abraham on 5/30/18.
//  Copyright © 2018 Hisham Abraham. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       view.backgroundColor = UIColor.black
        presentAuth() 
    }
    
    func presentAuth() {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Your crypto is protected by biometrics") { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let cryptoTableVC = CryptoTableViewController()
                    let navController = UINavigationController(rootViewController: cryptoTableVC)
                    self.present(navController, animated: true, completion: nil)
                }
            }else {
                self.presentAuth()
            }
        }
    }


}
