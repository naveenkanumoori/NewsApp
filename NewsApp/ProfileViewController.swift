//
//  ProfileViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/29/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    var ref: DatabaseReference!
    let storage = Storage.storage()
    var imagesRef: StorageReference!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var firstName: UILabel!
    
    @IBOutlet weak var lastName: UILabel!
    
    @IBOutlet weak var emailId: UILabel!
    
    @IBOutlet weak var password: UILabel!
    
    @IBAction func editAction(_ sender: Any) {
        let button = sender as! UIButton
        switch button.tag {
            
        case 3001:
            let isCameraAvailable:Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
            
            let uialertController:UIAlertController = UIAlertController(title: "Select", message: nil, preferredStyle: .actionSheet)
            
            let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (_) in
                self.launchImagePicker(type: "gallery")
            }
            uialertController.addAction(galleryAction)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
                self.launchImagePicker(type: "camera")
            }
            
            if isCameraAvailable {
                uialertController.addAction(cameraAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in}
            uialertController.addAction(cancelAction)
            
            self.present(uialertController, animated: true, completion: {})
            
            break
            
            
        case 3002:
            updateField(key: "fname")
            break
            
            
        case 3003:
            updateField(key: "lname")
            break
            
            
            
        case 3005:
            updateField(key: "pwd")
            break
            
            
        default: break
            
        }
    }
    
    //Launch Image picker based on type
    func launchImagePicker(type:String) {
        if type == "gallery" {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }else{
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.sendImageToServerToStore(image:pickedImage)
        }
        
    }
    
    //To add file
    func sendImageToServerToStore(image:UIImage) {
        let imageData = UIImagePNGRepresentation(image)

        let uid = Auth.auth().currentUser?.uid
        
        let newImage = imagesRef.child(uid!+".png")
        
        newImage.putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let downloadURL = metadata.downloadURL()
            let profileURL = downloadURL?.absoluteString ?? ""
            
            self.ref.child("profiles").child(uid!).child("profilePic").setValue(profileURL)
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            delegate.window = UIWindow(frame:UIScreen.main.bounds)
            let storyBoard = UIStoryboard(name:"Main", bundle:nil)
            let loginViewController: LoginViewController = storyBoard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
            delegate.window?.rootViewController = loginViewController
            delegate.window?.makeKeyAndVisible()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        imagesRef = storage.reference().child("profiles")
        
        imagePicker.delegate = self
        
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("profiles").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let firstname = value?["firstname"] as? String
            let lastname = value?["lastname"] as? String
            let email = value?["email"] as? String
            let password = value?["password"] as? String
            let profilePic = value?["profilePic"] as? String
            
            self.firstName.text = firstname
            self.lastName.text = lastname
            self.emailId.text = email
            self.password.text = password
            
            if profilePic != nil{
                URLSession.shared.dataTask(with: NSURL(string: profilePic!)! as URL, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        return
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        let image = UIImage(data: data!)
                        self.profileImage.image = image
                        
                    })
                    
                }).resume()
            }
            
        })
        
        //Image as background
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
        ref.child("profiles").child(uid!).observe(.childChanged, with: { (snapshot) in
            
            if snapshot.key == "firstname"{
                self.firstName.text = snapshot.value as? String
            }else if snapshot.key == "lastname"{
                self.lastName.text = snapshot.value as? String
            }else if snapshot.key == "password"{
                self.password.text = snapshot.value as? String
            }else if snapshot.key == "profilePic"{
                let url = snapshot.value as? String
                URLSession.shared.dataTask(with: NSURL(string: url!)! as URL, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        return
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        let image = UIImage(data: data!)
                        self.profileImage.image = image
                        
                    })
                    
                }).resume()
            }
        })
    }
    
    func updateField(key: String) {
        
        var title: String = ""
        var message: String = ""
        var child: String = ""
        
        if key == "fname" {
            title = "Firstname"
            message = "Please enter your firstname"
            child = "firstname"
        }else if key == "lname"{
            title = "Lastname"
            message = "Please enter your lastname"
            child = "lastname"
        }else if key == "pwd"{
            title = "Password"
            message = "Please enter your password"
            child = "password"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Update", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                let uid = Auth.auth().currentUser?.uid
                
                if key == "pwd"{
                    Auth.auth().currentUser?.updatePassword(to: field.text!) { (error) in
                        if error == nil{
                            self.ref.child("profiles").child(uid!).child(child).setValue(field.text!)
                        }
                    }
                }else{
                    self.ref.child("profiles").child(uid!).child(child).setValue(field.text!)
                }
                
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
}
