//
//  SettingsViewController.swift
//  Mom
//
//  Created by Aidan Barr Bono (student LM) on 3/28/19.
//  Copyright © 2019 Duck Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var alertTimeBeforeTextField: UITextField!
    @IBOutlet weak var snoozeTimeTextField: UITextField!
    var notificationTimeBeforeDatePicker : UIDatePicker?
    var snoozeTimeDatePicker : UIDatePicker?
    
    @IBOutlet weak var alertBeforeSwitch: UISwitch!
    @IBAction func alertBeforeValueChanged(_ sender: UISwitch) {
        if alertBeforeSwitch.isOn {
            alertTimeBeforeTextField.isEnabled = true
        } else {
            alertTimeBeforeTextField.isEnabled = false
        }
    }
    
    
    @IBAction func lightThemeTouchedUp(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "DarkTheme") {
            // change current view as a preview of the theme
            UserDefaults.standard.set(false, forKey: "DarkTheme")
            self.view.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func darkThemeTouchedUp(_ sender: UIButton) {
        if !UserDefaults.standard.bool(forKey: "DarkTheme") {
            // change current view as a preview of the theme
            UserDefaults.standard.set(true, forKey: "DarkTheme")
            self.view.backgroundColor = UIColor.black
        }
    }
    
    @IBAction func applyButtonTouchedUp(_ sender: UIButton) {
        
        if alertBeforeSwitch.isOn {
            Notifications.reminderDateComponents = nil
        } else {
            let dateComponents = Calendar.current.dateComponents([.minute, .hour], from: (notificationTimeBeforeDatePicker?.date)!)
            Notifications.reminderDateComponents = dateComponents
        }
        let snoozeComponents = Calendar.current.dateComponents([.minute, .hour], from: (snoozeTimeDatePicker?.date)!)
        Notifications.snoozeTime = Double(snoozeComponents.minute!)

        let alertController = UIAlertController(title: "Edit current notifications", message: "Would you like to change notification timers for already created events?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Change", style: .default) { (action) in
            Notifications.redoNotifications()
        }
        let denyAction = UIAlertAction(title: "Keep", style: .default, handler: nil)
        
        alertController.addAction(denyAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpSnoozeTimeDatePicker()
        setUpNotificationDatePicker()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func setUpNotificationDatePicker() {
        notificationTimeBeforeDatePicker = UIDatePicker()
        notificationTimeBeforeDatePicker?.datePickerMode = .countDownTimer
        notificationTimeBeforeDatePicker?.minuteInterval = 5
        if let components = Notifications.reminderDateComponents {
            if let startDate = Calendar.current.date(from: components) {
                notificationTimeBeforeDatePicker?.setDate(startDate, animated: false)
            }
        }
        
        notificationTimeBeforeDatePicker?.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        alertTimeBeforeTextField.inputView = notificationTimeBeforeDatePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        if datePicker == self.notificationTimeBeforeDatePicker {
            let dateComponents = Calendar.current.dateComponents([.minute, .hour], from: datePicker.date)
            alertTimeBeforeTextField.text = "\(dateComponents.hour ?? 0) hours and \(dateComponents.minute ?? 0) minutes."
        } else if datePicker == self.snoozeTimeDatePicker {
            let dateComponents = Calendar.current.dateComponents([.minute, .hour], from: datePicker.date)
            snoozeTimeTextField.text = "\(dateComponents.hour ?? 0) hours and \(dateComponents.minute ?? 0) minutes."
        }
    }
    
    func setUpSnoozeTimeDatePicker() {
        snoozeTimeDatePicker = UIDatePicker()
        snoozeTimeDatePicker?.datePickerMode = .countDownTimer
        if let startDate = Calendar.current.date(from: DateComponents(minute: Int(Notifications.snoozeTime))) {
            snoozeTimeDatePicker?.setDate(startDate, animated: false)
        }
        
        snoozeTimeDatePicker?.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        snoozeTimeTextField.inputView = snoozeTimeDatePicker
    }
}
