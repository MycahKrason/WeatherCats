//
//  ViewController.swift
//  WeatherCats
//
//  Created by Mycah on 12/16/19.
//  Copyright © 2019 Mycah Krason. All rights reserved.
//

//TODO: Rain animation when first loaded
//TODO: Wind over 7mph - no skirt

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var MainView: UIView!
    @IBOutlet weak var catImage: UIImageView!
    @IBOutlet weak var snowbyBtnDisplay: UIButton!
    @IBOutlet weak var kobraBtnDisplay: UIButton!
    @IBOutlet weak var outfitExplanationDisplay: UILabel!
    @IBOutlet weak var rainBackgroundDisplay: UIImageView!
    @IBOutlet weak var nightBackgroundDisplay: UIImageView!
    @IBOutlet weak var dayDisplay: UILabel!
    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var forecastDisplay: UILabel!
    @IBOutlet weak var dayToggleBtnDisplay: UIButton!
    @IBOutlet weak var nightToggleImageDisplay: UIImageView!
    @IBOutlet weak var dayToggleImageDisplay: UIImageView!
    @IBOutlet weak var nightToggleBtnDisplay: UIButton!
    @IBOutlet weak var activityIndicatorDisplay: UIActivityIndicatorView!
    @IBOutlet weak var rightBtnDisplay: UIButton!
    @IBOutlet weak var leftBtnDisplay: UIButton!
    
    var weatherDataArray : [WeatherData] = [WeatherData]()
    var weatherDayCount = 0
    var dayTimeSelected : Bool?
    var isSnowby = true
    var catChosen : String?
    var contentHasLoaded = false
    var meowAudioPlayer : AVPlayer!
    var buttonClickAudioPlayer : AVPlayer!
    var spinAudioPlayer : AVPlayer!
    
    
    //User Defaults
    let defaults = UserDefaults.standard
    
    //Setting Location Manager
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set up location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        getAuthorized()
        
        //Show users that content is loading
        activityIndicatorDisplay.startAnimating()
        
        //Set up swipes
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        //Display which Cat has been chosen
        if defaults.bool(forKey: "isSnowby"){
            
            snowbyBtnDisplay.isUserInteractionEnabled = false
            kobraBtnDisplay.isUserInteractionEnabled = true
            snowbyBtnDisplay.titleLabel?.alpha = 1
            kobraBtnDisplay.titleLabel?.alpha = 0.4
            catChosen = "snowby"
            
        }else{
            
            snowbyBtnDisplay.isUserInteractionEnabled = true
            kobraBtnDisplay.isUserInteractionEnabled = false
            snowbyBtnDisplay.titleLabel?.alpha = 0.4
            kobraBtnDisplay.titleLabel?.alpha = 1
            catChosen = "kobra"
            
        }
        
        
        //Turn off all button functionality until content loads
        rightBtnDisplay.isUserInteractionEnabled = false
        leftBtnDisplay.isUserInteractionEnabled = false
        kobraBtnDisplay.isUserInteractionEnabled = false
        snowbyBtnDisplay.isUserInteractionEnabled = false
        dayToggleBtnDisplay.isUserInteractionEnabled = false
        nightToggleBtnDisplay.isUserInteractionEnabled = false
        contentHasLoaded = false
        
        rainBackgroundDisplay.alpha = 0
        rainBackgroundDisplay.loadGif(name: "rain")

    }
    
    
    //****************************************
    //****** MARK: Location Delegate Functions
    //****************************************
    
    //Make sure that we are authorized - then update location
    func getAuthorized(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
//                locationManager.startUpdatingLocation()
            }
        } else {
            print("Location services are not enabled")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // The user has given permission to your app
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {

            locationManager.requestLocation()
            currentLocation = locationManager
                            .location
            let lon = String(currentLocation.coordinate.longitude)
            let lat = String(currentLocation.coordinate.latitude)
            
            //TEST
//            let lat = "40.71728515625"
//            let lon = "-80.1403875901721"
            
            //Get the Weather Data
            RetrieveWeatherData().getWeatherURLForForecast(lattitude: lat, longitude: lon, completion: { error,
                result in
                
                //Now that we have the weather data, Get the Cat outfits
                if let safeCatChosen = self.catChosen{
                    
                    RetrieveCatOutfits().getCatOutfitsWithWeatherData(catName: safeCatChosen, weatherArray: result, completion: { error,
                                    result in
                                                 
                        //Returns all of the current weather and outfit data
                        DispatchQueue.main.async {
                            
                            //The weather Array will contain the outfits at this point
                            self.weatherDataArray = result
                            
                            //You will want to download all of the images so everything will be cached
                            self.tempForecastDayDisplay()
                            
                            //Turn on all of the buttons
                            self.rightBtnDisplay.isUserInteractionEnabled = true
                            self.leftBtnDisplay.isUserInteractionEnabled = true
                            self.dayToggleBtnDisplay.isUserInteractionEnabled = true
                            self.nightToggleBtnDisplay.isUserInteractionEnabled = true
                            self.contentHasLoaded = true
                        
                            
                            //TODO: Display the cat image - START HERE
                            if self.catChosen == "snowby"{
                                
                                self.kobraBtnDisplay.isUserInteractionEnabled = true
                            self.catImage.imageFromServerURL(self.weatherDataArray[self.weatherDayCount].snowbyOutfitURL, placeHolder: UIImage(named: "CATZ")) { (error, result) in
                                    
                                    self.activityIndicatorDisplay.stopAnimating()
                                    self.bounceImage(imageToBounce: self.catImage)
                                    
                                    //Display the outfit explanation
                                    self.outfitExplanationDisplay.text = self.weatherDataArray[self.weatherDayCount].snowbyOutfitExplanation
                                        
                                        
                                }
                            }else{
                                
                                self.snowbyBtnDisplay.isUserInteractionEnabled = true
                            self.catImage.imageFromServerURL(self.weatherDataArray[self.weatherDayCount].kobraOutfitURL, placeHolder: UIImage(named: "CATZ")) { (error, result) in
                                
                                    self.activityIndicatorDisplay.stopAnimating()
                                    self.bounceImage(imageToBounce: self.catImage)
                                    
                                    //Display the outfit explanation
                                    self.outfitExplanationDisplay.text = self.weatherDataArray[self.weatherDayCount].kobraOutfitExplanation
                                    
                                }
                            }
                            
                            //Play rain test
                            if self.weatherDataArray[self.weatherDayCount].isRaining{
                                self.rainBackgroundDisplay.alpha = 1
                            }else{
                                self.rainBackgroundDisplay.alpha = 0
                            }
                            
                            
                            //Download all of the images in the background
                            self.catImage.downloadAllImagesToCache(weatherDataArray: self.weatherDataArray)
                            
                        }
                    })
                }
            })
            
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
    }
    
    
    //******************************
    //****** MARK: General Functions
    //******************************
    
    func tempForecastDayDisplay(){
        
        //Show the Day, Temperature, and Forecast based on the Weather Data
        dayDisplay.text = weatherDataArray[weatherDayCount].name
        tempDisplay.text = "\(weatherDataArray[weatherDayCount].temperature)°F"
        forecastDisplay.text = self.weatherDataArray[weatherDayCount].shortForecast
        
        
        //Set the night and display buttons based on the whether it is daytime or night time
        if weatherDataArray[weatherDayCount].isDaytime == 1{
            
            //Day time
            self.dayToggleBtnDisplay.isEnabled = false
            self.dayTimeSelected = true
            self.nightToggleBtnDisplay.isEnabled = true
            
            //set the nightBackground Alpha to 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.nightBackgroundDisplay.alpha = 0
            }, completion: nil)
            
            //Change the text colors
            outfitExplanationDisplay.textColor = UIColor.darkGray
            
            //change the alpha of the images
            dayToggleImageDisplay.alpha = 1
            nightToggleImageDisplay.alpha = 0.2
            
        }else{
            
            //Night time
            self.nightToggleBtnDisplay.isEnabled = false
            self.dayTimeSelected = false
            self.dayToggleBtnDisplay.isEnabled = true
            
            //set the nightBackground Alpha to 1
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.nightBackgroundDisplay.alpha = 1
            }, completion: nil)
            
            //Change the text colors
            outfitExplanationDisplay.textColor = UIColor.white
            
            //change the alpha of the images
            dayToggleImageDisplay.alpha = 0.2
            nightToggleImageDisplay.alpha = 1
            
        }
        
    }
    
    func bounceImage(imageToBounce : UIImageView){
        
        //Bounce effect
        let bounds = imageToBounce.bounds
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            imageToBounce.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 80, height: bounds.size.height + 80)
        }) { (success: Bool) in
            if success{
                
                UIView.animate(withDuration: 0.2, animations: {
                    imageToBounce.bounds = bounds
                })
            }
        }
        
    }
    
    func displayCatImage(catName: String){
        
        if catName == "snowby"{
            self.catImage.imageFromServerURL(self.weatherDataArray[self.weatherDayCount].snowbyOutfitURL, placeHolder: UIImage(named: "CATZ")) { (error, result) in
                
                self.activityIndicatorDisplay.stopAnimating()
                self.bounceImage(imageToBounce: self.catImage)
                
                //Display the outfit explanation
                self.outfitExplanationDisplay.text = self.weatherDataArray[self.weatherDayCount].snowbyOutfitExplanation
                
            }
        }else{
            self.catImage.imageFromServerURL(self.weatherDataArray[self.weatherDayCount].kobraOutfitURL, placeHolder: UIImage(named: "CATZ")) { (error, result) in
                
                self.activityIndicatorDisplay.stopAnimating()
                self.bounceImage(imageToBounce: self.catImage)
                
                //Display the outfit explanation
                self.outfitExplanationDisplay.text = self.weatherDataArray[self.weatherDayCount].kobraOutfitExplanation
                
                
            }
        }
        
        //Play rain
        if self.weatherDataArray[self.weatherDayCount].isRaining{
            rainBackgroundDisplay.alpha = 1
        }else{
            rainBackgroundDisplay.alpha = 0
        }
        
        //Play meow
        playCatMeow()
    }
    
    func playCatMeow() {
        
        //Create an array of meow sounds and randomly select one to play
        let meowSoundsArray : [String] = [
            "meow1","meow2","meow3","meow5", "meow6", "meow7"
        ]
        
        var chosenMeow = meowSoundsArray.randomElement()
        
        
        print("\n\n\n\(chosenMeow)\n\n\n")
        let url = Bundle.main.url(forResource: chosenMeow, withExtension: "mp3")
        meowAudioPlayer = AVPlayer(url: url!)
        meowAudioPlayer.volume = 0.6
        meowAudioPlayer?.play()
    }
    
    func playBtnSound(){
        let url = Bundle.main.url(forResource: "buttonClick", withExtension: "mp3")
        buttonClickAudioPlayer = AVPlayer(url: url!)
        buttonClickAudioPlayer.volume = 0.3
        buttonClickAudioPlayer?.play()
    }
    
    func playSpinSound(){
        let url = Bundle.main.url(forResource: "whoosh", withExtension: "mp3")
        spinAudioPlayer = AVPlayer(url: url!)
        spinAudioPlayer.volume = 0.9
        spinAudioPlayer?.play()
    }

    
    //***********************
    //****** MARK: UI Buttons
    //***********************
    
    @IBAction func nextDayBtnPressed(_ sender: Any) {
        playBtnSound()
        playSpinSound()
        
        activityIndicatorDisplay.startAnimating()
        
        //Check whether it is Daytime or night time
        if weatherDataArray[weatherDayCount].isDaytime == 1{
            
            //Day Time
            if (weatherDataArray.count - 1) > (weatherDayCount + 2){
                
                print("\n\(weatherDataArray.count - 1)\n\(weatherDayCount)\n")
                
                weatherDayCount = weatherDayCount + 2
                
                self.tempForecastDayDisplay()
                self.catImage.rotateClockwise()
                
            }else{
                print("You have reached the last day!")
            }
            
        }else{
            //Night Time
            
            if weatherDayCount == 0{
                
                weatherDayCount = weatherDayCount + 1
                
                self.tempForecastDayDisplay()
                self.catImage.rotateClockwise()
                
            }else{
                
                if (weatherDataArray.count - 1) > (weatherDayCount + 2) && self.weatherDataArray[self.weatherDayCount].isDaytime == 1{
                    
                    weatherDayCount = weatherDayCount + 2
                    
                    self.tempForecastDayDisplay()
                    self.catImage.rotateClockwise()
                    
                }else if (weatherDataArray.count - 1) > (weatherDayCount + 1) && self.weatherDataArray[self.weatherDayCount].isDaytime == 0{
                
                    weatherDayCount = weatherDayCount + 1
                    
                    self.tempForecastDayDisplay()
                    self.catImage.rotateClockwise()
                
                }else{
                    print("You have reached the last day!")
                }
                
            }
            
        }
        
        //Display Cat Image
        if let safeCatChosen = catChosen{
            displayCatImage(catName: safeCatChosen)
        }
        
    }
    
    @IBAction func previousDayBtnPressed(_ sender: Any) {
        playBtnSound()
        playSpinSound()
        
        activityIndicatorDisplay.startAnimating()
        
//        If the weather count is 1 - this would only occur at night time
        if weatherDayCount == 1{
            
            weatherDayCount = weatherDayCount - 1

            self.tempForecastDayDisplay()
            self.catImage.rotateCounterClockwise()

        }else if weatherDayCount == 2 && self.weatherDataArray[self.weatherDayCount].isDaytime == 0{
            
            weatherDayCount = weatherDayCount - 2
            
            self.tempForecastDayDisplay()
            self.catImage.rotateCounterClockwise()
            
        }else{
            
            if self.weatherDataArray[self.weatherDayCount].isDaytime == 1 && (weatherDayCount - 2) >= 0{
                
                weatherDayCount = weatherDayCount - 2
                
                self.tempForecastDayDisplay()
                self.catImage.rotateCounterClockwise()
                
            }else if self.weatherDataArray[self.weatherDayCount].isDaytime == 0 && (weatherDayCount - 3) >= 0{
                
                weatherDayCount = weatherDayCount - 3
                
                self.tempForecastDayDisplay()
                self.catImage.rotateCounterClockwise()
                
            }else{
                print("You have reached the first day")
            }
            
        }
        
        //Display Cat Image
        if let safeCatChosen = catChosen{
            displayCatImage(catName: safeCatChosen)
        }
        
    }
    
    @IBAction func dayToggleBtnPressed(_ sender: Any) {
        playBtnSound()
        playSpinSound()
        
        activityIndicatorDisplay.startAnimating()
        
        if (weatherDayCount - 1) >= 0{
            
            print("\n\(weatherDataArray.count - 1)\n\(weatherDayCount)\n")
            
            //Bounce effect
            let bounds = dayToggleImageDisplay.bounds
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                self.dayToggleImageDisplay.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height + 60)
            }) { (success: Bool) in
                if success{
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.dayToggleImageDisplay.bounds = bounds
                    })
                }
            }
            
            weatherDayCount = weatherDayCount - 1
            
            tempForecastDayDisplay()
            self.catImage.rotateCounterClockwise()
            
            //Display Cat Image
            if let safeCatChosen = catChosen{
                displayCatImage(catName: safeCatChosen)
            }
            
        }else{
            activityIndicatorDisplay.stopAnimating()
            print("You have reached the first day")
        }
        
    }
    
    @IBAction func nightToggleBtnPressed(_ sender: Any) {
        playBtnSound()
        playSpinSound()
        
        activityIndicatorDisplay.startAnimating()
        
        if (weatherDataArray.count - 1) > (weatherDayCount + 1){
            
            //Bounce effect
            let bounds = nightToggleImageDisplay.bounds
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                self.nightToggleImageDisplay.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height + 60)
            }) { (success: Bool) in
                if success{
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.nightToggleImageDisplay.bounds = bounds
                    })
                }
            }
            
            weatherDayCount = weatherDayCount + 1
            
            tempForecastDayDisplay()
            self.catImage.rotateClockwise()
            
            //Display Cat Image
            if let safeCatChosen = catChosen{
                displayCatImage(catName: safeCatChosen)
            }
            
        }else{
            activityIndicatorDisplay.stopAnimating()
            print("You have reached the last day!")
        }
        
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
         
        if contentHasLoaded{
            
            if (sender.direction == .left) {
                    print("Swipe Left")
                
                nextDayBtnPressed(self)
                
            }
                
            if (sender.direction == .right) {
                print("Swipe Right")
                
                previousDayBtnPressed(self)
                
            }
            
        }
        
    }
    
    @IBAction func kobraBtnPressed(_ sender: Any) {
        playBtnSound()
        
        activityIndicatorDisplay.startAnimating()
        
        snowbyBtnDisplay.titleLabel?.alpha = 0.4
        kobraBtnDisplay.titleLabel?.alpha = 1
        
        snowbyBtnDisplay.isUserInteractionEnabled = true
        kobraBtnDisplay.isUserInteractionEnabled = false
        
        //Set user default to remember the user
        self.defaults.set(false, forKey: "isSnowby")
        
        catChosen = "kobra"
        if let safeCatChosen = self.catChosen{
            
            RetrieveCatOutfits().getCatOutfitsWithWeatherData(catName: safeCatChosen, weatherArray: weatherDataArray, completion: { error,
                            result in

                //Returns all of the current weather date
                DispatchQueue.main.async {
                    
                    //The weather Array will contain the outfits at this point
                    self.weatherDataArray = result
                    
                    //You will want to download all of the images so everything will be cached
                    self.tempForecastDayDisplay()
                    
                    //Display Cat Image
                    if let safeCatChosen = self.catChosen{
                        self.displayCatImage(catName: safeCatChosen)
                    }
                }
            })
        }
        
    }
    
    @IBAction func snowbyBtnPressed(_ sender: Any) {
        playBtnSound()
        
        activityIndicatorDisplay.startAnimating()
        
        snowbyBtnDisplay.titleLabel?.alpha = 1
        kobraBtnDisplay.titleLabel?.alpha = 0.4
        
        snowbyBtnDisplay.isUserInteractionEnabled = false
        kobraBtnDisplay.isUserInteractionEnabled = true
        
        //Set user default to remember the user
        self.defaults.set(true, forKey: "isSnowby")
        
        catChosen = "snowby"
        if let safeCatChosen = self.catChosen{
            
            RetrieveCatOutfits().getCatOutfitsWithWeatherData(catName: safeCatChosen, weatherArray: weatherDataArray, completion: { error,
                            result in
                                
                //Returns all of the current weather date
                DispatchQueue.main.async {
                    
                    //The weather Array will contain the outfits at this point
                    self.weatherDataArray = result
                    
                    //You will want to download all of the images so everything will be cached
                    self.tempForecastDayDisplay()
                    
                    //Display Cat Image
                    if let safeCatChosen = self.catChosen{
                        self.displayCatImage(catName: safeCatChosen)
                    }
                }
            })
        }
        
    }
    
}
