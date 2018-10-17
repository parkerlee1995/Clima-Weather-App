//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

//WVC is a subclass of UIVC and conforms to the rules of CLLMD
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a6e6ab2e41928ac15e2b7ec457340137"
    

    //TODO: Declare instance variables here
    //create location manager object below
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        //self means our current class (i.e. weatherviewcontroller)
        //setting the WeatherViewController as the delegate of the locationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //This method will trigger authorization pop-up for location while app is in use
        //Must update key list and add text for this pop up to work
        //Privacy Location Usage Description (value = whatever you want it to say)
        //Privacy When in use location usage description
        //Add security override for not having SSL into the XML  (https)
        locationManager.requestWhenInUseAuthorization()
        //Start looking for current GPS location of iPhone (Asynchronous method, in background)
        //For WeatherViewController to receive update, must have didUpdateLocations method
        //Create didFailWithError function in case the location was not updated
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String : String]) {
        
        //The following block of code is provided by Alamofire in order to make a 'get' request
        //Netorking happens in asynchronus method
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data.")
                
                //Following line uses SwiftyJSON
                let weatherJSON : JSON = JSON(response.result.value!)
                //(Inside closure) must put self. in front of method calls
                //response in represents the closure
                self.updateWeatherData(json: weatherJSON)
                
                //print(weatherJSON)
            }
            else {
                //print("Error \(response.result.error)")
                self.cityLabel.text = "Connection issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        
        //Allowed by SwiftyJSON
        if let tempResult = json["main"]["temp"].double {
        
            weatherDataModel.temperature = Int(tempResult - 273.15)
        
            weatherDataModel.city = json["name"].stringValue
        
            weatherDataModel.condition = json["weather"][0]["id"].intValue
        
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
        updateUIWithWeatherData()
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //Will save the date into [Array] i.e. CLLocation object
    //Last value in the array is the most accurate and what we want to use
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            //stop updating to avoid user battery to be completely used up
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            //print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //Combine above values into a dictionary
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL, parameters : params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        //using q as the key comes from the API docs for data by city name
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
}


