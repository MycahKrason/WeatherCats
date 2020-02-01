//
//  RetrieveWeatherData.swift
//  WeatherCats
//
//  Created by Mycah on 12/22/19.
//  Copyright © 2019 Mycah Krason. All rights reserved.
//

//NOTE: The Weather API that I am using requires to calls, one that returns an general index of information pertaining to your location, and a second call which provides specific Weather information

import Foundation

class RetrieveWeatherData{
    
    private var weatherDataArray : [WeatherData] = [WeatherData]()
    
    func getWeatherURLForForecast(lattitude: String, longitude: String, completion: @escaping (_ error: String, _ urlForForecast: [WeatherData]) -> ()){
        
        //First call for general index
        let urlString = "https://api.weather.gov/points/\(lattitude),\(longitude)"
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

                    if let weatherForecast = json["properties"] as? Dictionary<String, Any>{
                        
                        if weatherForecast["forecast"] != nil{
                            
                            //Second Call for specifics
                            let urlString = weatherForecast["forecast"] as! String
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

                                        if let retrievedProperties = json["properties"] as? [String: Any] {
                                            
                                            if let periods = retrievedProperties["periods"] as? Array<Dictionary<String, Any>> {
                                                
                                                print(periods[1])
                                                
                                                for weatherData in periods{
                                                    
                                                    let weatherArrayObject = WeatherData()
                                                    
                                                    weatherArrayObject.name = weatherData["name"] as! String
                                                    weatherArrayObject.isDaytime = weatherData["isDaytime"] as! Int
                                                    weatherArrayObject.shortForecast = weatherData["shortForecast"] as! String
                                                    weatherArrayObject.temperature = String(format: "%@", weatherData["temperature"] as! CVarArg)
                                                    
                                                    self.weatherDataArray.append(weatherArrayObject)
                                                    
                                                }
                                                
                                                completion("", self.weatherDataArray)
                                            }
                                            
                                        }
                                        
                                    }

                                }catch let error{
                                    
                                    print(error)

                                }
                                
                            }
                            
                            task.resume()
                            
                        }
                         
                    }
                    
                }
                
            }catch let error{
                
                print(error)

            }

        }
        task.resume()
        
    }
    
}

