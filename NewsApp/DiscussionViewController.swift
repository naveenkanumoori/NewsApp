//
//  DiscussionViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/29/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit
import Firebase

class DiscussionViewController: UIViewController, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var listOfMessages:[NSDictionary] = []
    let imagePicker = UIImagePickerController()
    var ref: DatabaseReference!
    let storage = Storage.storage()
    var imagesRef: StorageReference!
    
    @IBOutlet weak var discussionTable: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        let messageText = self.messageTextField.text
        if messageText!.isEmpty{
            
        }else{
            self.messageTextField.text = nil
            self.messageTextField.resignFirstResponder()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            let dateString = formatter.string(from: date)
            let newRef = ref.child("messages").childByAutoId()
            let message: NSDictionary = [
                "type" : "TEXT",
                "text" : messageText ?? "",
                "createdAt" : dateString,
                "createdBy" : Auth.auth().currentUser?.uid ?? "",
                "id" : newRef.key
            ]
            newRef.setValue(message)
        }
    }
    
    @IBAction func sendImage(_ sender: AnyObject) {
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
        let date = Date()
        let formatter = DateFormatter()
        let dateString = formatter.string(from: date)
        let newRef = ref.child("messages").childByAutoId()
        let newImage = imagesRef.child(newRef.key+".png")
        
        newImage.putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let downloadURL = metadata.downloadURL()
            let message: NSDictionary = [
                "type" : "IMAGE",
                "createdAt" : dateString,
                "createdBy" : Auth.auth().currentUser?.uid ?? "",
                "id" : newRef.key,
                "imageUrl" : downloadURL?.absoluteString ?? ""
            ]
            newRef.setValue(message)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        
        ref = Database.database().reference()
        imagesRef = storage.reference().child("images")
        
        //Register Custom cell to display image and Text messages separately
        self.discussionTable.register(UINib(nibName:"TextMessageCell", bundle:nil), forCellReuseIdentifier: "textCell")
        self.discussionTable.register(UINib(nibName:"ImageMessageCell", bundle:nil), forCellReuseIdentifier: "imageCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        ref.child("messages").observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.listOfMessages.append(value)
            self.discussionTable.reloadData()
        })
        
        //Image as BG
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height-49
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = listOfMessages[indexPath.row]
        let type = message.value(forKey: "type") as? String
        if type == "TEXT" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextMessageCell
//            cell.senderName.text = message.getUserFName()+" "+message.getUserLName()
            let createdBy = message.value(forKey: "createdBy") as? String
            ref.child("profiles").child(createdBy!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let firstname = value?["firstname"] as? String
                let lastname = value?["lastname"] as? String
                cell.senderName.text = firstname!+" "+lastname!
                
            })
            cell.createdTime.text = message.value(forKey: "createdAt") as? String
            cell.messageText.text = message.value(forKey: "text") as? String
            
            cell.dataView.layer.cornerRadius = 10.0
            cell.dataView.layer.borderColor = UIColor.gray.cgColor
            cell.dataView.layer.borderWidth = 0.5
            cell.dataView.clipsToBounds = true
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageMessageCell

            let createdBy = message.value(forKey: "createdBy") as? String
            ref.child("profiles").child(createdBy!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let firstname = value?["firstname"] as? String
                let lastname = value?["lastname"] as? String
                cell.senderName.text = firstname!+" "+lastname!
                
            })
            cell.createdTime.text = message.value(forKey: "createdAt") as? String
            
            let imageUrl = message.value(forKey: "imageUrl") as? String
            cell.imageMessage.image = nil
            URLSession.shared.dataTask(with: NSURL(string: imageUrl!)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    let image = UIImage(data: data!)
                    cell.imageMessage.image = image
                    
                })
                
            }).resume()
            
            cell.dataView.layer.cornerRadius = 10.0
            cell.dataView.layer.borderColor = UIColor.gray.cgColor
            cell.dataView.layer.borderWidth = 0.5
            cell.dataView.clipsToBounds = true
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = listOfMessages[indexPath.row]
        let type = message.value(forKey: "type") as? String
        if type == "TEXT" {
            let width = tableView.frame.width - 24.0
            let message = listOfMessages[indexPath.row]
            let text = message.value(forKey: "text") as? String
            return 55.0 + (heightForView(text: text!, font: UIFont (name: "HelveticaNeue", size: 16)!, width: width))
        }else{
            return 150
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        let label:UILabel = UILabel(frame: frame)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }


}
