//
//  WeatherManager.swift
//  Clima
//
//  Created by everis on 11/23/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager ,weather: WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=aa3f1b55205dea72b940fd150e0d49b6&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(urlString)
        print(urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString)
        print(urlString)
    }
    
    func performRequest(_ urlString:String){
        // 1. Create a URL
        
        if let url = URL(string: urlString){
            // 2. Create a UrlSession
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            
            let task =  session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJson(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
            
        }
    }
    
    func parseJson(_ weatherData:Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.temperatureString)
            return weather
            
            
            
        } catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
