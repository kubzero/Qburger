//
//  MainArray.swift
//  Qburger
//
//  Created by Andrew on 08/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
struct MainArray: Codable {
    let id:String?
    let name:String?
    var url:String?
    let lat:Double?
    let long:Double?
    let distance:Int?
    
    
    init(id: String? = nil,name: String? = nil,url: String? = nil,lat:Double? = nil,long:Double? = nil,distance:Int? = nil) {
        
        self.id = id
        self.name = name
        self.url = url
        self.lat = lat
        self.long = long
        self.distance = distance
}
}
