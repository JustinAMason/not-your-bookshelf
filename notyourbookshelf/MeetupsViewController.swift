//
//  MeetupsViewController.swift
//  Not Your Bookshelf
//
//  Created by William Kelley on 12/2/18.
//  Copyright © 2018 William Kelley. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class Meetup: NSObject, MKAnnotation {
    let title: String? //title string
    let event: String //eg: childrens literature
    let location: String //eg Kinokuniya db:["name"]
    let address: String
    let date: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    
    init(event: String, location: String, address: String, date: String, type: String, coordinate: CLLocationCoordinate2D) {
        self.title = event + " @ " + location //eg Children's Literature @ Kinokuniya
        self.event = event
        self.location = location //eg Kinokuniya
        self.address = address
        self.date = date
        self.type = type
        self.coordinate = coordinate
        
        super.init()
    }
    
    //displays the date of event when clicked into pin
    var subtitle: String? {
        return date
    }
    
    // markerTintColor for meetup type: event, trade
    var markerTintColor: UIColor  {
        switch type {
        case "event":
            return .red
        case "trade":
            return .blue
        default:
            return .green
        }
    }
}

class MeetupMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let meetup = newValue as? Meetup else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = meetup.markerTintColor
            glyphText = String(meetup.type.first!)
        }
    }
}

class MeetupsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToDatabase()
        
        mapView.register(MeetupMarkerView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        getData()
        
        // set initial screen location in NYC
        let initialLocation = CLLocation(latitude: 40.7528, longitude: -74.0000)
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
    }
    
    func connectToDatabase() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func getData() {
        self.db.collection("meetups").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let event = document["event"] as? String ?? ""
                    let location = document["name"] as? String ?? ""
                    let address = document["address"] as? String ?? ""
                    let date = document["date"] as? String ?? ""
                    let type = document["type"] as? String ?? ""
                    
                    if let coords = document.get("coords") {
                        let point = coords as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        
                        let meetup = Meetup(event: event,
                                            location: location,
                                            address: address,
                                            date: date, type: type,
                                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        self.mapView.addAnnotation(meetup)
                    }
                }
            }
        }
    }
    let regionRadius: CLLocationDistance = 10000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //displays additional info when "i" clicked on a location pin
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? Meetup, let title = annotation.title else { return }
        
        let alertController = UIAlertController(title: title, message: "You''re almost there.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MeetupsViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? Meetup else { return nil }
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        return view
//    }
}
