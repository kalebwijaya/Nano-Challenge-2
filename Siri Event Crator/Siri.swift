
//
//  Siri.swift
//  Nano Challenge 2
//
//  Created by Kaleb Wijaya on 19/09/19.
//  Copyright © 2019 Kaleb Wijaya. All rights reserved.
//

import Foundation
import CloudKit

class SiriEvent{
    
    static let siriEvent = "Event Broadcast"
    static let suiteName = "com.kalebwijaya.Nano-Challenge-2"
    
    static func createEvent(title:String, desc:String, date:String, location:String, participant:String){
        let database = CKContainer.default().publicCloudDatabase
        let newEvent = CKRecord(recordType: "Event")
        newEvent.setValue(title, forKey: "EventTitle")
        newEvent.setValue(desc, forKey: "EventDesc")
        newEvent.setValue(date, forKey: "EventDate")
        newEvent.setValue(location, forKey: "EventLocation")
        newEvent.setValue(participant, forKey: "EventParticipant")
        database.save(newEvent) { (record, _) in
            guard record != nil else { return }
            print("Event Saved")
        }
    }
}
