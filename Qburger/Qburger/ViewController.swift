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

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {
    
    let clientIdNr:String = "BKWU3WTD5T5UIVACJF3YJXSLOK0O1RK5CBVXXZL0FRYHCWRC"
    let clientSecretNr:String = "EW2QAI02SOG45WCUBVVDXDBBCQOT53HR10FE2YUU33X1GBYW"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var generalView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var fetchedJsonArray:[MainArray] = []
    var cleanArray:[MainArray] = []
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
        return  cleanArray.count
    }
    
//MARK: Fulfill collectionview with images
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseCell", for: indexPath) as! CollectionViewCell
        let venue = cleanArray[indexPath.row].url
        
        if venue != nil && venue != ""{
            let url = URL(string: cleanArray[indexPath.row].url!)
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
    
//MARK: Remove Venues from 1km radius
    func cleanArrayForEmtyVenues() {
        let filteredArray = fetchedJsonArray.filter { $0.distance! >= 1000}
        fetchedJsonArray = filteredArray
        self.currentStatus.text = "Cleaning array"
    }
    //MARK: Remove Venues from 1km radius
    func cleanArrayForEmtyUrl() {
        let filteredArray = cleanArray.filter { $0.url! != "" || $0.url != ""}
        cleanArray = filteredArray
    }
    
//MARK: Get photo URLS by venueID
    func fulfillWithurl() {
        DispatchQueue.main.async {
        self.currentStatus.text = "Fetching image URL"
        }
        getImageUrls(venueId: fetchedJsonArray[index].id!) { imageUrl in
            self.cleanArray.append(MainArray(id: self.fetchedJsonArray[self.index].id!,name: self.fetchedJsonArray[self.index].name!,url: imageUrl!,lat: self.fetchedJsonArray[self.index].lat!,long: self.fetchedJsonArray[self.index].long!))
            self.index += 1
            if self.index < self.fetchedJsonArray.count {
                self.fulfillWithurl()
            } else if self.index == self.fetchedJsonArray.count {
                print("All image URLs has been successfully fetched")
                self.cleanArrayForEmtyUrl()
                print("All venues has been cleaned from empty URL places")
                self.chekUrlForBurger()
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
            destination.detailArray = cleanArray
        }
    }
    
//MARK: Func to check all urls by burger Api
    func chekUrlForBurger() {
        DispatchQueue.main.async {
        self.currentStatus.text = "Please wait,checking urls for API"
        }
        self.burgerCheking(linkToCheck: self.cleanArray[self.imageChekIndex].url!) { answer in
            if answer != "" {
                self.cleanArray[self.imageChekIndex].url = answer
            } else if answer == "" {
                self.cleanArray[self.imageChekIndex].url! = ""
            }
            self.imageChekIndex += 1
            if self.imageChekIndex < self.cleanArray.count {
                self.chekUrlForBurger()
            } else if self.imageChekIndex == self.cleanArray.count {
                self.cleanArrayForEmtyUrl()
                print("All venues expect Burger places has been removed")
                DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                }
                self.fulfillAnotations(cleanArray: self.cleanArray)
                self.collectionView!.reloadData()
            }
        }
    }
    
}
