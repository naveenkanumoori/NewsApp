//
//  StoriesViewController.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/29/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var source: NSDictionary!
    var listOfArticles: [NSDictionary] = []
    var selectedArticle: NSDictionary!
    @IBOutlet weak var articlesTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articlesTV.register(UINib.init(nibName: "ArticleTableViewCell", bundle: self.nibBundle), forCellReuseIdentifier: "articleCell")
        self.title = source.value(forKey: "name") as? String
        getStories()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func getStories() {
        let id = source.value(forKey: "id") as? String
        ServiceClass.sharedInstance.getStories(source: id!) { (response) in
            let rawArticles = response.value(forKey: "articles") as! NSArray
            for index in 0...rawArticles.count-1 {
                self.listOfArticles.append(rawArticles[index] as! NSDictionary)
            }
            self.articlesTV.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell
        
        let article = listOfArticles[indexPath.row]
        
        cell.articleTitle.text = article.value(forKey: "title") as? String
        let author = article.value(forKey: "author") as? String
        cell.articleAuthor.text = author
        
        let articleImage = article.value(forKey: "urlToImage") as? String
        cell.articleImage.image = nil
        URLSession.shared.dataTask(with: NSURL(string: articleImage!)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                cell.articleImage.image = image
                if image == nil{
                    cell.articleImage.image = UIImage.init(named: "defaultSource")
                }
            })
            
        }).resume()
        
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedArticle = listOfArticles[indexPath.row]
        self.performSegue(withIdentifier: "details", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details"{
            let dest = segue.destination as! ArticleViewController
            dest.article = selectedArticle
        }
    }

}
