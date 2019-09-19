//
//  ViewController.swift
//  Location
//
//  Created by Kaleb Wijaya on 18/09/19.
//  Copyright © 2019 Kaleb Wijaya. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CloudKit

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var eventTableList: UITableView!
    
    let locationManager:CLLocationManager = CLLocationManager()
    let database = CKContainer.default().publicCloudDatabase
    var auth:Bool = false
    var locAuth:Bool = false
    var currentLocation: CLLocation!
    var geoFenceRegion:CLCircularRegion!

    var events = [CKRecord]()
    
    @IBAction func addBroadcast(_ sender: UIBarButtonItem) {
        generateEvent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestPermissionNotifications()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 50
        
        geoFenceRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(-6.302122, 106.652183), radius: 50, identifier: "Apple Academy")
        
        locationManager.startMonitoring(for: geoFenceRegion)
        
        let nib = UINib(nibName: "EventTableViewCell", bundle: nil)
        eventTableList.register(nib, forCellReuseIdentifier: "EventTableViewCell")
        eventTableList.rowHeight = 110
        pullToRef()
        queryDatabase()
    }
    
    func generateEvent(){
        if(auth){
            performSegue(withIdentifier: "createBroadcast", sender: nil)
        }else{
            let alert = UIAlertController(title: "Warning", message: "You Must Inside Academy To Create a Broadcast", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        createUserActivity()
    }
    
    func createUserActivity(){
        let activity = NSUserActivity(activityType: UserActivityType.createBroadcast)
        activity.title = "Generate Event Broadcast"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier( UserActivityType.createBroadcast)
        
        self.userActivity = activity
        activity.becomeCurrent()
    }
    
    func pullToRef(){
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(queryDatabase), for: .valueChanged)
        self.eventTableList.refreshControl = refreshControl
    }
    
    func detectUser(){
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            currentLocation = locationManager.location
        }
        let distanceInMeters = currentLocation.distance(from: CLLocation(latitude: (geoFenceRegion?.center.latitude)!, longitude: (geoFenceRegion?.center.longitude)!))
        if(distanceInMeters <= geoFenceRegion.radius/2){
            auth = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations{
            print("\(String(describing: index)): \(currentLocation)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered: \(region.identifier)")
        postLocalNotifications(eventTitle: "Entered: \(region.identifier)", body: "Don't Forget To Clock In")
        auth = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited: \(region.identifier)")
        postLocalNotifications(eventTitle: "Exited: \(region.identifier)", body: "Don't Forget To Clock Out")
        auth = false
    }
    
    @objc func queryDatabase(){
        let query = CKQuery(recordType: "Event", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else { return }
            self.events = records
            DispatchQueue.main.async {
                self.eventTableList.refreshControl?.endRefreshing()
                self.eventTableList.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.queryDatabase()
        self.eventTableList.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableList.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath ) as! EventTableViewCell
        cell.title.text = events[indexPath.row].value(forKey: "EventTitle") as? String
        cell.date.text = events[indexPath.row].value(forKey: "EventDate") as? String
        cell.desc.text = events[indexPath.row].value(forKey: "EventDesc") as? String
        cell.participant.text = (events[indexPath.row].value(forKey: "EventParticipant") as? String)! + " People(s)"
        cell.location.text = events[indexPath.row].value(forKey: "EventLocation") as? String
        return cell
    }
    
}

extension ViewController{
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                        self.detectUser()
                    }else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                        self.detectUser()
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    func postLocalNotifications(eventTitle:String, body:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
}
