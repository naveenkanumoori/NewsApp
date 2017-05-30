//
//  LoginViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/28/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    
    @IBAction func loginPageAction(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 1001{
            if emailTF.text! == "" || passwordTF.text! == ""{
                let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
                let email = emailTF.text!
                let password = passwordTF.text!
                
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user,error) in
                    if error == nil {
                        self.performSegue(withIdentifier: "fromLogin", sender: self)
                    } else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }else{
            self.performSegue(withIdentifier: "register", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
