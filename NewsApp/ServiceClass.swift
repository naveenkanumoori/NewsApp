//
//  ServiceClass.swift
//  NewsApp
//
//  Created by Naveen Kumar on 5/28/17.
//  Copyright © 2017 Naveen Kumar. All rights reserved.
//

import Foundation
import Alamofire

class ServiceClass: NSObject {
    static let sharedInstance = ServiceClass()
    
    func getSources(completion handler: @escaping (NSDictionary) -> Void) {
        
        Alamofire.request("https://newsapi.org/v1/sources?language=en").responseJSON { response in
            if let JSON = response.result.value as? NSDictionary{
                handler(JSON)
            }
        }
    }
    
    func getStories(source: String, completion handler: @escaping (NSDictionary) -> Void) {
        
        Alamofire.request("https://newsapi.org/v1/articles?source="+source+"&apiKey=d38e70c419264d21bf97252d9c5ec320").responseJSON { response in
            if let JSON = response.result.value as? NSDictionary{
                handler(JSON)
            }
        }
    }
    
}
