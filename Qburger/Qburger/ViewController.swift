//
//  ViewController.swift
//  Qburger
//
//  Created by Andrew on 07/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//
import UIKit
import MapKit
import Foundation
import FoursquareAPIClient
import FoursquareKit

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {
    
    let clientIdNr:String = "FQMRQ5SDWWBPJUIGIAFQLYC5YNLWVOKSGYVSPLUBJMDM1IYP"
    let clientSecretNr:String = "3H0X3OO0N2GKPWLOZQ4LEK51OPB1VXZNOYVGGPLRRFKKU5UQ"
    let burgerApi = "https://pplkdijj76.execute-api.eu-west-1.amazonaws.com/prod/recognize"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var generalView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var secondArray:[MainArray] = []
    var thirdArray:[MainArray] = []
    var index = 0
    var imageChekIndex = 0
    @IBOutlet var currentStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.layer.zPosition = 3
        activityIndicator.startAnimating()
        mainView.layer.zPosition = 2
        collectionView.layer.zPosition = 3
        currentStatus.layer.zPosition = 3
        setGradientBackground()
        fetchData()
        self.mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  thirdArray.count
    }
    
//MARK: Fulfill collectionview with images
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseCell", for: indexPath) as! CollectionViewCell
        let venue = thirdArray[indexPath.row].url
        
        if venue != nil && venue != ""{
            let url = URL(string: thirdArray[indexPath.row].url!)
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async(execute: {
                cell.cellImage.image = UIImage(data: data!)
            })
        }
        return cell
    }
    
//MARK: Gradiend background
    func setGradientBackground() {
        let colorTop = UIColor(red: 68/255, green: 66/255, blue: 218/255, alpha: 1)
        let colorBottom  = UIColor(red: 191/255, green: 51/255, blue: 122/255, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.colors = [colorTop.cgColor,colorBottom.cgColor]
        generalView.layer.addSublayer(gradient)
        mainView.backgroundColor = UIColor.clear
    }
    
//MARK: Fetch JSON with data
    func fetchData() {
        self.currentStatus.text = "Fetching Data"
        let client = FoursquareAPIClient(clientId: "\(clientIdNr)", clientSecret: "\(clientSecretNr)")
        let parameter: [String: String] = [
            "ll": "58.3780,26.7321",
            "limit": "400",
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
                    self.secondArray.append(MainArray(id: placeId, name: placeName, url: "", lat: lattitude, long: longitude, distance: Int(distance)))
                }
                print("JSON has been fetched to Array with: \(self.secondArray.count) Venues ")
                self.cleanArrayForEmtyVenues()
                print("JSON has been cleaned from 1km venues from bus station: \(self.secondArray.count) Venues left ")
                if self.secondArray.count != 0 {
                self.fulfillWithurl()
                }
            //ERRORS:
            case let .failure(error):
                switch error {
                case let .connectionError(connectionError):
                    print(connectionError)
                case let .responseParseError(responseParseError):
                    print(responseParseError)   // e.g. JSON text did not start with array or object and option to allow fragments not set.
                case let .apiError(apiError):
                    print(apiError.errorType)   // e.g. endpoint_error
                    print(apiError.errorDetail) // e.g. The requested path does not exist.
                }
            }
        }
    }
    
//MARK: Remove Venues from 1km radius
    func cleanArrayForEmtyVenues() {
        let filteredArray = secondArray.filter { $0.distance! >= 1000}
        secondArray = filteredArray
        self.currentStatus.text = "Cleaning array"
    }
    //MARK: Remove Venues from 1km radius
    func cleanArrayForEmtyUrl() {
        let filteredArray = thirdArray.filter { $0.url! != "" || $0.url != ""}
        thirdArray = filteredArray
    }
    
    
//MARK: Get photo URLS by venueID
    func fulfillWithurl() {
        self.currentStatus.text = "Fetching image URL"
        getImageUrls(venueId: secondArray[index].id!) { imageUrl in
            self.thirdArray.append(MainArray(id: self.secondArray[self.index].id!,name: self.secondArray[self.index].name!,url: imageUrl!,lat: self.secondArray[self.index].lat!,long: self.secondArray[self.index].long!))
            self.index += 1
            if self.index < self.secondArray.count {
                self.fulfillWithurl()
            } else if self.index == self.secondArray.count {
                print("All image URLs has been successfully fetched")
                self.cleanArrayForEmtyUrl()
                print("All venues has been cleaned from empty URL places")
                self.chekUrlForBurger()
                self.currentStatus.text = "Downloading all"
            }
        }
    }
    
//MARK: Fulfill map with annotations, add radius
    func fulfillAnotations(cleanArray:[MainArray]) {
        let coordinate = CLLocationCoordinate2D(latitude: 58.3780, longitude: 26.7321)
        for each in cleanArray {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: each.lat!, longitude: each.long!)
            annotation.title = each.name!
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 7000, longitudinalMeters: 7000)
        mapView.setRegion(viewRegion, animated: false)
        self.mapView.addOverlay(MKCircle(center: coordinate, radius: 1000))
        self.currentStatus.isHidden = true
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,calloutAccessoryControlTapped control:UIControl) {
        performSegue(withIdentifier: "toDetailViewController", sender: view)
    }
    
//MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DetailViewController
        if let annotation = sender as? MKAnnotationView {
            destination.venueName  = (annotation.annotation?.title!)!
            destination.detailArray = thirdArray
        }
    }
    
//MARK: Func to check all urls by burger Api
    func chekUrlForBurger() {
        self.currentStatus.text = "Check if url"
        self.burgerCheking(linkToCheck: self.thirdArray[self.imageChekIndex].url!) { answer in
            if answer != "" {
                self.thirdArray[self.imageChekIndex].url = answer
            } else if answer == "" {
                self.thirdArray[self.imageChekIndex].url! = ""
            }
            self.imageChekIndex += 1
            if self.imageChekIndex < self.thirdArray.count {
                self.chekUrlForBurger()
            } else if self.imageChekIndex == self.thirdArray.count {
                self.cleanArrayForEmtyUrl()
                print("All venues expect Burger places has been removed")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.fulfillAnotations(cleanArray: self.thirdArray)
                self.collectionView!.reloadData()
            }
        }
    }
    
//MARK: Function to get image URLS
    func getImageUrls(venueId: String, completion: @escaping (String?) -> Void)  {
        var imageUrl = ""
        let auth = Authentification(clientId: "\(clientIdNr)", clientSecret: "\(clientSecretNr)")
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
                self.currentStatus.text = "Error Quota exceeded"
                print("error : \(error)")
            }
        }
    }
    
//MARK: Check image by qminder burger API
    func burgerCheking(linkToCheck:String, completion: @escaping (String?) -> Void) {
        var answer = ""
        guard let url = URL(string: burgerApi) else {return}
        let recognize = Recognize(urls: [linkToCheck])
        let jsonEncoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? jsonEncoder.encode(recognize) else {return }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response else {return}
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200){
                do {
                    print("successfully one burger place found")
                    let jsonRequest = try! JSONDecoder().decode(Responses.self, from: data)
                    answer = jsonRequest.urlWithBurger!
                    completion(answer)
                }}
            if(statusCode == 400){
                do {
                    answer = ""
                    completion(answer)
                }}
            if(statusCode == 404){
                do {
                    answer = ""
                    completion(answer)
                }}}.resume()
    }
}

//MARK: Annotation extention for circle, annotation details
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else { return MKOverlayRenderer() }
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.blue
        circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
        circle.lineWidth = 2.5
        return circle
    }
    //MARK: Adding annotation details
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            annotationView.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = btn
            return annotationView
        }
    }
}

