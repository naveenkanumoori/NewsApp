//
//  FirstViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/28/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit
import Firebase

class SourcesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let service = ServiceClass.sharedInstance
    var sources: [NSDictionary] = []
    
    var selectedSource:NSDictionary!
    
    @IBOutlet weak var sourcesCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sourcesCV.register(UINib.init(nibName: "SourceCollectionViewCell", bundle: self.nibBundle), forCellWithReuseIdentifier: "sourceCell")
        
        getSources()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func getSources() {
        service.getSources { (response) in
            let rawSources = response.value(forKey: "sources") as! NSArray
            for index in 0...rawSources.count-1 {
                self.sources.append(rawSources[index] as! NSDictionary)
            }
            self.sourcesCV.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sourceCell", for: indexPath) as! SourceCollectionViewCell
        let source = sources[indexPath.row]
        let companyUrl = source.value(forKey: "url") as? String
        let urlArr = companyUrl?.components(separatedBy: "//")
        let urlArr1 = (urlArr?[1])!.components(separatedBy: "/")
        let url = urlArr1[0]
        let logoUrl = "http://logo.clearbit.com/"+url
        
        cell.sourceTitle.text = source.value(forKey: "name") as? String
        
        URLSession.shared.dataTask(with: NSURL(string: logoUrl)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                cell.sourceLogo.image = image
                if image == nil{
                    cell.sourceLogo.image = UIImage.init(named: "defaultSource")
                }
            })
            
        }).resume()
        
        //Cell Styling
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSource = sources[indexPath.row]
        self.performSegue(withIdentifier: "newsStories", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.11, height: collectionView.frame.width / 2.11)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsStories" {
            let dest = segue.destination as! StoriesViewController
            dest.source = selectedSource
        }
    }
}

