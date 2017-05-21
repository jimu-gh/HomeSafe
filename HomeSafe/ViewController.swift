//
//  ViewController.swift
//  CoreLocationStarterKit
//
//  Created by Andy Feng on 4/14/17.
//  Copyright © 2017 Andy Feng. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapKit: MKMapView!
    
    @IBOutlet weak var label1: UILabel!
    
    let home = MKPointAnnotation()
    let monster1 = MKPointAnnotation()
    let monster2 = MKPointAnnotation()
    let monster3 = MKPointAnnotation()
    let monster4 = MKPointAnnotation()
    let monster5 = MKPointAnnotation()
    let monster6 = MKPointAnnotation()
    
    
    let myPin: MKPointAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1 // In seconds
        mapKit.addGestureRecognizer(longPress)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapKit.showsUserLocation = true
        }
        
        label1.text = "Locate your home on the map"
        label1.textColor = UIColor.blue
        
    }
    
        // define long press
 
    func mapLongPress(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapKit) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapKit.convert(touchedAt, toCoordinateFrom: self.mapKit) // will get coordinates
        
        home.coordinate = touchedAtCoordinate
        home.title="Home"
        func placeMonster(monster: MKPointAnnotation, far: Bool){
            var x : Double = 1
            var y : Double = 1
            let xdir = arc4random_uniform(2)
            let ydir = arc4random_uniform(2)
            var dist : UInt32 = 16
            
            if far == true{
                dist = 32
            }
            
            if xdir == 0 {
                x = -1
            }
            if ydir == 0 {
                y = -1
            }
            monster.coordinate.latitude = touchedAtCoordinate.latitude + Double(arc4random_uniform(dist)) * 0.0001 * x
            monster.coordinate.longitude = touchedAtCoordinate.longitude + Double(arc4random_uniform(dist)) * 0.0001 * y
        }
        
        monster1.title = "Monster"
        monster2.title = "Monster"
        monster3.title = "SmartMonster"
        monster4.title = "FarMonster"
        monster5.title = "FarMonster"
        monster6.title = "FarMonster"
        placeMonster(monster: monster1, far: false)
        placeMonster(monster: monster2, far: false)
        placeMonster(monster: monster3, far: false)
        placeMonster(monster: monster4, far: true)
        placeMonster(monster: monster5, far: true)
        placeMonster(monster: monster6, far: true)
        mapKit.addAnnotation(home)
        mapKit.addAnnotation(monster1)
        mapKit.addAnnotation(monster2)
        mapKit.addAnnotation(monster3)
        mapKit.addAnnotation(monster4)
        mapKit.addAnnotation(monster5)
        mapKit.addAnnotation(monster6)
        
        label1.text = "Avoid the monsters to go home!"
        label1.textColor = UIColor.brown
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("Location updated.")
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
//        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapKit.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        myPin.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myPin.title = "Player"
        mapKit.addAnnotation(myPin)
        
        print("User Latitude:\(userLocation.coordinate.latitude)")
        print("User Longitude:\(userLocation.coordinate.longitude)")
        
        print("Home Latitude:\(home.coordinate.latitude)")
        print("Home Longitude:\(home.coordinate.longitude)")
        
        // check proximity to pin
        
        func checkWinLose(){
            let latitudetohome = abs(home.coordinate.latitude - userLocation.coordinate.latitude)
            let longitudetohome = abs(home.coordinate.longitude - userLocation.coordinate.longitude)
            if (latitudetohome < 0.0002) && (longitudetohome < 0.0002){
                label1.text = "You made it home!"
                label1.textColor = UIColor.blue
                mapKit.removeAnnotations([monster1, monster2, monster3, monster4, monster5, monster6])
                mapKit.removeAnnotation(home)
            }
            else{
                let monsters = [monster1,monster2,monster3]
                for monster in monsters{
                    let latitudetomonster = abs(monster.coordinate.latitude - userLocation.coordinate.latitude)
                    let longitudetomonster = abs(monster.coordinate.longitude - userLocation.coordinate.longitude)
                    if (latitudetomonster < 0.0002) && (longitudetomonster < 0.0002){
                        label1.text = "You died! Try Again!"
                        label1.textColor = UIColor.red
                        mapKit.removeAnnotations([monster1, monster2, monster3, monster4, monster5, monster6])
                        mapKit.removeAnnotation(home)
                    }
                    
                }
            }
        }
        
        if home.coordinate.latitude != 0 && home.coordinate.longitude != 0 {
            
            func refreshMonster(monster: MKPointAnnotation, far: Bool){
                mapKit.removeAnnotation(monster)
                // L, R, U, or D
                
                let xdir = arc4random_uniform(3)
                let ydir = arc4random_uniform(3)
                
                var speed : Double = 1
                
                if monster.title == "SmartMonster" {
                    speed = 0.5
                    if userLocation.coordinate.latitude-monster.coordinate.latitude < 0 {
                        monster.coordinate.latitude -= 0.0001 * speed
                    }
                    else{
                        monster.coordinate.latitude += 0.0001 * speed
                    }
                    if userLocation.coordinate.longitude-monster.coordinate.longitude < 0 {
                        monster.coordinate.longitude -= 0.0001 * speed
                    }
                    else{
                        monster.coordinate.longitude += 0.0001 * speed
                    }
                }
                else{
                    if far == true {
                        speed = 3
                    }
                    
                    if xdir == 0{
                        monster.coordinate.latitude -= 0.0001 * speed
                    }
                    else if xdir == 1 {
                        monster.coordinate.latitude += 0.0001 * speed
                    }
                    
                    if ydir == 0{
                        monster.coordinate.longitude -= 0.0001 * speed
                    }
                    else if ydir == 1 {
                        monster.coordinate.longitude += 0.0001 * speed
                    }
                }
                
                mapKit.addAnnotation(monster)
            }
            refreshMonster(monster: monster1, far: false)
            refreshMonster(monster: monster2, far: false)
            refreshMonster(monster: monster3, far: true)
            refreshMonster(monster: monster4, far: true)
            refreshMonster(monster: monster5, far: true)
            refreshMonster(monster: monster6, far: true)
            checkWinLose()
        }

        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        if annotation.title! == "Monster"{
            annotationView.pinTintColor = UIColor.magenta
        }
        else if annotation.title! == "FarMonster"{
            annotationView.pinTintColor = UIColor.purple
        }
        else if annotation.title! == "SmartMonster"{
            annotationView.pinTintColor = UIColor.red
        }
        else if annotation.title! == "Home"{
            annotationView.pinTintColor = UIColor.green
        }
        else{
            annotationView.pinTintColor = UIColor.blue
        }
        return annotationView
    }

}

