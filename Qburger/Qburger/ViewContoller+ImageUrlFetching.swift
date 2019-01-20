//
//  ViewContoller+ImageUrlFetching.swift
//  Qburger
//
//  Created by Andrew on 20/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import FoursquareKit

extension ViewController {
    //MARK: Function to get image URLS
    func getImageUrls(venueId: String, completion: @escaping (String?) -> Void)  {
        var imageUrl = ""
        let auth = Authentification(clientId: "\(FoursquareAPI.sharedInstance.clientIdNr)", clientSecret: "\(FoursquareAPI.sharedInstance.clientSecretNr)")
        let client = FoursquareClient(authentification: auth)
        client.venue.photos(id: "\(venueId)").response { result in
            switch result {
            case .success(let data):
                let linkParts = data.response.photos.items
                if !data.response.photos.items.isEmpty {
                    imageUrl = linkParts[0].prefix + "500x500" + linkParts[0].suffix
                    completion(imageUrl)
                } else {
                    imageUrl = ""
                    completion(imageUrl)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.currentStatus.text = "Error Quota exceeded"
                }
                print("error : \(error)")
            }
        }
    }
}
