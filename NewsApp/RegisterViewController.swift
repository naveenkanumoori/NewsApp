//
//  RegisterViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/28/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var emailIdTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var ref : DatabaseReference!
    
    @IBAction func registerPageAction(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 1003{
            if lastNameTF.text == "" || firstNameTF.text! == "" || emailIdTF.text! == "" || passwordTF.text! == ""{
                let alertController = UIAlertController(title: "Error", message: "Please enter valid details", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
                let firstname = firstNameTF.text!
                let lastname = lastNameTF.text!
                let email = emailIdTF.text!
                let password = passwordTF.text!
                
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user,error) in
                    if error == nil {
                        let key = user?.uid
                        let user = [
                            "uid"       : key!,
                            "firstname" : firstname,
                            "lastname"  : lastname,
                            "email"     : email,
                            "password"  : password
                        ]
                        self.ref.child("profiles").child(key!).setValue(user)
                        self.performSegue(withIdentifier: "fromRegister", sender: self)
                    } else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }else{
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
