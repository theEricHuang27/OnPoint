//
//  NextViewController.swift
//  Mom
//
//  Created by Connor Stange (student LM) on 1/29/19.
//  Copyright © 2019 Duck Inc. All rights reserved.

import UIKit
var time = ""
var subj = ""
var desc = ""

class NextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ThemedViewController {
    
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet var Table: UITableView!
    @IBOutlet weak var newEventButton: UIButton!
    var backView: UIView { return self.view }
    var navBar: UINavigationBar { return self.navigationController!.navigationBar }
    var labels: [UILabel]? {
        return [DateLabel]
    }
    var buttons: [UIButton]? {
        return [newEventButton]
    }
    var textFields: [UITextField]? { return nil }
    var tableCellColor: UIColor = UIColor.clear
    var tableCellTextColor: UIColor = UIColor.black
    var events: [Event] = []
    var cellsArray: [UITableViewCell] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DateLabel.text = dateString
        if let loadedData = defaults.data(forKey: "\(dateString)*1") {
            if let loadedEvents = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Event] {
                events = loadedEvents
            }
        }
        if let loadedData = defaults.data(forKey: "\(dateString)*2") {
            if let loadedEvents = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Event] {
                for x in loadedEvents{
                    events.append(x)
                }
            }
        }
        if events.count > 0{
            events = order(e: events)
        }
        self.Reload()
        theme(isDarkTheme: SettingsViewController.isDarkTheme)
        Table.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 1
        cell.backgroundColor = UIColor.myPurple
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Table", for: indexPath) as! EventTableViewCell
        cell.Date.text = getTime(s: events[indexPath.section].d.description)
        cell.Date.textColor = tableCellTextColor
        cell.Subject.text = events[indexPath.section].subject
        cell.Subject.textColor = tableCellTextColor
        cell.layer.cornerRadius = 5
        cell.separatorInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        cell.layoutSubviews()
        cellsArray.append(cell)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        time = getTime(s: events[indexPath.row].d.description)
        subj = events[indexPath.row].subject
        desc = events[indexPath.row].information
        performSegue(withIdentifier: "Description", sender: self)
    }
    
    
    func Reload(){
        events = []
        if let loadedData = defaults.data(forKey: "\(dateString)*1") {
            if let loadedEvents = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Event] {
                events = loadedEvents
            }
        }
        if let loadedData = defaults.data(forKey: "\(dateString)*2") {
            if let loadedEvents = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Event] {
                for x in loadedEvents{
                    events.append(x)
                }
            }
        }
        if events.count > 0{
            events = order(e: events)
        }
        Table.reloadData()
    }
    
    
    func getTime(s: String) -> String{
        let r: String
        var time = s[s.firstIndex(of: ":")!...s.lastIndex(of: ":")!]
        time.remove(at: time.lastIndex(of: ":")!)
        var hour = s[s.firstIndex(of: " ")!...s.firstIndex(of: ":")!]
        hour.remove(at: hour.firstIndex(of: " ")!)
        hour.remove(at: hour.firstIndex(of: ":")!)
        var m = Int(hour)!
        if m >= 16{
            m = m-16
            if m == 0{
                r = "12:00 PM"
            }
            else if m >= 10{
                r = "\(m)\(time) PM"
            }
            else{
                r = " \(m)\(time) PM"
            }
        }
        else{
            m = m-4
            if m == 0{
                r = "12:00 AM"
            }
            else if m >= 10{
                r = "\(m)\(time) AM"
            }
            else{
                r = " \(m)\(time) AM"
            }
        }
        return r
    }
    
    
    func order(e: [Event]) -> [Event]{
        var z = e
        var new: [Event] = []
        var next: Event = Event()
        var index: Int = 0
        var lowest = 2500
        var a: String
        var b: Substring
        for _ in 0...z.count-1{
            for y in z{
                a = "\(y.d.description)"
                b = a[a.firstIndex(of: " ")!...a.lastIndex(of: ":")!]
                b.remove(at: b.firstIndex(of: " ")!)
                b.remove(at: b.firstIndex(of: ":")!)
                b.remove(at: b.firstIndex(of: ":")!)
                if Int("\(b)")! < lowest{
                    lowest = Int("\(b)")!
                    next = y
                    index = z.firstIndex(of: y)!
                }
            }
            lowest = 2500
            new.append(next)
            z.remove(at: index)
        }
        return new
    }
    
    
    func theme(isDarkTheme: Bool) {
        defaultTheme(isDarkTheme: isDarkTheme)
        if isDarkTheme {
            Table.backgroundColor = UIColor.myDeepGrey
            tableCellColor = UIColor.myDeepGrey
            tableCellTextColor = UIColor.white
        } else {
            Table.backgroundColor = UIColor.white
            tableCellColor = UIColor.white
            tableCellTextColor = UIColor.black
        }
    }
}