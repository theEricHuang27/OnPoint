//
//  PowerschoolViewController.swift
//  Mom
//
//  Created by Aidan Barr Bono (student LM) on 4/28/19.
//  Copyright © 2019 Duck Inc. All rights reserved.
//

import UIKit
import Kanna
import WebKit

var GPAAVG = 0.0
var grades: [String] = []


class PowerschoolViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, ThemedViewController {
    
    @IBOutlet var webView: WKWebView!
    var links: [String] = []
    var GPA:[String]=[]
    var timer : Timer?
    var click = 0
    var finished = false
    var timer2 : Timer?
    var timer3 : Timer?
    // Themed View Controller
    var backView: UIView { return self.view }
    var navBar: UINavigationBar { return self.navigationController!.navigationBar }
    var labels: [UILabel]? { return nil }
    var buttons: [UIButton]? { return nil }
    var textFields: [UITextField]? { return nil }
    
    // Opens powerschool
    override func viewDidLoad() {
        super.viewDidLoad()
        let myRequest = URLRequest(url: URL(string: "https://powerschool.lmsd.org/public/")!)
        webView.load(myRequest)
    }
    
    // Sets the theme
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theme(isDarkTheme: SettingsViewController.isDarkTheme)
    }
    
    // Scrapes missing assignments from a class
    @objc func fireTimer() {
        self.webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html1: Any?, error: Error?) in
            do {
                var grade = ""
                var ghold:String  = ""
                var count = 2
                var count2 = 0
                for char in [Character]((try Kanna.HTML(html: html1 as! String, encoding: String.Encoding.utf8, option: kDefaultHtmlParseOption).content?.characters)!){
                    grade.append(char)
                }
                // removes useless parts of the string
                grade = String(grade[grade.index(grade.firstIndex(of: "@")!, offsetBy: 31968)...])
                grade = grade.removeExtraSpaces()
                grade = grade.replacingOccurrences(of: " collected late missing exempt from final grade absent incomplete excluded from final grade ", with: " ")
                grade = grade.replacingOccurrences(of: "DISCLAIMER: This system is provided as a convenience. Grades and other information provided by this system are not official records and may or may not be accurate. Neither this institution nor PowerSchool Group LLC or its affiliates accepts any responsibility for information provided by this system and/or for any damages resulting from information provided by this system. For official grades and student records contact your school. Copyright © 2005-2018 PowerSchool Group LLC and/or its affiliate(s). All rights reserved.All trademarks are either owned or licensed by PowerSchool Group LLC and/or its affiliates.", with: " ")
                grade = grade.replacingOccurrences(of: "Legend 1 - This final grade may include assignments that are not yet published, or may be the result of special weighting used by the teacher. Click to view additional information on special weighting. Icons - Has Description | - Has Comment | - Collected | - Late | - Missing | - Exempt from Final Grade | - Absent | - Incomplete | - Excluded notifier.displayGuardian();", with: " ")
                grade = grade.replacingOccurrences(of: "td.stdCol { padding: 2px; width: 40px; min-width: 40px; } td.codeCol { padding: 2px; width: 20px; min-width: 20px; } td.stdNA { opacity: .5; border: none !important; } .noStyle td { background-color: #fff !important; } table.zebra tbody tr.sub>td { border-top: none; border-bottom: none; }", with: " ")
                grade = "\(grade)"
                for char in 0...grade.count-10{
                    if "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char)])" == "0" && "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char+1)])" == "/" && "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char-1)])" == " " {
                        while !("\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char-count)])" == "/" && "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char-count+3)])" == "/"){
                            ghold = "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char-count-2)...grade.index(grade.firstIndex(of: " ")!, offsetBy: char-count-2)])"
                            count = count+1
                        }
                        while "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char+count2)])" != " " {
                            count2 = count2+1
                        }
                        ghold = "\(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char-count-2)...grade.index(grade.firstIndex(of: " ")!, offsetBy: char-2)]) \(grade[grade.index(grade.firstIndex(of: " ")!, offsetBy: char)...grade.index(grade.firstIndex(of: " ")!, offsetBy: char+count2)])"
                        grades.append(ghold)
                        count2=0
                        count=93
                    }
                    ghold=""
                }
            }
            catch _ {
            }
        })
        self.finished=true
    }
    
    // Webview that moves around powerschool and saves grades in order to find gpa and missing assignments
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(webView.url! == URL(string: "https://powerschool.lmsd.org/guardian/home.html")){
            let request = URLRequest(url: URL(string: "https://powerschool.lmsd.org/guardian/home.html")!)
            webView.load(request)
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
                do {
                 
                    let htmlDoc = try Kanna.HTML(html: html as! String, encoding: String.Encoding.utf8, option: kDefaultHtmlParseOption)
                    var html = htmlDoc.innerHTML
                    var holder = ""
                    var GPAHolder = ""
                    var count = 0
                    var count2 = 0
                    var miss = 0
                    var htmlList = [Character](html!.characters)
                    for char in 0..<html!.count{
                        if htmlList[char]=="\"" && htmlList[char+1]=="s" && htmlList[char+2]=="c" && htmlList[char+3]=="o" && htmlList[char+4]=="r" && htmlList[char+5]=="e" && htmlList[char+6]=="s" && htmlList[char+7]=="." && htmlList[char+8]=="h" && htmlList[char+9]=="t" && htmlList[char+10]=="m" && htmlList[char+11]=="l" && htmlList[char+12]=="?" && htmlList[char+13]=="f" && htmlList[char+14]=="r" && htmlList[char+15]=="n" && htmlList[char+16]=="="{
                            for i in 1...16{
                                holder.append(htmlList[char+i])
                            }
                            count = 17
                            while htmlList[char+count] != "\""{
                                holder.append(htmlList[char+count])
                                count=count+1
                            }
                            self.links.append(holder)
                            holder=""
                            count=0
                        }
                    }
                    let c = self.links.count
                    for i in 1...c{
                        if "\(self.links[c-i][self.links[c-i].index(self.links[c-i].firstIndex(of: "s")!,offsetBy: self.links[c-i].count-2)])" != "Y"{
                            self.links.remove(at: c-i)
                        }
                    }
                    
                    for char in 0..<html!.count{
                        if htmlList[char]=="Y" && htmlList[char+1]=="1"{
                            count2 = 17
                            while htmlList[char+count2] != "<"{
                                GPAHolder.append(htmlList[char+count2])
                                count2=count2+1
                            }
                            self.GPA.append(GPAHolder)
                            GPAHolder=""
                        }
                    }
                    for grade in self.GPA{
                        if grade == "A+"{
                            GPAAVG=GPAAVG+4
                        }
                        else if grade == "A"{
                            GPAAVG=GPAAVG+4
                        }
                        else if grade == "A-"{
                            GPAAVG=GPAAVG+3.66
                        }
                        else if grade == "B+"{
                            GPAAVG=GPAAVG+3.33
                        }
                        else if grade == "B"{
                            GPAAVG=GPAAVG+3
                        }
                        else if grade == "B-"{
                            GPAAVG=GPAAVG+2.66
                        }
                        else if grade == "C+"{
                            GPAAVG=GPAAVG+2.33
                        }
                        else if grade == "C"{
                            GPAAVG=GPAAVG+2.0
                        }
                        else if grade == "C-"{
                            GPAAVG=GPAAVG+1.66
                        }
                        else if grade == "D+"{
                            GPAAVG=GPAAVG+1.33
                        }
                        else if grade == "D"{
                            GPAAVG=GPAAVG+1.0
                        }
                        else if grade == "D-"{
                            GPAAVG=GPAAVG+0.66
                        }
                        else {
                            miss=miss+1
                        }
                    }
                    GPAAVG=GPAAVG/Double(self.GPA.count-miss)

                    defaults.set(GPAAVG, forKey: "GPA")
                    for z in 0...self.links.count-2{
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4*(z)), execute: {
                            self.webView.load( URLRequest(url: URL(string: "https://powerschool.lmsd.org/guardian/"+self.links[z])!))
                            self.webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html1: Any?, error: Error?) in
                                do {
                                    self.timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
                                        defaults.set(grades, forKey: "grades")
                                    if z == self.links.count - 2
                                    {
                                        DispatchQueue.main.asyncAfter( deadline: .now() + .seconds(4), execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                    
                                }
                                catch _ {
                                }
                            })
                        })
                        //                        Thread.sleep(until: Date(timeIntervalSinceNow: 5))
                    }
                }
                catch _ {
                }
            })
        }
    }
    
    // Loads the view
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        webView.navigationDelegate = self
    }
    
    // Sets the theme
    func theme(isDarkTheme: Bool) {
        defaultTheme(isDarkTheme: isDarkTheme)
    }
}

// Sets any instances of two or more spaces together to just a single space in a string
extension String {
    func removeExtraSpaces() -> String {
        return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    }
}


