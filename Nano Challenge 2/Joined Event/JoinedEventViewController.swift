//
//  JoinedEventViewController.swift
//  Nano Challenge 2
//
//  Created by Kaleb Wijaya on 20/09/19.
//  Copyright © 2019 Kaleb Wijaya. All rights reserved.
//

import UIKit

class JoinedEventViewController: UIViewController {
    
    @IBOutlet weak var joinedEventTableList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "EventTableViewCell", bundle: nil)
        joinedEventTableList.register(nib, forCellReuseIdentifier: "EventTableViewCell")
        joinedEventTableList.rowHeight = 110
    }

}

extension JoinedEventViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = joinedEventTableList.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath ) as! EventTableViewCell
        cell.title.text = joinedEvents[indexPath.row].title
        cell.date.text = joinedEvents[indexPath.row].date
        cell.desc.text = joinedEvents[indexPath.row].desc
        cell.participant.text = joinedEvents[indexPath.row].participant
        cell.location.text = joinedEvents[indexPath.row].location
        cell.joinBtn.isHidden = true
        return cell
    }
    
    
}
