//
//  WeatherVC.swift
//  RainyShinyCloudyyy
//
//  Created by Cookie on 9/13/17.
//  Copyright © 2017 Cookie. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class WeatherVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {


    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentWeatherTypelbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentWeather: CurrentWeather!
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        currentWeather = CurrentWeather()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    
                    self.updateMainUI()
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    
    }
    
    func downloadForecastData(completed: @escaping DownloadComplete){
        //Downloading forecast weather data for TableView
        let forecastUrl = URL(string: FORECAST_URL)!
        Alamofire.request(forecastUrl).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    for obj in list {
                        let forecast = Forecast(weatherDict: obj)
                        self.forecasts.append(forecast)
                    }
                    self.forecasts.remove(at: 0)
                    self.tableView.reloadData()
                }
            }
            completed()
        }
    
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? WeatherCell {
            let forecast = forecasts[indexPath.row]
            cell.configureCell(forecast: forecast)
            return cell
        } else {
            return WeatherCell()
        }
    }
    
    func updateMainUI() {
        dateLbl.text = currentWeather.date
        tempLabel.text = "\(currentWeather.currentTemp)"
        currentWeatherTypelbl.text = currentWeather.weatherType
        locationLbl.text = currentWeather.cityName
        print("###########")
        print(currentWeather.cityName)
        currentWeatherImage.image = UIImage(named: currentWeather.weatherType)
    }
}

