//
//  CreateBroadcastController.swift
//  Nano Challenge 2
//
//  Created by Kaleb Wijaya on 19/09/19.
//  Copyright © 2019 Kaleb Wijaya. All rights reserved.
//

import UIKit
import CloudKit
import LocalAuthentication

class CreateBroadcastController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var eventTittle: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var totalParticipant: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    
    var datePicker : UIDatePicker!
    let database = CKContainer.default().publicCloudDatabase
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        eventDate.delegate = self
        totalParticipant.delegate = self
        eventLocation.delegate = self
        eventTittle.delegate = self
        eventDescription.layer.borderWidth = 1
        eventDescription.layer.borderColor = #colorLiteral(red: 0.8871908188, green: 0.8819170594, blue: 0.8912447095, alpha: 1)
        eventDescription.layer.cornerRadius = 5
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        // Do any additional setup after loading the view.
        
    }
    
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .medium
        eventDate.text = dateFormatter1.string(from: datePicker.date)
        eventDate.resignFirstResponder()
    }
    @objc func cancelClick() {
        eventDate.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickUpDate(eventDate)
        if(totalParticipant.isEditing){
            moveTextField(textField, moveDistance: -60, up: true)
        }else if (eventLocation.isEditing){
            moveTextField(textField, moveDistance: -20, up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 3){
            moveTextField(textField, moveDistance: -60, up: false)
        }else if(textField.tag == 2){
            moveTextField(textField, moveDistance: -20, up: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func saveToCloud(title:String, desc:String, date:String, location:String, participant:String){
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
    
    @IBAction func createBroadcast(_ sender: UIButton) {
        var message:String!
        let alert = UIAlertController(title: "Warning", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{
            (alert: UIAlertAction!) in _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        if(eventTittle.text!.isEmpty){
            message = "Event Tittle Cannot Be Empty"
            alert.message = message
            self.present(alert, animated: true, completion: nil)
        }else if(eventDescription.text!.isEmpty){
            message = "Event Description Cannot Be Empty"
            alert.message = message
            self.present(alert, animated: true, completion: nil)
        }else if(eventDate.text!.isEmpty){
            message = "Event Date Cannot Be Empty"
            alert.message = message
            self.present(alert, animated: true, completion: nil)
        }else if(eventLocation.text!.isEmpty){
            message = "Event Location Cannot Be Empty"
            alert.message = message
            self.present(alert, animated: true, completion: nil)
        }else if(totalParticipant.text!.isEmpty){
            message = "Event Participant Cannot Be Empty"
            alert.message = message
            self.present(alert, animated: true, completion: nil)
        }else{
            context = LAContext()
            context.localizedCancelTitle = "Enter Username/Password"
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ) { success, error in
                    if success {
                        DispatchQueue.main.async { [unowned self] in
                            self.saveToCloud(title: self.eventTittle.text!, desc: self.eventDescription.text!, date: self.eventDate.text!, location: self.eventLocation.text!, participant: self.totalParticipant.text!)
                            alert.title = "Success"
                            alert.message = "Event Broadcasted!"
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                    }
                }
            }
            
        }
    }
    
    
}
