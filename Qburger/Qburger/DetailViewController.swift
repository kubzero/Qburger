//
//  DetailViewController.swift
//  Qburger
//
//  Created by Andrew on 13/01/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var navBarTitle: UINavigationItem!
    @IBOutlet var venueImage: UIImageView!
    @IBOutlet var venueLabel: UILabel!
    @IBOutlet var mainBackGround: UIView!
    @IBOutlet var generalView: UIView!

    var venueName:String = "No name"
    var venueUrl:String = ""
    var detailArray:[MainArray] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarTitle.title = venueName
        setGradientBackground()
        generalView.layer.zPosition = 2
        venueLabel.text = venueName
        fetchImage()
    }
    override func viewDidAppear(_ animated: Bool) {
      self.navigationController?.navigationBar.isHidden = false
    }
    
    func setGradientBackground() {
        let colorTop = UIColor(red: 68/255, green: 66/255, blue: 218/255, alpha: 1)
        let colorBottom  = UIColor(red: 191/255, green: 51/255, blue: 122/255, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.colors = [colorTop.cgColor,colorBottom.cgColor]
        mainBackGround.layer.addSublayer(gradient)
    }
    
    func fetchImage () {
        if let i = detailArray.index(where: { $0.name == "\(venueName)" }) {
            venueUrl = detailArray[i].url!
            
            if  venueUrl != ""{
                let url = URL(string: detailArray[i].url!)
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async(execute: {
                    self.venueImage.image = UIImage(data: data!)
                })
            }
        }
    }
}
