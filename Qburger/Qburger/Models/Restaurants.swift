//
//  Restaurants.swift
//  Qburger
//
//  Created by Andrew on 08/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    let response: Response
}

struct Response: Codable {
    let venues: [Venues]
}

struct Venues: Codable {
    let id: String
    let name: String
    let location: Location
    let categories: [Category]
    
}

struct Category: Codable {
    let id: String
    let name: String
    let pluralName: String
    let shortName: String
    
}

struct Location: Codable {
    let lat, lng: Double
    let distance: Int
}

