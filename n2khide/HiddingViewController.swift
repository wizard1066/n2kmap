//
//  HiddingViewController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import CoreLocation
import SafariServices

// 2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6 UUID iBeacon

extension UIImage {
    func resize(width: CGFloat) -> UIImage {
        let height = (width/self.size.width)*self.size.height
        return self.resize(size: CGSize(width: width, height: height))
    }
    
    func resize(height: CGFloat) -> UIImage {
        let width = (height/self.size.height)*self.size.width
        return self.resize(size: CGSize(width: width, height: height))
    }
    
    func resize(size: CGSize) -> UIImage {
        let widthRatio  = size.width/self.size.width
        let heightRatio = size.height/self.size.height
        var updateSize = size
        if(widthRatio > heightRatio) {
            updateSize = CGSize(width:self.size.width*heightRatio, height:self.size.height*heightRatio)
        } else if heightRatio > widthRatio {
            updateSize = CGSize(width:self.size.width*widthRatio,  height:self.size.height*widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(updateSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: updateSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension String {
    func reformatIntoDMS() -> String {
        let parts2F = split(separator: "-")
        let partsF = parts2F.map { String($0) }
        return String(
            format: "%@°%@'%@\"%@",
            partsF[0],
            partsF[1],
            partsF[2],
            partsF[3]
        )
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



class HiddingViewController: UIViewController, UIDropInteractionDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, setWayPoint, zap, UICloudSharingControllerDelegate, showPoint, CLLocationManagerDelegate,save2Cloud, table2Map, SFSafariViewControllerDelegate {
  
    

    
 
    
    
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var longitudeNextLabel: UILabel!
    @IBOutlet weak var latitudeNextLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
  
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loadingSV: UIStackView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var pin: UIBarButtonItem!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var SVcountingLabels: UIStackView!
    @IBOutlet weak var topView: UIView!
    private var savedMap: Bool = true
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var compassRing: UIImageView!
    @IBOutlet weak var playButton: UIBarButtonItem!
  
    @IBOutlet weak var thereLabel: UIImageView!
    @IBOutlet weak var farLabel: UIImageView!
    @IBOutlet weak var nearLabel: UIImageView!
    @IBOutlet weak var hereLabel: UIImageView!
    
    @IBAction func saveButton(_ sender: Any) {
        tryNow = !tryNow
        if tryNow {
            doLive()
            DispatchQueue.main.async() {
                self.playButton.image = UIImage(named: "rec")
                self.playButton.tintColor = UIColor.red
            }
            return
        }
        if !tryNow {
            undoLive()
            DispatchQueue.main.async() {
                self.playButton.image = UIImage(named: "play")
                self.playButton.tintColor = self.buttonColour
            }
        }
        if !confirmSequenced() {
            return
        }
        DispatchQueue.main.async() {
            self.spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 64, height: 64))
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.spinner)
            self.spinner.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        save2Cloud(rex2S: listOfPoint2Seek, rex2D: nil, sharing: false, reordered: false)
    }
    
    
    @IBAction func searchButton(_ sender: Any) {
        let url = URL(string: "https://elearning.swisseducation.com")
        let svc = SFSafariViewController(url: url!)
        present(svc, animated: true, completion: nil)
    }
    
    @IBAction func foobar(_ sender: Any) {

    }
    
    @IBAction func debug(_ sender: Any) {
        
        for overlays in mapView.overlays {
            
            let latitude = overlays.coordinate.latitude
            let longitude = overlays.coordinate.longitude
           
            var box2M: String!
            for (k2U, V2U) in WP2P {
                if V2U.coordinate.longitude == longitude, V2U.coordinate.latitude == latitude {
                    box2M = k2U
                }
            }
        }
        
    }
    
    func returnUUID(Source2U: String) -> String {
        let allowedCharset = CharacterSet
            .alphanumerics
            .union(CharacterSet(charactersIn: "+"))
        
       return(String(Source2U.unicodeScalars.filter(allowedCharset.contains)))
    }
    
    @IBAction func pinButton(_ sender: Any) {
        if usingMode == op.playing {
            return
        }
        savedMap = false
        if currentLocation != nil {
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude)
            let wp2FLat = self.getLocationDegreesFrom(latitude: currentLocation.coordinate.latitude)
            let wp2FLog = self.getLocationDegreesFrom(longitude: currentLocation.coordinate.longitude)
            let hint2D = wp2FLat + wp2FLog
            let uniqueName =  returnUUID(Source2U: hint2D)
           
            
            let waypoint2 = MyPointAnnotation()
            waypoint2.coordinate  = userLocation
            waypoint2.title = uniqueName
            MKPinAnnotationView.greenPinColor()
            waypoint2.subtitle = nil
            
            mapView.addAnnotation(waypoint2)
            let boxes = self.doBoxV2(latitude2D: waypoint2.coordinate.latitude, longitude2D: waypoint2.coordinate.longitude, name: uniqueName, add2Map: true)
            var box2F:[CLLocation] = []
            for box in boxes {
                box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
            }
            let newWayPoint = wayPoint(recordID:nil,recordRecord: nil, UUID: nil, major:nil, minor: nil, proximity: nil, coordinates: userLocation, name: uniqueName, hint: hint2D, image: nil, order: wayPoints.count, boxes:box2F, challenge: nil, URL: nil)
            wayPoints[uniqueName] = newWayPoint
            listOfPoint2Seek.append(newWayPoint)
        }
    }
    
    private func selectSet(set2U:[CLLocation], type2U: Int, size2R: Int) -> CLLocationCoordinate2D {
        
        var selectedCord:Double!
        switch size2R {
            case size2U.min:
                selectedCord = Double(MAXFLOAT)
            case size2U.max:
                selectedCord = -Double(MAXFLOAT)
            default:
                break
        }
        var selectedSet:CLLocationCoordinate2D!
        for cord in set2U {
            if size2R == size2U.min, type2U == axis.longitude {
                selectedCord = Double.minimum(cord.coordinate.longitude , selectedCord)
                if cord.coordinate.longitude == selectedCord {
                    selectedCord = cord.coordinate.longitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
            if size2R == size2U.max, type2U == axis.longitude {
                selectedCord = Double.maximum(cord.coordinate.longitude , selectedCord)
                if cord.coordinate.longitude == selectedCord {
                    selectedCord = cord.coordinate.longitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
            if size2R == size2U.min, type2U == axis.latitude {
                selectedCord = Double.minimum(cord.coordinate.latitude , selectedCord)
                if cord.coordinate.latitude == selectedCord {
                    selectedCord = cord.coordinate.latitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
            if size2R == size2U.max, type2U == axis.latitude {
                selectedCord = Double.maximum(cord.coordinate.latitude , selectedCord)
                if cord.coordinate.latitude == selectedCord {
                    selectedCord = cord.coordinate.latitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
        }
        return selectedSet
    }
    
    
    private func listAllZones()  {
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        operation.fetchRecordZonesCompletionBlock = { records, error in
            if error != nil {
                print("\(String(describing: error?.localizedDescription))")
                self.parseCloudError(errorCode: error as! CKError, lineno: 257)
            }
            for rex in records! {
                
                zoneTable[rex.value.zoneID.zoneName] = rex.value.zoneID
            }
//            self.zonesReturned = true
        }
        privateDB.add(operation)
    }
    
    var geotifications = [Geotification]()
    var locationManager:CLLocationManager? = nil
    
    // MARK: DMS direction section
    
    func showDirection2Take(direction2G:CGFloat) {
        if self.angle2U != nil {
            DispatchQueue.main.async {
                let direction2GN = CGFloat(self.angle2U!) - direction2G
                let tr2 = CGAffineTransform.identity.rotated(by: direction2GN)
                let degree2S = self.radiansToDegrees(radians: Double(direction2GN))
                self.centerImage.transform = tr2
                
                let trueNorth = CGFloat(direction2G)
                let tr1 = CGAffineTransform.identity.rotated(by: trueNorth)
                self.compassRing.transform = tr1
                
            }
        }
    }
    
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / Double.pi }
    func degreesToRadians(degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    
    func getBearing(toPoint point: CLLocationCoordinate2D, longitude:Double, latitude: Double) -> Double {
        
        let lat1 = degreesToRadians(degrees: latitude)
        let lon1 = degreesToRadians(degrees: longitude)
        let lat2 = degreesToRadians(degrees: point.latitude)
        let lon2 = degreesToRadians(degrees: point.longitude)
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        //        return radiansToDegrees(radians: radiansBearing)

        return radiansBearing
    }
    
    // MARK location Manager delegate code + more
    
    @IBAction func stateButton(_ sender: Any) {
        // draws a square around the current window
        // Disabled 21.06.2018
        let mRect = self.mapView.visibleMapRect
//        let cordSW = mapView.convert(getSWCoordinate(mRect: mRect), toPointTo: mapView)
//        let cordNE = mapView.convert(getNECoordinate(mRect: mRect), toPointTo: mapView)
//        let cordNW = mapView.convert(getNWCoordinate(mRect: mRect), toPointTo: mapView)
//        let cordSE = mapView.convert(getSECoordinate(mRect: mRect), toPointTo: mapView)
        
//        let DNELat = getLocationDegreesFrom(latitude: getNECoordinate(mRect: mRect).latitude)
//        let DNELog = getLocationDegreesFrom(longitude: getNECoordinate(mRect: mRect).longitude)
//        let (latCords,longCords) = getDigitalFromDegrees(latitude: DNELat, longitude: DNELog)
//        let cord2U = CLLocationCoordinate2D(latitude: latCords, longitude: longCords)
        
        var coordinates =  [getNWCoordinate(mRect: mRect),getNECoordinate(mRect: mRect), getSECoordinate(mRect: mRect),getSWCoordinate(mRect: mRect),getNWCoordinate(mRect: mRect)]
        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
    }
    
    
    private func doPin(cord2D: CLLocationCoordinate2D, title: String) {
        DispatchQueue.main.async() {
            let pin = MyPointAnnotation()
            pin.coordinate  = cord2D
            pin.title = title
            self.mapView.addAnnotation(pin)
        }
    }
    
    // MARK: // iBeacon code
    
    var globalUUID: String? {
        didSet {
            startScanning()
        }
    }
    
    func stopScanning() {
         if globalUUID != nil {
            locationManager?.stopMonitoring(for: beaconRegion)
            locationManager?.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    
    func startScanning() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        locationManager = appDelegate.locationManager
        if globalUUID != nil {
            beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: globalUUID!)!, identifier: "nobody")
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(in: beaconRegion)
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
        }
    }
    
    var isSearchingForBeacons = false
    var lastFoundBeacon:CLBeacon!
    var lastProximity: CLProximity?
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "LocationMgr state", message:  "\(region.identifier) \(state)", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
        if beaconRegion != nil {
            if state == CLRegionState.inside {
                locationManager?.startRangingBeacons(in: beaconRegion)
            }
            else {
                locationManager?.stopRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print( "Beacon in range")
     
//        lblBeaconDetails.hidden = false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("No beacons in range")
        
//        lblBeaconDetails.hidden = true
    }
    
    
    var beaconsInTheBag:[String:Bool?] = [:]
    var beaconsLogged:[String] = []
    var cMinorMajorKey: String!
    var signalStength: CLProximity?
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        var closestBeacon: CLBeacon!
        if usingMode == op.recording {
            if beacons.count == 0 {
                lastProximity = nil
                proximityLabel.isHidden = true
            } else {
                lastProximity = beacons.first?.proximity
                proximityLabel.isHidden = false
            }
        }
        
        if beacons.count > 0, usingMode == op.recording {
            let beacons2S = beacons.filter { $0.proximity != CLProximity.unknown }
            if beacons2S.count > 0 {
                 let closestBeacon = beacons2S[0]
                        cMinorMajorKey = closestBeacon.minor.stringValue + closestBeacon.major.stringValue
                        if beaconsInTheBag[cMinorMajorKey] == nil {
                            beaconsInTheBag[cMinorMajorKey] = true
                            trigger = point.ibeacon

                            let uniqueName = "UUID" + "-" + cMinorMajorKey
                            beaconsLogged.append(uniqueName)
                            let newWayPoint = wayPoint(recordID:nil, recordRecord: nil, UUID: globalUUID, major:closestBeacon.major as? Int, minor: closestBeacon.minor as? Int, proximity: closestBeacon.proximity, coordinates: nil, name: uniqueName, hint:nil, image: nil, order: listOfPoint2Seek.count, boxes: nil, challenge: nil,  URL: nil)
                            wayPoints[cMinorMajorKey] = newWayPoint
                            if cMinorMajorKey != nil {
                                let k2U = String(closestBeacon.minor as! Int) + String(closestBeacon.major as! Int)
                                self.beaconsInTheBag[k2U] = true
                                WP2M[k2U] = uniqueName
                            }
                            listOfPoint2Seek.append(newWayPoint)
                            performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
                        }
                }
        }
        
//        if beacons.count > 0, usingMode == op.playing, codeRunState == gameplay.playing {
        if beacons.count > 0 {
            let beacons2S = beacons.filter { $0.proximity != CLProximity.unknown }
            if beacons2S.count > 0 {
                if let closestBeacon = beacons2S[0] as? CLBeacon {
                    if order2Search! < listOfPoint2Seek.count {
                         let nextWP2S = listOfPoint2Seek[order2Search!]
                        let k2U = closestBeacon.minor.stringValue + closestBeacon.major.stringValue
                        let  alert2Post = WP2M[k2U]
                        // look for a specific/next ibeacon
                       
                        if alert2Post == nextWP2S.name {
                            if closestBeacon.proximity  == nextWP2S.proximity || nextWP2S.proximity == nil {
                                WP2M[k2U] = nil
                                updatePoint2Search(name2S: nextWP2S.name!)
                                if nextWP2S.URL != nil {
                                    if presentedViewController?.contents != WebViewController() {
                                        let url = URL(string: nextWP2S.URL! )
                                        let svc = SFSafariViewController(url: url!)
                                        present(svc, animated: true, completion: nil)
                                        self.orderLabel.text = String(order2Search!)
                                        self.judgement()
                                        self.nextLocation2Show()
                                    }
                                } else {
                                    
                                    if presentedViewController?.contents != ImageViewController() {
                                        performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
                                        self.orderLabel.text = String(order2Search!)
                                        self.judgement()
                                        self.nextLocation2Show()
                                    }
                                }
                            }
                        } else {
                            // see if you found an out of sequence ibeacon
                            if alert2Post != nil {
                                sequence(k2U: k2U, alert2U: alert2Post!)
                            }
                        }
                    }
                }
            }
        }
        var proximityMessage: String!
        
        if beacons.count > 0 {
            if let closestBeacon = beacons[0] as? CLBeacon {
//                if closestBeacon != lastFoundBeacon, lastProximity != closestBeacon.proximity  {
                    lastFoundBeacon = closestBeacon
                    editSegue?.lastProximity = closestBeacon.proximity
                    lastProximity = closestBeacon.proximity
                    switch lastFoundBeacon.proximity {
                    case CLProximity.immediate:
                        proximityMessage = "Close " + String(CLProximity.immediate.rawValue) + " "
                        hereLabel.backgroundColor = UIColor.yellow
                         nearLabel.backgroundColor = UIColor.yellow
                        farLabel.backgroundColor = UIColor.yellow
                        thereLabel.backgroundColor = UIColor.yellow
                    case CLProximity.near:
                        proximityMessage = "Near " + String(CLProximity.near.rawValue) + " "
                        hereLabel.backgroundColor = UIColor.clear
                        nearLabel.backgroundColor = UIColor.yellow
                        farLabel.backgroundColor = UIColor.yellow
                        thereLabel.backgroundColor = UIColor.yellow
                    case CLProximity.far:
                        proximityMessage = "Far " + String(CLProximity.far.rawValue) + " "
                        hereLabel.backgroundColor = UIColor.clear
                        nearLabel.backgroundColor = UIColor.clear
                        farLabel.backgroundColor = UIColor.yellow
                        thereLabel.backgroundColor = UIColor.yellow
                    default:
                        proximityMessage = "??? " + String(CLProximity.unknown.rawValue) + " "
                        hereLabel.backgroundColor = UIColor.clear
                        nearLabel.backgroundColor = UIColor.clear
                        farLabel.backgroundColor = UIColor.clear
                        thereLabel.backgroundColor = UIColor.yellow
                    }
                    self.proximityLabel.text = proximityMessage + "Maj \(closestBeacon.major.intValue) Min \(closestBeacon.minor.intValue)\n"
//                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: NSError!) {
        print(error)
    }
    
//    func locationManager(_ manager: CLLocationManager!, monitoringDidFailFor region: CLRegion?, withError error: Error) {
//        print(error)
//    }

//    func locationManager(_ manager: CLLocationManager!, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
//        print(error)
//    }
    
    private var OOS:[String:Int?] = [:]
    private var meme: String?
    private var prememe: String?

    func sequence(k2U: String, alert2U: String) {
        if OOS[k2U] == nil {
            OOS[k2U] = 0
            if WP2M[k2U] != nil, codeRunState == gameplay.playing {
                if k2U != meme {
                    meme = k2U
                    let alert = UIAlertController(title: "Sequence Jump \(alert2U) \(k2U) OOS", message:  "Do you want to SKIP ahead?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak alert] (_) in
                        
                        let index2F  = listOfPoint2Search.index(where: { (item) -> Bool in
                            item.name == alert2U
                        })
                        order2Search = index2F!
                        self.updatePoint2Search(name2S: alert2U)
                        self.judgement()
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: .default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        if OOS[k2U]!! < 24 {
            OOS[k2U] = OOS[k2U]!! + 1
        } else {
            OOS[k2U] = nil
        }
   }

    
    func getLocationDegreesFrom(latitude: Double) -> String {
        var latSeconds = Int(latitude * 3600)
//        var latitudeSeconds = abs(latitude * 3600).truncatingRemainder(dividingBy: 60)
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        
        return String(
//            format: "%d°%d'%d\"%@",
            format: "%d-%d-%d-%@",
            abs(latDegrees),
            latMinutes,
            latSeconds,
            latDegrees >= 0 ? "N" : "S"
        )
    }
    
    func getLocationDegreesFrom(longitude: Double) -> String {
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
//        var longitudeSeconds = abs(longitude * 3600).truncatingRemainder(dividingBy: 60)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        
        return String(
//            format: "%d°%d'%d\"%@",
             format: "%d-%d-%d-%@",
            abs(longDegrees),
            longMinutes,
            longSeconds,
            longDegrees >= 0 ? "E" : "W"
        )
    }
    
    func getDigitalFromDegrees(latitude: String, longitude: String) -> (Double, Double) {
        
        var n2C = latitude.split(separator: "-")
        let latS = Double(n2C[2])! / 3600
        let latM = Double(n2C[1])! / 60
        let latD = Double(n2C[0])?.rounded(toPlaces: 0)
        var DDlatitude:Double!
        if n2C[3] == "S" {
            DDlatitude = -latD! - latM - latS
        } else {
            DDlatitude = latD! + latM + latS
        }
        n2C = longitude.split(separator: "-")
        let lonS = Double(n2C[2])! / 3600
        let lonM = Double(n2C[1])! / 60
        let lonD = Double(n2C[0])?.rounded(toPlaces: 0)
        var DDlongitude:Double!
        if n2C[3]  == "W" {
            DDlongitude = -lonD! - lonM - lonS
        } else {
            DDlongitude = lonD! + lonM + lonS
        }
        return (DDlatitude,DDlongitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("User still thinking")
        case .denied:
            print("User hates you")
        case .authorizedWhenInUse:
                locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
        case .authorizedAlways:
                locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
        case .restricted:
            print("User dislikes you")
        }
        mapView.showsUserLocation = (status == .authorizedWhenInUse)
    }
    
    var regionHasBeenCentered = false
    var currentLocation: CLLocation!
    
    func updatePoint2Search(name2S: String) {
        let WP2F = wp2Search(name: name2S, find: timerLabel.text, bon: nil)
        let zap = listOfPoint2Search.index(where: { (item) -> Bool in
            item.name == name2S
        })
        if zap != nil {
            listOfPoint2Search.remove(at: zap!)
            listOfPoint2Search.insert(WP2F, at: zap!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        orderLabel.text = String(order2Search!)
        currentLocation = locations.first

        DispatchQueue.main.async {
 
            let longValue =  self.getLocationDegreesFrom(longitude: (self.locationManager?.location?.coordinate.longitude)!)
            let latValue = self.getLocationDegreesFrom(latitude: (self.locationManager?.location?.coordinate.latitude)!)
            self.longitudeLabel.text = self.getLocationDegreesFrom(longitude: (self.locationManager?.location?.coordinate.longitude)!)
            self.latitudeLabel.text =  self.getLocationDegreesFrom(latitude: (self.locationManager?.location?.coordinate.latitude)!)
            if listOfPoint2Seek.count > 0, order2Search! <  listOfPoint2Seek.count {
                let nextWP2S = listOfPoint2Seek[order2Search!]
                
                if WP2M[latValue + longValue] != nil {
                    let k2U = latValue + longValue
                    let  alert2Post = WP2M[k2U]
                    
                    if alert2Post == nextWP2S.name, usingMode == op.playing, (codeRunState == gameplay.playing || codeRunState == gameplay.finished) {
                        self.updatePoint2Search(name2S: nextWP2S.name!)
                        if nextWP2S.URL != nil {
                            if self.presentedViewController?.contents != WebViewController() {
                                let url = URL(string: nextWP2S.URL! )
                                let svc = SFSafariViewController(url: url!)
                                self.present(svc, animated: true, completion: nil)
                                self.orderLabel.text = String(order2Search!)
                                self.judgement()
                                self.nextLocation2Show()
                            }
                        } else {
                           
                            if self.presentedViewController?.contents != ImageViewController() {
                                
                                self.performSegue(withIdentifier: Constants.ShowImageSegue, sender: self.view)
                                self.orderLabel.text = String(order2Search!)
                                self.judgement()
                                self.nextLocation2Show()
                            }
                        }
                    } else {
                        if alert2Post != nil {
                            self.sequence(k2U: k2U, alert2U: alert2Post!)
                        }
                    }
                }
            }
       }
        if angle2U != nil {
            self.angle2U = self.getBearing(toPoint: nextLocation, longitude:  (self.locationManager?.location?.coordinate.longitude)!, latitude:  (self.locationManager?.location?.coordinate.latitude)!)
        }
    }
    
    private func deleteWM2M(key2U: String) {
        let key2D = WP2M[key2U]
        for rex in WP2M.keys {
            if WP2M[rex] == key2D {
                WP2M[rex] = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "LocationMgr fail", message:  "\(error)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("moving")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        showDirection2Take(direction2G: CGFloat(newHeading.magneticHeading * Double.pi/180))
    }
    
//    func handleEvent(forRegion region: CLRegion!) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Geofence Triggered", message: "Geofence Triggered", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
//        }
//    }
    
    //MARK:  Observer
    

    
    func didSet(record2U: String) {
        if !sharingApp {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert", message: record2U, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: delete waypoints by name
    
    func deleteAllWayPointsInPlace() {
        for wayP in mapView.annotations {
                mapView.removeAnnotation(wayP)
        }
    }
    
    func wayPoint2G(wayPoint2G: String) {
        for wayP in mapView.annotations {
            if wayP.title == wayPoint2G {
                mapView.removeAnnotation(wayP)
            }
        }
        let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
            item.name == wayPoint2G
        })
        if index2F != nil {
            zapBoxes(boxes2D:  listOfPoint2Seek[index2F!].boxes! as! [CLLocation])
        }
    }
    
    // MARK: setWayPoint protocl implementation
    
    func didSetProximity(name: String?, proximity: CLProximity?) {
         savedMap = false
        if proximity != nil {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == name
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].proximity = proximity
            }
        }
    }
    
    func didSetURL(name: String?, URL: String?) {
         savedMap = false
        for wayPoints in mapView.annotations {
            if wayPoints.title == name {
                let view = mapView.view(for: wayPoints)
                let image2U = UIImage(named: "noun_link_654795")
                if let thumbButton = view?.leftCalloutAccessoryView as? UIButton {
                    thumbButton.setImage(image2U, for: .normal)
                }
            }
        }
        if URL != nil {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == name
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].URL = URL
            }
        }
    }
    
    func didSetChallenge(name: String?, challenge: String?) {
         savedMap = false
        if challenge != nil {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == name
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].challenge = challenge
            }
        }
    }

    
    
    func didSetName(originalName: String?, name: String?) {
         savedMap = false
        if !(name?.isEmpty)!, originalName != nil {
            for wayPoints in mapView.annotations {
                if wayPoints.title == originalName {
                    let nWP = MKPointAnnotation()
                    nWP.coordinate  = wayPoints.coordinate
                    nWP.subtitle = wayPoints.subtitle!
                    nWP.title = name
                    mapView.removeAnnotation(wayPoints)
                    mapView.addAnnotation(nWP)
                }
            }
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == originalName!
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].name = name
            }
        }
    }
    
    func didSetHint(name: String?, hint: String?) {
         savedMap = false
        if name != nil {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == name
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].hint = hint
            }
        }
    }

    
    func didSetImage(name: String?, image: UIImage?) {
         savedMap = false
        for wayPoints in mapView.annotations {
           if wayPoints.title == name {
                let view = mapView.view(for: wayPoints)
                if let thumbButton = view?.leftCalloutAccessoryView as? UIButton {
                    thumbButton.setImage(image, for: .normal)
                }
            }
        }
        if image != nil {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == name
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].image = image
            }
        }
    }

    // MARK: MapView
    
private func getNECoordinate(mRect: MKMapRect) ->  CLLocationCoordinate2D {
        return getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mRect), y: mRect.origin.y)
}
    
private func getNWCoordinate(mRect: MKMapRect) -> CLLocationCoordinate2D {
        return getCoordinateFromMapRectanglePoint(x: MKMapRectGetMinX(mRect), y: mRect.origin.y)
}

private func getSECoordinate(mRect: MKMapRect) -> CLLocationCoordinate2D {
    return getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mRect), y: MKMapRectGetMaxY(mRect))
}
    
    private func getSWCoordinate(mRect: MKMapRect) -> CLLocationCoordinate2D {
    return getCoordinateFromMapRectanglePoint(x: mRect.origin.x, y: MKMapRectGetMaxY(mRect))
}
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D  {
        let swMapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(swMapPoint);
    }

    @IBAction func boxButton(_ sender: Any) {
        // Disabled 21.06.2018
        // 7-0-36-E
        // 46-20-22-N
        let box2D:[(Double,Double)] = [(36,22),(37,22),(37,23),(36,23),(36,22)]
        var coordinates:[CLLocationCoordinate2D] = []
        for sec2U in box2D {
                let lat2P = "7-0-\(sec2U.0)-E"
                let lon2P  = "46-20-\(sec2U.1)-N"
                let (cordLat, cordLong) = getDigitalFromDegrees(latitude: lat2P, longitude: lon2P)
                let cord2U = CLLocationCoordinate2D(latitude: cordLat, longitude: cordLong)
                coordinates.append(cord2U)
        }
        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
    }
    
    private func convert2nB(latitude2D: Double, longitude2D:Double, name2U:String) -> CLLocationCoordinate2D {

        let longValue =  self.getLocationDegreesFrom(longitude: (longitude2D))
        let latValue = self.getLocationDegreesFrom(latitude: (latitude2D))

       let (latD, longD) = getDigitalFromDegrees(latitude: latValue, longitude: longValue)
        WP2M[latValue + longValue] = name2U
        return CLLocationCoordinate2D(latitude: latD, longitude: longD)
    }
    
    var neCord:CLLocationCoordinate2D?
    var nwCord:CLLocationCoordinate2D?
    var seCord:CLLocationCoordinate2D?
    var swCord:CLLocationCoordinate2D?
    
    private func drawBox(Cords2E: CLLocationCoordinate2D,  boxColor: UIColor, corner2R: Int?) -> MKOverlay {
        var cords2D:[CLLocationCoordinate2D] = []
        
        let SWLatitude = Cords2E.latitude - Constants.Variable.magic
        let SWLongitude = Cords2E.longitude - Constants.Variable.magic
        var cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        
        if corner2R == corners.southWest {
//            doPin(cord2D: cord2U, title: "SW")
            swCord = cord2U
        }
        cords2D.append(cord2U)
        let NWLatitude = Cords2E.latitude + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: SWLongitude)
       
        if corner2R == corners.northWest {
//            doPin(cord2D: cord2U, title: "NW")
            nwCord = cord2U
        }
        cords2D.append(cord2U)
        let NELongitude = Cords2E.longitude + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NELongitude)
        
        if corner2R == corners.northEast {
//            doPin(cord2D: cord2U, title: "NE")
            neCord = cord2U
        }
        cords2D.append(cord2U)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: NELongitude)
        if corner2R == corners.southEast {
//            doPin(cord2D: cord2U, title: "SE")
            seCord = cord2U
        }
        cords2D.append(cord2U)
        
//        let polyLine:MKOverlay = MKPolyline(coordinates: &cords2D, count: cords2D.count)
        let polygon:MKOverlay = MKPolygon(coordinates: &cords2D, count: cords2D.count)
        
        DispatchQueue.main.async {
            self.polyColor = boxColor
//            self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
//            self.mapView.add(polygon, level: MKOverlayLevel.aboveRoads)
        }
//        return polyLine
        return polygon
    }
    
    private func doBoxV2(latitude2D: Double, longitude2D: Double, name: String, add2Map: Bool) -> [MKOverlay]
    {
        var boxes2R:[CLLocation] = []
        var boxes2S:[MKOverlay] = []
        
        if latitude2D + (Constants.Variable.magic/2)  > latitude2D {
            var cords2U = convert2nB(latitude2D: latitude2D + (Constants.Variable.magic*1.5), longitude2D: longitude2D, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
            var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.blue, corner2R: corners.northWest)
            
            boxes2S.append(poly2F)
            WP2P["blue"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D, name2U: name)
           cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
            poly2F =  drawBox(Cords2E: cords2U, boxColor: UIColor.orange, corner2R:  corners.southWest)
            boxes2S.append(poly2F)
            WP2P["orange"] = poly2F
        } else {
            var cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
           
            boxes2R.append(cords2F)
             var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.yellow, corner2R: corners.northWest)
            boxes2S.append(poly2F)
            WP2P["yellow"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D - (Constants.Variable.magic * 1.5), longitude2D: longitude2D, name2U: name)
            cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
             poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.orange, corner2R: corners.northWest)
            boxes2S.append(poly2F)
            WP2P["red"] = poly2F
        }
        if longitude2D + (Constants.Variable.magic/2) > longitude2D  {
            var cords2U = convert2nB(latitude2D: latitude2D + Constants.Variable.magic * 1.5, longitude2D: longitude2D + Constants.Variable.magic * 1.5, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
             var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.green, corner2R:  corners.northEast)
            boxes2S.append(poly2F)
            WP2P["purple"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D + Constants.Variable.magic * 1.5, name2U: name)
            cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
           
            boxes2R.append(cords2F)
                poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.red, corner2R: corners.southEast)
            boxes2S.append(poly2F)
            WP2P["pink"] = poly2F
        } else {
            var cords2U = convert2nB(latitude2D: latitude2D - Constants.Variable.magic * 1.5, longitude2D: longitude2D - Constants.Variable.magic * 1.5, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
             var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.green, corner2R: corners.northEast)
            boxes2S.append(poly2F)
            WP2P["cyan"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D - Constants.Variable.magic * 1.5, name2U: name)
            
            cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            boxes2R.append(cords2F)
             poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.red, corner2R:  corners.southWest)
            boxes2S.append(poly2F)
            WP2P["brown"] = poly2F
        }
        
        // newcode to draw around 4 smaller boxes
        // struct axis and size2U
        var cords2D:[CLLocationCoordinate2D] = []
        if nwCord != nil {
            cords2D.append(nwCord!)
        }
        if neCord != nil {
            cords2D.append(neCord!)
        }
        if seCord != nil {
            cords2D.append(seCord!)
        }
        if swCord != nil {
            cords2D.append(swCord!)
        }
        if cords2D.count == 4 {
             let polygon:MKOverlay = MKPolygon(coordinates: &cords2D, count: cords2D.count)
            boxes2S.append(polygon)
            if add2Map {
                DispatchQueue.main.async {
                    self.polyColor = UIColor.black
                    self.mapView.add(polygon, level: MKOverlayLevel.aboveRoads)
                }
            }
        }
        return boxes2S
    }
    
    func zapBoxes(boxes2D:[CLLocation]) {
//        let boxes2D = wP2E?.boxes
        for overlays in mapView.overlays {
            let latitude = overlays.coordinate.latitude
            let longitude = overlays.coordinate.longitude
            for boxes in boxes2D {
                let long2C:Double = ((boxes.coordinate.longitude))
                let lat2C:Double = (boxes.coordinate.latitude)
                print("\(long2C) \(lat2C) \(longitude) \(latitude)")
                if long2C == longitude, lat2C == latitude {
                    mapView.remove(overlays)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
//        let pinMoving = view.annotation?.title
        savedMap = false
        
        if newState == MKAnnotationViewDragState.starting {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == view.annotation?.title
            })
            if index2F != nil {
                let boxes2D =  listOfPoint2Seek[index2F!].boxes
//                listOfPoint2Seek[index2F!].boxes = box2F
                if boxes2D != nil {
                    for overlays in mapView.overlays {
                        let latitude = overlays.coordinate.latitude
                        let longitude = overlays.coordinate.longitude
                        for boxes in boxes2D! {
                            let long2C:Double = ((boxes?.coordinate.longitude)!)
                            let lat2C:Double = (boxes?.coordinate.latitude)!
                            print("\(long2C) \(lat2C) \(longitude) \(latitude)")
                            if long2C == longitude, lat2C == latitude {
                                mapView.remove(overlays)
                            }
                        }
                    }
                }
            }
//            let wP2E = wayPoints[((view.annotation?.title)!)!]
//
//            let boxes2D = wP2E?.boxes

        }
        if newState == MKAnnotationViewDragState.ending {
            let boxes = self.doBoxV2(latitude2D: (view.annotation?.coordinate.latitude)!, longitude2D: (view.annotation?.coordinate.longitude)!, name: ((view.annotation?.title)!)!, add2Map: true)
            var box2F:[CLLocation] = []
            for box in boxes {
                box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
            }
//            wayPoints[((view.annotation?.title)!)!]?.boxes = box2F
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name == view.annotation?.title
            })
            if index2F != nil {
                listOfPoint2Seek[index2F!].boxes = box2F
                listOfPoint2Seek[index2F!].coordinates = view.annotation?.coordinate
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapview region changed")
//        let answer = getBoundingBox(mRect: mapView.visibleMapRect)
//        print("mapview region changed \(answer)")
    }
    
    private func clearWaypoints() {
        mapView?.removeAnnotation(mapView.annotations as! MKAnnotation)
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    
    class MyPointAnnotation : MKPointAnnotation {
//        var pinColor: UIColor
//
//        init(pinColor: UIColor) {
//            self.pinColor = pinColor
//            super.init()
//        }
        var tintColor: UIColor?
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //check annotation is not user location
//        let userLongitude = mapView.userLocation.coordinate.longitude
//        let userLatitiude = mapView.userLocation.coordinate.latitude
//        if annotation.coordinate.longitude == userLongitude, annotation.coordinate.latitude == userLatitiude {
//            return nil
//        }
        if annotation is MKUserLocation {
            return nil
        }
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier) as? MKPinAnnotationView
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
            view.tintColor = .blue
            
        } else {
            view.annotation = annotation
            view?.tintColor = .green
        }
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view.leftCalloutAccessoryView  = UIButton(frame: Constants.LeftCalloutFrame)
        
     
        view.isDraggable = true
        
        return view
    }
    
    private var pinViewSelected: MKPointAnnotation!
//    private var pinView: MKAnnotationView!
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        pinViewSelected = view.annotation as? MKPointAnnotation
//        pinView = view
//        if usingMode == op.recording {
//            mapView.deselectAnnotation(view.annotation, animated: false)
//            performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
//        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name ==  view.annotation?.title
            })
            let URL2U  = listOfPoint2Seek[index2F!].URL
            let image2U = listOfPoint2Seek[index2F!].image
            let order2U =  listOfPoint2Seek[index2F!].order
            if URL2U != nil {
                let url = URL(string: URL2U!)
                let svc = SFSafariViewController(url: url!)
                self.present(svc, animated: true, completion: nil)
            } else if image2U != nil {
                order2Search = order2U
                self.performSegue(withIdentifier: Constants.ShowImageSegue, sender: self.view)
            }
        } else if control == view.rightCalloutAccessoryView, usingMode != .playing {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
        }
    }
    
    var polyColor: UIColor = UIColor.red
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.yellow.withAlphaComponent(0.2)
            return circleRenderer
        } else  if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = polyColor
            renderer.lineWidth = 1
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.strokeColor = polyColor
            renderer.lineWidth = 1
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    private func region(withPins region2D: CKRecord) -> CLCircularRegion {
        let longitude = region2D.object(forKey:  Constants.Attribute.longitude) as? Double
        let latitude = region2D.object(forKey:  Constants.Attribute.latitude) as? Double
        let name = region2D.object(forKey:  Constants.Attribute.name) as? String
        let r2DCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude:longitude!)
//        let maxDistance = locationManager?.maximumRegionMonitoringDistance
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Monitoring available")
        }
        
        let region = CLCircularRegion(center: r2DCoordinates, radius: CLLocationDistance(Constants.Variable.radius), identifier: name!)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func addRadiusOverlay(forGeotification region2D: CKRecord) {
        let longitude = region2D.object(forKey:  Constants.Attribute.longitude) as? Double
        let latitude = region2D.object(forKey:  Constants.Attribute.latitude) as? Double
       
        let r2DCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude:longitude!)
        DispatchQueue.main.async {
            self.mapView?.add(MKCircle(center: r2DCoordinates, radius: CLLocationDistance(Constants.Variable.radius)))
        }
    }
    
    // MARK: UIAlertController + iCloud code
    
    func isICloudContainerAvailable()->Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
    }
    
    var linksRecord: CKReference!
    var mapRecord: CKRecord!

    var recordZoneID: CKRecordZoneID!
    var recordID: CKRecordID!
    
//    var records2MaybeDelete:[CKRecordID] = []
    
    @IBAction func newMap(_ sender: UIBarButtonItem) {
        if recordZone   == nil {
            shareButton.isEnabled = false
            playButton.isEnabled = false
            nouveauMap(source: true)
        } else {
//            plusButton.isEnabled = false
            for rework in 0..<listOfPoint2Seek.count {
                listOfPoint2Seek[rework].recordID = nil
                listOfPoint2Seek[rework].recordRecord = nil
            }
            shareButton.isEnabled = false
            playButton.isEnabled = false
            nouveauMap(source: true)
        }
    }
    
    var resetShareNPlay: Bool? {
        willSet {
            DispatchQueue.main.async {
                self.shareButton.isEnabled = true
                self.playButton.isEnabled = true
            }
        }
    }
    
    private func nouveauMap(source: Bool) {
        usingMode = op.recording
        var alert2U: String!
        if source {
            alert2U = "Map Name"
        } else {
            alert2U = "You NEED to define a Map Name first, nothing SHARED!"
        }
        let alert = UIAlertController(title: "Map Name", message: alert2U, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Map Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                self.navigationItem.title = (textField?.text)!
                if zoneTable[(textField?.text)!] != nil {
                    self.share2Load(zoneNamed: (textField?.text)!)
                    if listOfPoint2Seek.count == 0 {
                        // if you have no records in a zone, you need to go get the zone
                        self.zoneRecord2Load(zoneNamed: (textField?.text)!)
                    }
                } else {
                    recordZone = CKRecordZone(zoneName: (textField?.text)!)
                   
                    self.saveZone(zone2S: recordZone)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
        self.present(alert, animated: true, completion: nil)
        plusButton.isEnabled = false
    }
    
    // MARK: CloudSharing delegate
    
    func saveZone(zone2S: CKRecordZone) {
        self.privateDB.save(zone2S, completionHandler: ({returnRecord, error in
            if error != nil {
                // Zone creation failed
                self.parseCloudError(errorCode: error as! CKError, lineno: 1392)
            } else {
                // Zone creation succeeded
                recordZone = returnRecord
                self.doshare(rexShared: nil, withoutSavingChildren: true)
                
//                self.doshare(rexShared: nil)
            }
        }))
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print(error)
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return recordZone.zoneID.zoneName
    }
    
    func itemThumbnailData(for: UICloudSharingController) -> Data? {
        return nil
    }
    
    // MARK: iCloudKit
    
    private var _ckWayPointRecord: CKRecord? {
        didSet {
            
        }
    }
    
    var ckWayPointRecord: CKRecord {
        get {
            if _ckWayPointRecord == nil {
                _ckWayPointRecord = CKRecord(recordType: Constants.Entity.wayPoints )
            }
            return _ckWayPointRecord!
        }
        set {
            _ckWayPointRecord = newValue
        }
    }
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    private let sharedDB = CKContainer.default().sharedCloudDatabase
    private var operationQueue = OperationQueue()
    private var sharingApp = false
    private var records2Share:[CKRecord] = []
    private var records2Update:[CKRecord] = []
    private var sharePoint: CKRecord?
    
//    func mergeList(rex2S:[wayPoint]?) -> ([wayPoint]?, Int) {
//
//    }
    
    func save2Cloud(rex2S:[wayPoint]?, rex2D:[CKRecordID]?, sharing: Bool, reordered: Bool) {
//        print("fcuk02082018 recordZone.zoneID.ownerName \(recordZone.zoneID.ownerName)")
        if recordZone == nil {
            nouveauMap(source: false)
            DispatchQueue.main.async() {
                if self.spinner != nil {
                    self.spinner.stopAnimating()
                    self.spinner.removeFromSuperview()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            return
        }
        sharingApp = true
      save2CloudV2(rex2S: rex2S, rex2D: rex2D, sharing: sharing, reordered: reordered)
        savedMap = true
        //        var dispatchDelay = 0
        //         if sharePoint == nil {
        //            dispatchDelay = 2
        //        }
        //        let when = DispatchTime.now() + Double(dispatchDelay)
        //        DispatchQueue.main.asyncAfter(deadline: when){
        //            if self.sharePoint == nil {
        //                            return
        //            }
        //
        //        self.operationQueue.maxConcurrentOperationCount = 1
        //        self.operationQueue.waitUntilAllOperationsAreFinished()
        
        //        }
    }
    
    func updateRecord(wp2S: wayPoint, p2S: Int, reorder: Bool) -> CKRecord? {
        if wp2S.recordID == nil {
            let record = CKRecord(recordType: Constants.Entity.wayPoints, zoneID: recordZone.zoneID)
            let record2S = self.setRecord(wp2S: wp2S, record: record, p2S: p2S, reorder: reorder)
            return record2S
        } else {
            let record2S = self.setRecord(wp2S: wp2S, record: wp2S.recordRecord, p2S: p2S, reorder: reorder)
             return record2S
        }
        return nil
    }
    
    func saveRecord(record2S: CKRecord) {
        self.privateDB.save(record2S, completionHandler: { (savedRecord, saveError) in
            if saveError != nil {
                print("Error saving record: \(saveError?.localizedDescription)")
            } else {
                print("Successfully updated record!")
                let order2D = savedRecord?.object(forKey: "order") as? Int
                listOfPoint2Seek[order2D!].recordID = savedRecord?.recordID
            }
        })
    }
    
    func setRecord(wp2S: wayPoint, record:CKRecord?, p2S:Int, reorder: Bool) -> CKRecord {
        let long2F:Double = (wp2S.coordinates?.longitude)!
        let lat2F:Double = (wp2S.coordinates?.latitude)!
        record?.setObject(long2F as CKRecordValue, forKey: Constants.Attribute.longitude)
        record?.setObject(lat2F as CKRecordValue, forKey: Constants.Attribute.latitude)
        record?.setObject(wp2S.name as CKRecordValue?, forKey: Constants.Attribute.name)
        record?.setObject(wp2S.hint as CKRecordValue?, forKey: Constants.Attribute.hint)
        record?.setObject((wp2S.boxes! as CKRecordValue), forKey:  Constants.Attribute.boxes)
        record?.setObject(wp2S.major as CKRecordValue?, forKey:  Constants.Attribute.major)
        record?.setObject(wp2S.minor as CKRecordValue?, forKey:  Constants.Attribute.minor)
        record?.setObject(wp2S.proximity?.rawValue as CKRecordValue?, forKey:  Constants.Attribute.proximity)
        record?.setObject(wp2S.UUID as CKRecordValue?, forKey: Constants.Attribute.UUID)
        record?.setObject(wp2S.challenge as CKRecordValue?, forKey: Constants.Attribute.challenge)
        record?.setObject(wp2S.URL as CKRecordValue?, forKey: Constants.Attribute.URL)
        if reorder {
            record?.setObject(wp2S.order as CKRecordValue?, forKey: Constants.Attribute.order)
        } else {
            record?.setObject(p2S as CKRecordValue?, forKey: Constants.Attribute.order)
        }
        record?.setParent(self.sharePoint)
        let data2U = self.returnImage2U(image2U: wp2S)
        if let _ = wp2S.name {
            let file2ShareURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
            do {
                try data2U.write(to: file2ShareURL!, options: .atomicWrite)
                let newAsset = CKAsset(fileURL: file2ShareURL!)
                record?.setObject(newAsset as CKAsset?, forKey: Constants.Attribute.imageData)
                self.records2Share.append(record!)
            } catch let e as NSError {
                print("Error! \(e)");
            }
        }
        return record!
    }
    
    func returnImage2U(image2U:wayPoint?) -> Data {
        var image2D: Data!
        if image2U?.image != nil {
            let newImage = image2U?.image?.resize(size: CGSize(width: 1080, height: 1920))
            image2D = UIImageJPEGRepresentation(newImage!, 1.0)
        } else {
            image2D = UIImageJPEGRepresentation(UIImage(named: "noun_1348715_cc")!, 1.0)
        }
        return image2D
    }
    
   
    func save2CloudV2(rex2S:[wayPoint]?, rex2D:[CKRecordID]?, sharing: Bool, reordered: Bool) {
        var rex2Skip:[String] = []
        var records2Save:[CKRecord] = []
        let query = CKQuery(recordType: "Waypoints", predicate: NSPredicate(value: true))
        print("fcuk07082018 recordZoneID \(recordZoneID) \(recordZone.zoneID)")
        privateDB.perform(query, inZoneWith: recordZone.zoneID) { (records, error) in
            if error != nil {
                self.parseCloudError(errorCode: error as! CKError, lineno: 1557)
            } else {
            records?.forEach({ (record) in
                let find = listOfPoint2Seek.filter { $0.name == record.value(forKey: "name") as! String }
                if !find.isEmpty {
                     listOfPoint2Seek[(find.first?.order!)!].recordID = record.recordID
                    listOfPoint2Seek[(find.first?.order!)!].recordRecord = record
                }
                })
                var p2S = 0
                for point2Save in rex2S! {
                    let record2Save = self.updateRecord(wp2S: point2Save, p2S: p2S, reorder: reordered)
                    if record2Save != nil {
                        records2Save.append(record2Save!)
                    }
                    p2S += 1
                }
                let saveOp = CKModifyRecordsOperation(recordsToSave:
                    records2Save, recordIDsToDelete: rex2D)
                saveOp.savePolicy = .allKeys
                saveOp.perRecordCompletionBlock = {(record,error) in
                    print("error \(error.debugDescription)")
                    let find = listOfPoint2Seek.filter { $0.name == record.value(forKey: "name") as! String }
                    if !find.isEmpty {
                        listOfPoint2Seek[(find.first?.order!)!].recordID = record.recordID
                        listOfPoint2Seek[(find.first?.order!)!].recordRecord = record
                    }
                }
                saveOp.modifyRecordsCompletionBlock = { (record, recordID,
                    error) in
                    if error != nil {
                        print("error \(error.debugDescription)")
                        self.parseCloudError(errorCode: error as! CKError, lineno: 1589)
                    }
                }
                
                self.privateDB.add(saveOp)
                print("fcuk07082018 records \(records?.count)")
            }
        }
        
        DispatchQueue.main.async {
            

                
           print("fcuk02082018 records2Share \(self.records2Share.count)")
            
            let modifyOp = CKModifyRecordsOperation(recordsToSave:
                self.records2Share, recordIDsToDelete: rex2D)
            modifyOp.savePolicy = .allKeys
//            modifyOp.perRecordCompletionBlock = {(record,error) in
//                print("error \(record) \(error.debugDescription)")
//            }
            modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                error) in
                if error != nil {
                    print("error \(error.debugDescription)")
                    self.parseCloudError(errorCode: error as! CKError, lineno: 1614)
                }
                
//                for rex in record! {
//                    let rex2U = listOfWayPointsSaved.filter { $0.order == rex.object(forKey:  Constants.Attribute.order) as? Int }
//                    listOfWayPointsSaved[(rex2U.first?.order)!].recordRecord = rex
//                }
                DispatchQueue.main.async() {
                    if self.spinner != nil {
                        self.spinner.stopAnimating()
                        self.spinner.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                if sharing {
                    self.sharing(record2S: self.sharePoint!)
                    order2Search = listOfPoint2Seek.count
                }
//                listOfPoint2Seek = listOfWayPointsSaved
            }
            self.privateDB.add(modifyOp)
        }
    }
    
    func parseCloudError(errorCode: CKError, lineno: Int) {
        switch errorCode {
            case CKError.internalError:
                doAlert(title: "iCloudError" + String(lineno), message:  "CloudKit.framework encountered an error.  This is a non-recoverable error.")
                break
            case CKError.partialFailure:
                doAlert(title: "iCloudError" + String(lineno), message:  "Some items failed, but the operation succeeded overall.")
            break
            case CKError.networkUnavailable:
                doAlert(title: "iCloudError" + String(lineno), message:  "Network not available.")
            break
            case CKError.networkFailure:
                 doAlert(title: "iCloudError" + String(lineno), message:  "Network error (available but CFNetwork gave us an error).")
            break
            case CKError.badContainer:
                doAlert(title: "iCloudError" + String(lineno), message:  "Un-provisioned or unauthorized container. Try provisioning the container before retrying the operation.")
            break
            case CKError.serviceUnavailable:
                doAlert(title: "iCloudError" + String(lineno), message:  "Service unavailable.")
            break
            case CKError.requestRateLimited:
                doAlert(title: "iCloudError" + String(lineno), message:  "Client is being rate limited.")
            break
            case CKError.missingEntitlement:
                doAlert(title: "iCloudError" + String(lineno), message:  "Missing entitlement.")
            break
            case CKError.notAuthenticated:
                doAlert(title: "iCloudError" + String(lineno), message:  "Not authenticated (writing without being logged in, no user record).")
            break
            case CKError.permissionFailure:
                doAlert(title: "iCloudError" + String(lineno), message:  "Access failure (save or fetch.  This is a non-recoverable error.")
            break
            case CKError.unknownItem:
                doAlert(title: "iCloudError" + String(lineno), message:  "Record does not exist.  This is a non-recoverable error.")
            break
            case CKError.invalidArguments:
                doAlert(title: "iCloudError" + String(lineno), message:  "Bad client request (bad record graph, malformed predicate).")
            break
        case CKError.serverRecordChanged:
            doAlert(title: "iCloudError" + String(lineno), message:  "The record was rejected because the version on the server was different.")
            break
        case CKError.serverRejectedRequest:
            doAlert(title: "iCloudError" + String(lineno), message:  "The server rejected this request.  This is a non-recoverable error.")
            break
        case CKError.assetFileNotFound:
           doAlert(title: "iCloudError" + String(lineno), message:  "Asset file was not found.")
            break
        case CKError.assetFileModified:
            doAlert(title: "iCloudError" + String(lineno), message:  "Asset file content was modified while being saved.")
            break
        case CKError.incompatibleVersion:
            doAlert(title: "iCloudError" + String(lineno), message:  "App version is less than the minimum allowed version.")
            break
        case CKError.constraintViolation: /*  */
            doAlert(title: "iCloudError" + String(lineno), message:  "The server rejected the request because there was a conflict with a unique field.")
            break
        case CKError.operationCancelled: /* */
            doAlert(title: "iCloudError" + String(lineno), message:  "A CKOperation was explicitly cancelled.")
            break
        case CKError.changeTokenExpired: /*  */
            doAlert(title: "iCloudError" + String(lineno), message:  "The previousServerChangeToken value is too old and the client must re-sync from scratch.")
            break
        case CKError.batchRequestFailed:
            doAlert(title: "iCloudError" + String(lineno), message:  "One of the items in this batch operation failed in a zone with atomic updates, so the entire batch was rejected.")
            break
        case CKError.zoneBusy:
            doAlert(title: "iCloudError" + String(lineno), message:  "The server is too busy to handle this zone operation. Try the operation again in a few seconds.")
            break
        case CKError.badDatabase:
            doAlert(title: "iCloudError" + String(lineno), message:  "Operation could not be completed on the given database. Likely caused by attempting to modify zones in the public database.")
            break
        case CKError.quotaExceeded:
           doAlert(title: "iCloudError" + String(lineno), message:  "Saving a record would exceed quota.")
            break
        case CKError.zoneNotFound:
            doAlert(title: "iCloudError" + String(lineno), message:  "The specified zone does not exist on the server.")
            break
        case CKError.limitExceeded:
           doAlert(title: "iCloudError" + String(lineno), message:  "The request to the server was too large. Retry this request as a smaller batch")
            break
        case CKError.userDeletedZone:
            doAlert(title: "iCloudError" + String(lineno), message:  "The user deleted this zone through the settings UI. Your client should either remove its local data or prompt the user before attempting to re-upload any data to this zone.")
            break
        default:
            // do nothing
            break
        }
    }
    
    func doAlert(title: String, message:String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
        
        // new code added for parent setup 2nd try
    func doshare(rexShared: [CKRecord]?, withoutSavingChildren: Bool) {
        
//        if listOfPoint2Seek.count == 0 {
            sharePoint = CKRecord(recordType: Constants.Entity.mapLinks, zoneID: recordZone.zoneID)
        parentID = CKReference(record: self.sharePoint!, action: .none)
//        }
//        var recordID2Share:[CKReference] = []
        
//        for rex in self.records2Share {
////            let parentR = CKReference(record: self.parentID, action: .none)
//            rex.parent = parentID
//            let childR = CKReference(record: rex, action: .deleteSelf)
//            recordID2Share.append(childR)
//        }
        
        sharePoint?.setObject(recordZone.zoneID.zoneName as CKRecordValue, forKey: Constants.Attribute.mapName)
//        privateDB.save(sharePoint!) { (savedRecord, error) in
//            if error != nil {
//                print("error \(error.debugDescription)")
//            }
        
//            let modifyOp = CKModifyRecordsOperation(recordsToSave:
//                self.records2Share, recordIDsToDelete: nil)
            let modifyOp = CKModifyRecordsOperation(recordsToSave:
                [sharePoint!], recordIDsToDelete: nil)
            modifyOp.savePolicy = .changedKeys
            modifyOp.perRecordCompletionBlock = {(record,error) in
                print("error \(error.debugDescription)")
            }
            modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                error) in
                if error != nil {
                    print("error \(error.debugDescription)")
                    self.parseCloudError(errorCode: error as! CKError, lineno: 1769)
                }
//                self.sharing(record2S: self.sharePoint)
//                self.save2CloudV2(rex2S: listOfPoint2Seek, rex2D: nil, sharing: false, reordered: false)
                self.resetShareNPlay = true
            }
            self.privateDB.add(modifyOp)
//        }
        return
    }
    
    //       let file2ShareURL = documentsDirectoryURL.appendingPathComponent("image2SaveX")
    //        if listOfPoint2Seek.count != wayPoints.count {
    //            listOfPoint2Save = Array(wayPoints.values.map{ $0 })
    //        }
    
    //        self.recordZone = CKRecordZone(zoneName: "LeZone")
    //        CKContainer.default().discoverAllIdentities { (users, error) in
    //            print("identities \(users) \(error)")
    //        }
    //
    //        CKContainer.default().discoverUserIdentity(withEmailAddress:"mark.lucking@gmail.com") { (id,error ) in
    //            print("identities \(id.debugDescription) \(error)")
    //            self.userID = id!
    //        }
        
    func sharing(record2S: CKRecord) {
        
//        let record2S = records2Share.first!
//        let record2S = self.sharePoint
        
        let share = CKShare(rootRecord: record2S)
                    share[CKShareTitleKey] = "My Next Share" as CKRecordValue
                    share.publicPermission = .none
            
            DispatchQueue.main.async {
                    let sharingController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler:
                        @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                        let modifyOp = CKModifyRecordsOperation(recordsToSave:
                            [record2S, share], recordIDsToDelete: nil)
                        modifyOp.savePolicy = .allKeys
                        modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                            error) in
                            handler(share, CKContainer.default(), error)
                        }
                        CKContainer.default().privateCloudDatabase.add(modifyOp)
                    })
                    sharingController.availablePermissions = [.allowReadWrite,
                                                              .allowPrivate]
                    sharingController.delegate = self
                    sharingController.popoverPresentationController?.sourceView = self.view
            
                    self.present(sharingController, animated:true, completion:nil)
                }
        }
    
    func undoLive() {
        pin.isEnabled = true
        scanButton.isEnabled = true
        plusButton.isEnabled = true
        usingMode  = op.recording
        windowView = .points
    }
    
    func doLive() {
         listOfPoint2Search.removeAll()
        windowView = .playing
        pin.isEnabled = false
        scanButton.isEnabled = false
        plusButton.isEnabled = false
        getShare(mode2D: false)
        for rex in listOfPoint2Seek {
            let rex2D = wp2Search(name: rex.name, find: nil, bon: false)
            listOfPoint2Search.append(rex2D)

            let boxes = rex.boxes
            DispatchQueue.main.async {
                if boxes != nil {
                    for _ in boxes! {
                        let wp2FLat = self.getLocationDegreesFrom(latitude:(rex.coordinates?.latitude)!)
                        let wp2FLog = self.getLocationDegreesFrom(longitude: (rex.coordinates?.longitude)!)
                        WP2M[wp2FLat+wp2FLog] = rex.name
                    }
                }
                if rex.major != nil, rex.minor != nil {
                    let k2U = String(rex.minor!) + String(rex.major!)
                    self.beaconsInTheBag[k2U] = true
                    WP2M[k2U] = rex.name
                }
            }
        }
        codeRunState = gameplay.playing
       
        self.topView.bringSubview(toFront: self.lowLabel)
        self.topView.bringSubview(toFront: self.highLabel)
        let when = DispatchTime.now() + Double(0)
        usingMode = op.playing
        DispatchQueue.main.asyncAfter(deadline: when){            self.runMode()
        }
    }
        
func fetchShare() {
        windowView = .playing
        pin.isEnabled = false
        scanButton.isEnabled = false
        plusButton.isEnabled = false
        getShare(mode2D: true)
        codeRunState = gameplay.playing
//        resetTitles()
        self.topView.bringSubview(toFront: self.lowLabel)
        self.topView.bringSubview(toFront: self.highLabel)
    }
    
    @IBAction func saveB(_ sender: Any) {
        if usingMode == op.recording, listOfPoint2Seek.count > 0 {
            doLive()
        }
        saveImage()
    }
    
    
    
    func getParticipant() {
//        CKContainer.default().discoverAllIdentities { (identities, error) in
//            print("identities \(identities.debugDescription)")
//        }
    }
//
//    private var userID: CKUserIdentity!
//
    
    var nextLocation: CLLocationCoordinate2D!
    var angle2U: Double? = nil
    
    func getShare(mode2D: Bool) {
        usingMode = op.playing
        mapView.alpha = 0.7
        centerImage.image = UIImage(named: "compassClip")
        compassRing.image = UIImage(named: "compassRing")
        if mode2D {
            listOfPoint2Seek = []
            listOfPoint2Search = []
            if currentZone == nil {
                let alert = UIAlertController(title: "Map Name", message: "", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Map Name"
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    if textField?.text != "" {
                        self.navigationItem.title = textField?.text
                        self.share2Load(zoneNamed: (textField?.text)!)
                        self.zoneRecord2Load(zoneNamed: (textField?.text)!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func share2Source(zoneID: CKRecordZoneID?) {
        DispatchQueue.main.async {
            self.mapView.alpha = 0.7
            listOfPoint2Seek = []
            self.centerImage.image = UIImage(named: "compassClip")
            self.compassRing.image = UIImage(named: "compassRing")
        }
        recordZoneID = zoneID
        let predicate = NSPredicate(value: true)
//        let predicate = NSPredicate(format: "owningList == %@", recordZoneID)
        //        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        DispatchQueue.main.async() {
            self.spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 64, height: 64))
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.spinner)
            self.spinner.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        sharedDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(String(describing: error))")
                self.parseCloudError(errorCode: error as! CKError, lineno: 1952)
            }
            for record in records! {
                self.buildWaypoint(record2U: record)
            }
//            self.confirmSequenced()
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                let when = DispatchTime.now() + Double(4)
                DispatchQueue.main.asyncAfter(deadline: when){
                    if usingMode == op.playing {
                        self.countLabel.text  = String(listOfPoint2Seek.count)
                        self.lowLabel.isHidden = false
                        self.highLabel.isHidden = false
                        self.nextLocation2Show()
                        self.makeTimer()
                        self.timerLabel.isHidden = false
                        self.countLabel.isHidden = false
                        self.spinner.removeFromSuperview()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
    }
    
    func zoneRecord2Load(zoneNamed: String?) {
        recordZone = CKRecordZone(zoneName: zoneNamed!)
        recordZoneID = recordZone.zoneID
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "mapLinks", predicate: predicate)
        privateDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(String(describing: error))")
                self.parseCloudError(errorCode: error as! CKError, lineno: 1986)
            }
            for record in records! {
                
                // there is always only a single record here!!
                self.sharePoint = record
                self.resetShareNPlay = true
            }
        }
    }
    
    var readinrecords: Int?
    
    func share2Load(zoneNamed: String?)  {
//        spotOrderError.removeAll()
//            records2MaybeDelete.removeAll()
            recordZone = CKRecordZone(zoneName: zoneNamed!)
            recordZoneID = recordZone.zoneID
        
        
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        privateDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(String(describing: error))")
                self.parseCloudError(errorCode: error as! CKError, lineno: 2013)
            }

            for record in records! {
               
                self.buildWaypoint(record2U: record)
                
//                self.records2MaybeDelete.append(record.recordID)
            }
            self.readinrecords  = records?.count
            DispatchQueue.main.async() {
                if self.spinner != nil {
                    self.spinner.stopAnimating()
                    self.spinner.removeFromSuperview()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
            let when = DispatchTime.now() + Double(4)
            DispatchQueue.main.asyncAfter(deadline: when){
                self.runMode()
            }
        }
    }
    
    func runMode() {
        if usingMode == op.playing {
            self.countLabel.text  = String(listOfPoint2Seek.count)
            self.lowLabel.isHidden = false
            self.highLabel.isHidden = false
            self.nextLocation2Show()
            self.makeTimer()
            self.timerLabel.isHidden = false
            self.countLabel.isHidden = false
        }
    }
    
//    private func fetchRex(recordID: CKRecordID) -> CKRecord {
//        let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
//        var record2R: CKRecord!
//        fetchOperation.fetchRecordsCompletionBlock = {
//            records, error in
//            if error != nil {
//                print("\(error!)")
//            } else {
//                record2R = records?.first?.value
//            }
//        }
//        privateDB.add(fetchOperation)
//    }
    
    private func fetchParentX(recordID: CKRecordID)  {
        let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
        fetchOperation.fetchRecordsCompletionBlock = {
            records, error in
            if error != nil {
                print("\(error!)")
                self.parseCloudError(errorCode: error as! CKError, lineno: 2070)
            } else {
                for (_, record) in records! {
                    self.sharePoint = record
                }
            }
        }
        privateDB.add(fetchOperation)
    }
    
    private var spotOrderError:[Int:Bool?] = [:]
    var spotDuplicateError:[String:Bool]? = [:]
    
    private func buildWaypoint(record2U: CKRecord) {

        let longitude = record2U.object(forKey:  Constants.Attribute.longitude) as? Double
        let latitude = record2U.object(forKey:  Constants.Attribute.latitude) as? Double
        let major = record2U.object(forKey: Constants.Attribute.major) as? Int
        let minor = record2U.object(forKey: Constants.Attribute.minor) as? Int
        globalUUID = record2U.object(forKey: Constants.Attribute.UUID) as? String

        parentID = record2U.parent
        if usingMode == op.recording {
            if parentID != nil,  sharePoint == nil {
                fetchParentX(recordID: (parentID?.recordID)!)
            }
        }
            let url2U = record2U.object(forKey: Constants.Attribute.URL) as? String
            let name = record2U.object(forKey:  Constants.Attribute.name) as? String
            let hint = record2U.object(forKey:  Constants.Attribute.hint) as? String
            let order = record2U.object(forKey:  Constants.Attribute.order) as? Int
            let proximity = record2U.object(forKey: Constants.Attribute.proximity) as? Int
            let boxes = record2U.object(forKey: Constants.Attribute.boxes) as? [CLLocation]
            let challenge = record2U.object(forKey: Constants.Attribute.challenge) as? String
            let file : CKAsset? = record2U.object(forKey: Constants.Attribute.imageData) as? CKAsset
            var image2D: UIImage!
            if let data = NSData(contentsOf: (file?.fileURL)!) {
                image2D = UIImage(data: data as Data)
            }
            if major == nil {
                let k2C = "\(String(describing: longitude)) \(String(describing: latitude?.description))"
                if spotDuplicateError![k2C] == nil {
                    let wp2S = wayPoint(recordID: record2U.recordID, recordRecord: record2U, UUID: nil, major:major, minor: minor, proximity: nil, coordinates: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), name: name, hint: hint, image: image2D, order: order, boxes: boxes, challenge: challenge, URL: url2U)
                     listOfPoint2Seek.append(wp2S)
                    let wp2S2 = wp2Search(name: name, find: nil, bon: nil)
                    listOfPoint2Search.append(wp2S2)
                    spotDuplicateError![k2C]  = true
                }
            } else {
                let k2U = String(minor!) + String(major!)
                 if spotDuplicateError![k2U] == nil {
                    let prox2U = CLProximity(rawValue: proximity!)
                    let wp2S = wayPoint(recordID: record2U.recordID,recordRecord: record2U, UUID: globalUUID, major:major, minor: minor, proximity: prox2U, coordinates: nil, name: name, hint: hint, image: image2D, order: order, boxes: nil, challenge: challenge, URL: url2U)
                    listOfPoint2Seek.append(wp2S)
                    // set this just in case you want to define more ibeacons
                   
                    beaconsInTheBag[k2U] = true
                    WP2M[k2U] = name
                    let wp2S2 = wp2Search(name: name, find: nil, bon: nil)
                    listOfPoint2Search.append(wp2S2)
                    spotDuplicateError![k2U]  = true
                }
            }
        self.plotPin(pin2P: record2U, index2F:(listOfPoint2Seek.count - 1))
        
//            let region2M = self.region(withPins: record2U)
//            self.addRadiusOverlay(forGeotification: record2U)
//            self.locationManager?.startMonitoring(for: region2M)
           
            DispatchQueue.main.async {
                if boxes != nil {
                    for _ in boxes! {
//                        self.drawBox(Cords2E: boxes2D.coordinate, boxColor: UIColor.red)
                        let wp2FLat = self.getLocationDegreesFrom(latitude: latitude!)
                        let wp2FLog = self.getLocationDegreesFrom(longitude: longitude!)
                        WP2M[wp2FLat+wp2FLog] = name
                    }
                }
        }
    }
    
    var fireme: Bool! {
        didSet {
            _ = confirmSequenced()
        }
    }
    
    
    
    private func confirmSequenced() -> Bool {
        var bonSequence = 0
        for items in listOfPoint2Seek {
            if items.order == bonSequence {
                bonSequence += 1
            }
        }
        if bonSequence != listOfPoint2Seek.count {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Out Of Sequence", message: "Not Shared, sequence MUST start @ zero", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return false
        }
        return true
    }
    
    private func nextLocation2Show() {
        if codeRunState == gameplay.finished {
//            UIView.animate(withDuration: 4.0) {
//                self.latitudeNextLabel.alpha = 0
//                self.longitudeNextLabel.alpha = 0
//                self.timerLabel.alpha = 0
//                self.countLabel.alpha = 0
//                self.orderLabel.alpha = 0
//            }
//            self.highLabel.text = "You Finished!! Well done!!"
        }
        if order2Search == 0, usingMode == op.playing {
            // do splash
        }
        if order2Search! < listOfPoint2Seek.count, usingMode == op.playing {
            let nextWP2S = listOfPoint2Seek[(order2Search!)]
            if nextWP2S.UUID == nil {
                self.latitudeNextLabel.isHidden = false
                self.longitudeNextLabel.isHidden = false
                self.longitudeNextLabel.text = self.getLocationDegreesFrom(longitude: (nextWP2S.coordinates?.longitude)!)
                self.latitudeNextLabel.text = self.getLocationDegreesFrom(latitude: (nextWP2S.coordinates?.latitude)!)
                self.nextLocation = CLLocationCoordinate2DMake((nextWP2S.coordinates?.latitude)!, (nextWP2S.coordinates?.longitude)!)
                self.angle2U = self.getBearing(toPoint: self.nextLocation, longitude:  (self.locationManager?.location?.coordinate.longitude)!, latitude:  (self.locationManager?.location?.coordinate.latitude)!)
                self.hintLabel.text = nextWP2S.hint
                self.nameLabel.text = nextWP2S.name
                self.hintLabel.isHidden = false
                self.nameLabel.isHidden = false
                self.latitudeNextLabel.isHidden = false
                self.longitudeNextLabel.isHidden = false
                self.compassRing.isHidden = false
                self.highLabel.text = " < You need to be here >"
                self.centerImage.image = UIImage(named: "compassClip")
                self.compassRing.image = UIImage(named: "compassRing")
            } else {
                    // you have a beacon record
                    self.centerImage.image = UIImage(named: "ibeacon-logo")
                    self.compassRing.isHidden = true
                    self.hintLabel.text = nextWP2S.hint
                    self.nameLabel.text = nextWP2S.name
                    self.hintLabel.isHidden = false
                    self.nameLabel.isHidden = false
                    self.latitudeNextLabel.isHidden = true
                    self.longitudeNextLabel.isHidden = true
                self.highLabel.text = " < You need to search > "
                }
        } else {
            // do finale
        }
    }
    // MARK: Saving to the iPad as JSON
    
    func saveImage() {
//        if listOfPoint2Seek.count != wayPoints.count {
//            listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
//        }
        
        var w2GA:[way2G] = []
        for ways in listOfPoint2Seek {
            let w2G = way2G(longitude: (ways.coordinates?.longitude)!, latitude: (ways.coordinates?.latitude)!, name: ways.name!, hint: ways.hint!, imageURL: URL(string: "http://")!)
            w2GA.append(w2G)
        }
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(w2GA) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let file2ShareURL = documentsDirectoryURL.appendingPathComponent("config.n2khunt")
                    do {
                        try jsonString.write(to: file2ShareURL, atomically: false, encoding: .utf8)
                    } catch {
                        print(error)
                    }
                    
                    do {
                        let _ = try Data(contentsOf: file2ShareURL)
                        let activityViewController = UIActivityViewController(activityItems: [file2ShareURL], applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true, completion: nil)
                    } catch {
                        print("unable to read")
                    }
            }
        }
    }
}
    
    @IBAction func ShareButton2(_ sender: UIBarButtonItem) {

        if !confirmSequenced() {
            return
        }
        DispatchQueue.main.async() {
            self.spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 64, height: 64))
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.spinner)
            self.spinner.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        save2Cloud(rex2S: listOfPoint2Seek, rex2D: nil, sharing: true, reordered: false)
        
//        saveImage()
    }
     
     // MARK: Navigation
    
    var editSegue: EditWaypointController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        let annotationView = sender as? MKAnnotationView
        if segue.identifier == Constants.EditUserWaypoint, trigger == point.gps {
            let ewvc = destination as? EditWaypointController
//            wayPoints.removeValue(forKey: ((pinViewSelected?.title)!)!)
            
            let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
                item.name ==  (pinViewSelected?.title)!
            })
            
            ewvc?.nameText = listOfPoint2Seek[index2F!].name
            ewvc?.hintText = listOfPoint2Seek[index2F!].hint
            ewvc?.me = self
            if index2F != nil {
                 ewvc?.challengeText = listOfPoint2Seek[index2F!].challenge
            }
//            if let _ = wayPoints[(pinViewSelected?.title)!] {
//                    ewvc?.challengeText = (wayPoints[(pinViewSelected?.title)!]?.challenge)
//            }
            ewvc?.setWayPoint = self
                if let ppc = ewvc?.popoverPresentationController {
                    
                    ppc.sourceRect = (annotationView?.frame)!
                    ppc.delegate = self
                }
        }
        if segue.identifier == Constants.EditUserWaypoint, trigger == point.ibeacon {
            let ewvc = destination as? EditWaypointController
            editSegue = ewvc
            let uniqueName = "UUID" + "-" + cMinorMajorKey
            let index2F:Int?  = listOfPoint2Seek.index(where: { (item) -> Bool in
                   item.name == uniqueName
            })
//            if order2Search == nil { order2Search = 0 } else { order2Search = index2F }

            if index2F == nil {
                order2Search = 0
                ewvc?.lastProximity = lastProximity
                ewvc?.nameText =  uniqueName
                ewvc?.hintText = "ibeacon"
                ewvc?.setWayPoint = self
                ewvc?.me = self
            } else {
                order2Search = index2F
                ewvc?.lastProximity = lastProximity
                ewvc?.nameText = listOfPoint2Seek[index2F!].name
                ewvc?.hintText = listOfPoint2Seek[index2F!].hint
                ewvc?.setWayPoint = self
                ewvc?.me = self
            }
//            let wp2A = wayPoint(recordID: nil, UUID: nil, major:nil, minor: nil,proximity: nil, coordinates: nil, name: uniqueName, hint: "ibeacon", image: nil, order: listOfPoint2Seek.count, boxes:nil, challenge: nil, URL: nil)
//            listOfPoint2Seek.append(wp2A)
            if let ppc = ewvc?.popoverPresentationController {
                let point2U = mapView.convert( (locationManager?.location?.coordinate)!, toPointTo: mapView)
                ppc.sourceRect = CGRect(x: point2U.x, y: point2U.y, width: 1, height: 1)
                ppc.delegate = self
            }
        }
        if segue.identifier == Constants.TableWaypoint {
            let tbvc = destination as?  HideTableViewController
            tbvc?.zapperDelegate = self
            tbvc?.save2CloudDelegate = self
            tbvc?.table2MapDelegate = self
            tbvc?.me = self
        }
        if segue.identifier == Constants.ScannerViewController {
            let svc = destination as? ScannerViewController
            svc?.firstViewController = self
        }
        if segue.identifier == Constants.ShowImageSegue {
            let svc = destination as? ImageViewController
            let nextWP2S = listOfPoint2Seek[order2Search!]
            if nextWP2S.image != nil {
                svc?.image2S = nextWP2S.image
                svc?.challenge2A = nextWP2S.challenge
                svc?.index2U = order2Search
            }
            svc?.callingViewController = self
        }
        if segue.identifier == Constants.WebViewController {
            let svc = destination as? WebViewController
            svc?.secondViewController = self
            svc?.nameOfNode = (pinViewSelected?.title)!
        }
    }
    
//    private func updateHint(waypoint2U: MKPointAnnotation, hint: String?) {
//        if hint != nil {
//            let wp2Fix = wayPoints.filter { (arg) -> Bool in
//                let (_, value2U) = arg
//                return value2U.name == waypoint2U.title
//            }
//            let wp2F = wp2Fix.values.first
//            let waypoint2A = wayPoint(recordID: wp2F?.recordID, UUID: wp2F?.UUID, major:wp2F?.major, minor: wp2F?.minor,proximity: nil, coordinates: waypoint2U.coordinate, name: wp2F?.name, hint: hint, image: wp2F?.image, order: wayPoints.count, boxes:wp2F?.boxes, challenge: wp2F?.challenge, URL: wp2F?.URL)
//            wayPoints[waypoint2U.title!] = waypoint2A
//        }
//    }
    

    
    private func updateChallenge(waypoint2U: MKPointAnnotation, challenge: String?) {
        let index2F  = listOfPoint2Seek.index(where: { (item) -> Bool in
            item.name == waypoint2U.title
        })
        if index2F != nil {
            listOfPoint2Seek[index2F!].challenge = challenge
        }
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if usingMode == op.playing {
            return
        }
        savedMap = false
        if sender.state == .began {
            trigger = point.gps
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
//            let wayNames = Array(wayPoints.keys)
//            let uniqueName = "GPS".madeUnique(withRespectTo: wayNames)
            let wp2FLat = self.getLocationDegreesFrom(latitude: coordinate.latitude)
            let wp2FLog = self.getLocationDegreesFrom(longitude: coordinate.longitude)
            let hint2D = wp2FLat + wp2FLog
             let uniqueName =  returnUUID(Source2U: hint2D)
//            let uniqueName = UUID().uuidString
//           let waypoint2 = MKPointAnnotation()
            let waypoint2 = MyPointAnnotation()
          waypoint2.coordinate  = coordinate
          waypoint2.title = uniqueName
//            waypoint2.tintColor = .purple

          waypoint2.subtitle = nil
//            updateWayname(waypoint2U: waypoint2, image2U: nil)
            
     

            DispatchQueue.main.async() {
                self.mapView.addAnnotation(waypoint2)
//                self.doBox(latitude2S: wp2FLat, longitude2S: wp2FLog)
                let boxes = self.doBoxV2(latitude2D: coordinate.latitude, longitude2D: coordinate.longitude, name: uniqueName, add2Map: true)
                var box2F:[CLLocation] = []
                for box in boxes {
                    box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
                }
                let newWayPoint = wayPoint(recordID: nil, recordRecord: nil, UUID: nil, major:nil, minor: nil, proximity: nil, coordinates: coordinate, name: uniqueName, hint:nil, image: nil, order: listOfPoint2Seek.count, boxes: box2F, challenge: nil, URL: nil)
                wayPoints[uniqueName] = newWayPoint
                
                listOfPoint2Seek.append(newWayPoint)
            }
        }
    }
    
    //MARK: timer
    
     var timer2D: Timer!
    
    func makeTimer() {
        var timeCount:TimeInterval = 1.0
        let timeInterval:TimeInterval = 1.0
        timer2D = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            self.timerLabel.text = self.timeString(time: timeCount)
            timeCount += 1
        }
    }
    
    // MARK: Popover Delegate
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        print("\(listOfPoint2Seek[0].proximity!.rawValue)")
    }
    
     @IBOutlet weak var hideView: HideView!
    private var pinObserver: NSObjectProtocol!
    private var regionObserver: NSObjectProtocol!
    
    private func judgement() {
        if order2Search! < listOfPoint2Seek.count - 1 {
            order2Search! += 1
        } else {
            codeRunState = gameplay.finished
            self.fadeTitles()
        }
        self.nextLocation2Show()
    }
    
    private func resetTitles() {
        DispatchQueue.main.async {
            self.makeTimer()
            self.latitudeNextLabel.alpha = 1
            self.longitudeNextLabel.alpha = 1
            self.timerLabel.alpha = 1
            self.countLabel.alpha = 1
            self.orderLabel.alpha = 1
            self.nameLabel.alpha = 1
            self.hintLabel.alpha = 1
        }
        order2Search = 0
        wayPoints = [:]
        listOfPoint2Seek = []
//        listOfPoint2Save = []
        listOfPoint2Search = []
        listOfZones = []
        
        zoneTable = [:]
        WP2M = [:]
        WP2P = [:]
        order2SaveIndex = nil
    }
    
    private func fadeTitles() {
        DispatchQueue.main.async {
            if self.timer2D != nil {
                self.timer2D.invalidate()
            }
            UIView.animate(withDuration: 4.0) {
                self.latitudeNextLabel.alpha = 0
                self.longitudeNextLabel.alpha = 0
                self.timerLabel.alpha = 0
                self.countLabel.alpha = 0
                self.orderLabel.alpha = 0
                self.nameLabel.alpha = 0
                self.hintLabel.alpha = 0
            }
            self.highLabel.text = " [ You Finished ] "
            UIView.animate(withDuration: 24.0, animations: {
                self.highLabel.alpha = 0
            }, completion: { (done) in
                self.navigationItem.title = nil
                self.highLabel.text = " Any more Maps ?"
                UIView.animate(withDuration: 4.0) {
                    self.highLabel.alpha = 1
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.distanceFilter = kCLDistanceFilterNone
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager?.activityType = CLActivityType.fitness
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.startUpdatingHeading()
        self.locationManager?.requestLocation()
        self.startScanning()
        

        let center = NotificationCenter.default
        let queue = OperationQueue.main
        var alert2Monitor = "regionEvent"
        regionObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
             let message2N = notification.userInfo!["region"] as? String
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Monitoring", message:  "\(message2N!)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
         alert2Monitor = "showPin"
        pinObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
             let record2O = notification.userInfo!["pin"] as? CKShareMetadata
            if record2O != nil {
//                self.queryShare(record2O!)
//                self.menuButton.isEnabled = false
                self.plusButton.isEnabled = false
                self.playButton.isEnabled = false
                self.pin.isEnabled = false
                self.scanButton.isEnabled = false
                self.fetchParent(record2O!)
            }
        }

//        check internet
        if reachable() {
//            print("Internet connection OK")
            if isICloudContainerAvailable() {
                // do nothing
            } else {
                DispatchQueue.main.async() {
                    let alert = UIAlertController(title: "AppleID Required", message: "Make sure your device is logged with an AppleID.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
//                    self.menuButton.isEnabled = false
                    self.plusButton.isEnabled = false
                    self.playButton.isEnabled = false
                    self.shareButton.isEnabled = false
                }
            }
        } else {
//            print("Internet connection FAILED")
              let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
             self.present(alert, animated: true, completion: nil)
//            self.menuButton.isEnabled = false
            self.plusButton.isEnabled = false
            self.playButton.isEnabled = false
            self.shareButton.isEnabled = false
        }
        
        highLabel.isHidden = true
//        lowLabel.isHidden = true
        hereLabel.layer.borderWidth = 1
        hereLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        nearLabel.layer.borderWidth = 1
        nearLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        farLabel.layer.borderWidth = 1
        farLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        thereLabel.layer.borderWidth = 1
        thereLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }
    
    // MARK: // StarStrella
    
    var spinner: UIActivityIndicatorView!
    
    func fetchParent(_ metadata: CKShareMetadata) {
        
        recordZoneID = metadata.share.recordID.zoneID
        recordID = metadata.share.recordID
        self.navigationItem.title = recordZoneID.zoneName
//        let record2S =  [metadata.rootRecordID].last
        DispatchQueue.main.async() {
//            self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
//            self.spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 64, height: 64))
//            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//            self.view.addSubview(self.spinner)
//            self.spinner.startAnimating()
        }
        share2Source(zoneID: recordZoneID)
    }
    
//    func queryShare(record2S: [CKReference]) {
//        var pinID:[CKRecordID] = []
//        for pins in record2S {
//            pinID.append(pins.recordID)
//        }
//        let operation = CKFetchRecordsOperation(recordIDs: pinID)
//        operation.perRecordCompletionBlock = { record, _, error in
//            if error != nil {
//                print("\(String(describing: error?.localizedDescription))")
//            }
//            if record != nil {
//                DispatchQueue.main.async() {
//                    self.plotPin(pin2P: record!)
//                }
////                let region2M = self.region(withPins: record!)
////                self.locationManager?.startUpdatingLocation()
////                self.locationManager?.startUpdatingHeading()
////                self.locationManager?.startMonitoring(for: region2M)
////                self.locationManager.startMonitoringVisits()
//            }
//        }
//        operation.fetchRecordsCompletionBlock = { _, error in
//            if error != nil {
//                print("\(String(describing: error))")
//            }
//            DispatchQueue.main.async() {
////                self.spinner.stopAnimating()
////                self.spinner.removeFromSuperview()
//            }
//        }
//        CKContainer.default().sharedCloudDatabase.add(operation)
//    }
    
    
    private func plotPin(pin2P: CKRecord, index2F: Int) {
        let UUID = pin2P.object(forKey:  Constants.Attribute.UUID) as? String
        if UUID == nil {
            DispatchQueue.main.async() {
                let longitude = pin2P.object(forKey:  Constants.Attribute.longitude) as? Double
                let latitude = pin2P.object(forKey:  Constants.Attribute.latitude) as? Double
                let name = pin2P.object(forKey:  Constants.Attribute.name) as? String
                //            let order = pin2P.object(forKey:  Constants.Attribute.order) as? Int
                //            let wp2FLat = self.getLocationDegreesFrom(latitude: latitude!)
                //            let wp2FLog = self.getLocationDegreesFrom(longitude: longitude!)
                //            let hint2D = String(order!) + ":" + wp2FLat + wp2FLog
                let hint = pin2P.object(forKey:  Constants.Attribute.hint) as? String
//                let file : CKAsset? = pin2P.object(forKey: Constants.Attribute.imageData) as? CKAsset
                let waypoint = MKPointAnnotation()
                waypoint.coordinate  = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                waypoint.title = name
                waypoint.subtitle = hint
                
                let boxes = self.doBoxV2(latitude2D: latitude!, longitude2D: longitude!, name: name!, add2Map: false)
                var box2F:[CLLocation] = []
                for box in boxes {
                    box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
                }
                if index2F > 0 {
                    listOfPoint2Seek[index2F].boxes = box2F
                }
                self.mapView.addAnnotation(waypoint)
            }
        }
    }
    
    // MARK: motion
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if reachable() {
                if isICloudContainerAvailable() {
                    DispatchQueue.main.async() {
                        self.menuButton.isEnabled = true
                        self.plusButton.isEnabled = true
                        self.playButton.isEnabled = true
                        self.shareButton.isEnabled = true
                    }
                } else {
                    DispatchQueue.main.async() {
                        let alert = UIAlertController(title: "AppleID Required", message: "Make sure your device is logged with an AppleID.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
                        self.present(alert, animated: true, completion: nil)
//                        self.menuButton.isEnabled = false
                        self.plusButton.isEnabled = false
                        self.playButton.isEnabled = false
                        self.shareButton.isEnabled = false
                    }
                }
                DispatchQueue.main.async() {
                    self.menuButton.isEnabled = true
                    self.plusButton.isEnabled = true
                    self.playButton.isEnabled = true
                    self.shareButton.isEnabled = true
                }
            } else {
                //            print("Internet connection FAILED")
                DispatchQueue.main.async() {
                    let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
//                    self.menuButton.isEnabled = false
                    self.plusButton.isEnabled = false
                    self.playButton.isEnabled = false
                    self.shareButton.isEnabled = false
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.stopUpdatingHeading()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         let center = NotificationCenter.default
        if pinObserver != nil {
            center.removeObserver(pinObserver)
        }
        if regionObserver != nil {
            center.removeObserver(regionObserver)
        }
    }
    
    var buttonColour: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let redView = UIView(frame: CGRect(x: 50, y: 150, width: 128, height: 128))
//        redView.backgroundColor = .red
//        view.addSubview(redView)
//
//        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
//        maskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
//        maskView.layer.cornerRadius = 32
//        redView.mask = maskView
        
        buttonColour = playButton.tintColor
        cleanup()
        trigger = point.gps
        centerImage.alpha = 0.5
        
        nameLabel.isHidden = true
        hintLabel.isHidden = true
        latitudeNextLabel.isHidden = true
        longitudeNextLabel.isHidden = true
        nameLabel.backgroundColor = UIColor.clear
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
//        CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: {status, error in
//            let alert = UIAlertController(title: "No Cloud Connection", message: "Make sure your device is connected to the internet and logged into your AppleID.", preferredStyle: .alert)
//                         alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
//                         self.present(alert, animated: true, completion: nil)
//            self.menuButton.isEnabled = false
//            self.plusButton.isEnabled = false
            self.playButton.isEnabled = false
            self.shareButton.isEnabled = false
//        })
        locationManager?.delegate = self
        if globalUUID == nil {
            proximityLabel.isHidden = true
        }
//        locationManager?.requestAlwaysAuthorization()
//        locationManager?.distanceFilter = kCLDistanceFilterNone
//        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager?.activityType = CLActivityType.fitness
////        locationManager?.allowsBackgroundLocationUpdates
//        locationManager?.requestLocation()
        self.listAllZones()
        
        let when = DispatchTime.now() + Double(8)
        DispatchQueue.main.asyncAfter(deadline: when){
            if self.currentLocation != nil {
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentLocation!.coordinate.latitude, self.currentLocation!.coordinate.longitude)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
                self.mapView.setRegion(region, animated: true)
                self.regionHasBeenCentered = true
                self.mapView.userTrackingMode = .followWithHeading
            }
        }
        
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        let secondsFraction = seconds - Double(Int(seconds))
        return String(format:"%02i:%02i.%01i",minutes,Int(seconds),Int(secondsFraction * 10.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // do something
        return traitCollection.horizontalSizeClass == .compact ? UIModalPresentationStyle.overFullScreen : .none
    }
    
    @objc func byebye() {
//        self.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: {
            // code
        })
    }
  
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        
        if style == .fullScreen || style == .overFullScreen {
            let navcon = UINavigationController(rootViewController: controller.presentedViewController)
//            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
//            visualEffectView.frame = navcon.view.bounds
//            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            visualEffectView.backgroundColor = UIColor.clear
//            navcon.view.insertSubview(visualEffectView, at: 0)
            
            let maskView = UIView()
            maskView.backgroundColor = UIColor(white: 1,  alpha: 0.5) //you can modify this to whatever you need
            maskView.frame = navcon.view.bounds
            maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            navcon.view.insertSubview(maskView, at: 0)
             let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(byebye))
            controller.presentedViewController.navigationItem.rightBarButtonItem = rightBarButton
            return navcon
        } else {
            return nil
        }
    }
    
    // MARK: Utilities
    
    private func cleanup() {
        let fileManager = FileManager.default
        do {
            let tmpDirURL = fileManager.temporaryDirectory
            let files2D = try fileManager.contentsOfDirectory(atPath: tmpDirURL.path )
            for file2D in files2D {
                do {
                    let fileURL = tmpDirURL.appendingPathComponent(file2D)
                    try fileManager.removeItem(at: fileURL)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    // MARK: Constants
    
    private struct axis {
        static let longitude = 0
        static let latitude =  1
    }
    
    private struct size2U {
        static let min = 0
        static let max = 1
    }
    
    private struct corners {
        static let northEast = 0
        static let southEast = 1
        static let southWest = 3
        static let northWest = 4
    }
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
        static let TableWaypoint = "Table Waypoint"
        static let ScannerViewController = "Scan VC"
        static let WebViewController = "WebViewController"
       
        
        struct Entity {
            static let wayPoints = "wayPoints"
            static let mapLinks = "mapLinks"
        }
        struct Attribute {
            static let UUID = "UUID"
            static let minor = "minor"
            static let major = "major"
            static let proximity = "proximity"
            static let longitude = "longitude"
            static let  latitude = "latitude"
            static let  name = "name"
            static let hint = "hint"
            static let order = "order"
            static let  imageData = "image"
            static let mapName = "mapName"
            static let linkReference = "linkReference"
            static let wayPointsArray = "wayPointsArray"
            static let boxes = "boxes"
            static let challenge = "challenge"
            static let URL = "URL"
        }
        struct Variable {
            static  let radius = 40
            // the digital difference between degrees-miniutes-seconds 46-20-41 & 46-20-42.
            static let magic = 0.00015
        }
    }
}


