//
//  EventTableViewCell.swift
//  Nano Challenge 2
//
//  Created by Kaleb Wijaya on 19/09/19.
//  Copyright © 2019 Kaleb Wijaya. All rights reserved.
//

import UIKit

struct joinedEvent {
    var title:String
    var desc:String
    var date:String
    var participant:String
    var location:String
}

var joinedEvents = [joinedEvent]()

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var participant: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    
    @IBAction func joinBtnPressed(_ sender: UIButton) {
        joinBtn.setTitle("Joined", for: .disabled)
        joinBtn.isEnabled = false
        let joinEvent = joinedEvent(title: title.text!, desc: desc.text!, date: date.text!, participant: participant.text!, location: location.text!)
        joinedEvents.append(joinEvent)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
