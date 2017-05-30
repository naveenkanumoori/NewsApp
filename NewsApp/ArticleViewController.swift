//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/29/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var articleImage: UIImageView!
    
    @IBOutlet weak var articleDesc: UILabel!
    
    @IBOutlet weak var articleTitle: UILabel!
    
    var article: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Article"
        articleTitle.text = article.value(forKey: "title") as? String
        articleDesc.text = article.value(forKey: "description") as? String
        articleDesc.lineBreakMode = NSLineBreakMode.byWordWrapping;
        articleDesc.numberOfLines = 0;
        articleDesc.adjustsFontSizeToFitWidth = true
        
        let articleImageURL = article.value(forKey: "urlToImage") as? String
        articleImage.image = nil
        URLSession.shared.dataTask(with: NSURL(string: articleImageURL!)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.articleImage.image = image
                if image == nil{
                    self.articleImage.image = UIImage.init(named: "defaultSource")
                }
            })
            
        }).resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
