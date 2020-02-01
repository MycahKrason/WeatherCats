//
//  RetrieveCatOutfits.swift
//  WeatherCats
//
//  Created by Mycah on 1/11/20.
//  Copyright © 2020 Mycah Krason. All rights reserved.
//

import Foundation

class RetrieveCatOutfits{

    private var catOutfitArray : [WeatherData] = [WeatherData]()
    
    func getCatOutfitsWithWeatherData(catName: String, weatherArray: [WeatherData], completion: @escaping (_ error: String, _ catOutfitsWithWeather: [WeatherData]) -> ()){
        
        let urlString = Private().URL_FOR_CAT_IMAGES
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil{

                return

            }
            
            guard let jsonData = data else {return}
            
            do{
                
                
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] {
                    
                    //Get the Temperature for each object in weather array
                    for temp in weatherArray{
                        
                        var tempRange : String = ""
                        
                        //Need to convert the Temperature to an Int
                        if let retrievedTemp = NumberFormatter().number(from: temp.temperature)?.intValue{
                        
                            //Find the temperature range
                            if retrievedTemp >= 96{
                                tempRange = "96+"
                            }else if retrievedTemp >= 86 && retrievedTemp <= 95{
                                tempRange = "86-95"
                            }else if retrievedTemp >= 76 && retrievedTemp <= 85{
                                tempRange = "76-85"
                            }else if retrievedTemp >= 66 && retrievedTemp <= 75{
                                tempRange = "66-75"
                            }else if retrievedTemp >= 56 && retrievedTemp <= 65{
                                tempRange = "56-65"
                            }else if retrievedTemp >= 46 && retrievedTemp <= 55{
                                tempRange = "46-55"
                            }else if retrievedTemp <= 45{
                                tempRange = "45-"
                            }
                            
                            //TODO: Rename these variables
                            if let catTemperature = json[tempRange] as? Dictionary<String, Any>{
                                
                                //Find out if the outfit is for rain or clear sky
                                var forecast : String?
                                let shortForecast = temp.shortForecast
                                if shortForecast.contains("Rain"){
                                    forecast = "rain"
                                    temp.isRaining = true
                                }else{
                                    forecast = "clear"
                                    temp.isRaining = false
                                }
                                
                                
                                if let catForecast = catTemperature["clear"] as? Dictionary<String, Any>{
                                    
                                    //Get outfits for Snowby
                                    if let catOutfitInformation = catForecast["snowby"] as? Array<Dictionary<String,Any>>{
                                                                        
                                            temp.snowbyOutfitURL = catOutfitInformation[0]["outfitURL"] as! String
                                            temp.snowbyOutfitExplanation = catOutfitInformation[0]["outfitExplanation"] as! String
                                          
                                    }
                                    
                                    //Get outfits for Kobra
                                    if let catOutfitInformation = catForecast["kobra"] as? Array<Dictionary<String,Any>>{

                                            temp.kobraOutfitURL = catOutfitInformation[0]["outfitURL"] as! String
                                            temp.kobraOutfitExplanation = catOutfitInformation[0]["outfitExplanation"] as! String

                                    }
                                    
                                }
                                
                            }
                            
                            
                        }else{
                            //Wasn't able to convert the Retrieved temperature to an Int
                        }
                    }//End of for loop
                        
                    completion("", weatherArray)
                        
                }
                
            }catch let error{
                
                print(error)

            }

        }
        task.resume()
        
    }
}
