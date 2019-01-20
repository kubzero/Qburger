//
//  ViewController+FetchJSON.swift
//  Qburger
//
//  Created by Andrew on 20/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//
import MapKit
import Foundation
import FoursquareAPIClient

extension ViewController {
    
    //MARK: Fetch JSON with data
    func fetchData() {
        self.currentStatus.text = "Fetching Data"
        let client = FoursquareAPIClient(clientId: "\(FoursquareAPI.sharedInstance.clientIdNr)", clientSecret: "\(FoursquareAPI.sharedInstance.clientSecretNr)")
        let parameter: [String: String] = [
            "ll": "58.3780,26.7321",
            "limit": "50",
            "radius": "6000",
            "categoryId": "4bf58dd8d48988d16c941735"
            // 4bf58dd8d48988d16c941735 burgers
            // 4d4b7105d754a06374d81259 all restaurants
        ];
        client.request(path: "venues/search", parameter: parameter) { result in
            switch result {
            case let .success(data):
                let product = try! JSONDecoder().decode(Restaurant.self, from: data)
                for eachVenue in product.response.venues{
                    let placeName = eachVenue.name
                    let placeId = eachVenue.id
                    let lattitude = eachVenue.location.lat
                    let longitude = eachVenue.location.lng
                    let centerCoordinate = CLLocation(latitude: 58.3780, longitude: 26.7321)
                    let venueCoordinate = CLLocation(latitude: eachVenue.location.lat, longitude: eachVenue.location.lng)
                    let distance = venueCoordinate.distance(from: centerCoordinate)
                    self.fetchedJsonArray.append(MainArray(id: placeId, name: placeName, url: "", lat: lattitude, long: longitude, distance: Int(distance)))
                }
                print("JSON has been fetched to Array with: \(self.fetchedJsonArray.count) Venues ")
                self.cleanArrayForEmtyVenues()
                print("JSON has been cleaned from 1km venues from bus station: \(self.fetchedJsonArray.count) Venues left ")
                if self.fetchedJsonArray.count != 0 {
                    self.fulfillWithurl()
                }
            //ERRORS:
            case let .failure(error):
                switch error {
                case let .connectionError(connectionError):
                    DispatchQueue.main.async {
                        self.currentStatus.text = "Error: \(connectionError) "
                    }
                    print(connectionError)
                case let .responseParseError(responseParseError):
                    DispatchQueue.main.async {
                        self.currentStatus.text = "Error: \(responseParseError) "
                    }
                    print(responseParseError)   // e.g. JSON text did not start with array or object and option to allow fragments not set.
                case let .apiError(apiError):
                    DispatchQueue.main.async {
                        self.currentStatus.text = "Error: \(apiError.errorType) "
                    }
                    print(apiError.errorType)   // e.g. endpoint_error
                    print(apiError.errorDetail) // e.g. The requested path does not exist.
                }
            }
        }
    }
}
