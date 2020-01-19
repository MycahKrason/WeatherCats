//
//  UIImageViewExtension.swift
//  WeatherCats
//
//  Created by Mycah on 1/12/20.
//  Copyright © 2020 Mycah Krason. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {

    
    func downloadAllImagesToCache(weatherDataArray: [WeatherData]){
        
        for weatherObject in weatherDataArray{
            
            //Download everything for Snowby
            if let url = URL(string: weatherObject.snowbyOutfitURL) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                    //print("RESPONSE FROM API: \(response)")
                    if error != nil {
                        print("ERROR LOADING IMAGES FROM URL: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data {
                            if let downloadedImage = UIImage(data: data) {
                                print("DOWNLOADED SNOWBY!\n")
                                imageCache.setObject(downloadedImage, forKey: NSString(string: weatherObject.snowbyOutfitURL))
                            }
                        }
                    }
                }).resume()
            }
            
            
            //Donwload everthing for Kobra
            if let url = URL(string: weatherObject.kobraOutfitURL) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                    //print("RESPONSE FROM API: \(response)")
                    if error != nil {
                        print("ERROR LOADING IMAGES FROM URL: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data {
                            if let downloadedImage = UIImage(data: data) {
                                print("DOWNLOADED KOBRA!\n")
                                imageCache.setObject(downloadedImage, forKey: NSString(string: weatherObject.kobraOutfitURL))
                            }
                        }
                    }
                }).resume()
            }
            
        }
        
    }
    
    func imageFromServerURL(_ URLString: String, placeHolder: UIImage?, completion: @escaping (_ error: String, _ imageFound: Bool) -> ()){
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            completion("", true)
            return
        }
        
        if URLString == ""{
            DispatchQueue.main.async {
                self.image = UIImage(named: "CATZ")
                completion("Error", false)
            }
            return
        }

        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(error)")
                    DispatchQueue.main.async {
                        self.image = UIImage(named: "CATZ")
                        completion("Error", false)
                        
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            
                            self.image = downloadedImage
                            completion("", true)
                        }
                    }
                }
            }).resume()
        }
    }
}
