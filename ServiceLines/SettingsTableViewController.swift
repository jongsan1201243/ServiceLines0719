//
//  SettingsTableViewController.swift
//  ServiceLines
//
//  Created by Mac on 17/06/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import DatePickerDialog
import ActionSheetPicker_3_0
import SCLAlertView
import Alamofire

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
    }

    var userName = ""
    var password = ""
    
    override func viewWillAppear(_ animated: Bool) {
        let defaultValues = UserDefaults.standard
        
        if let settings = defaultValues.array(forKey: "settings"){
            self.menuItems = settings as! [Dictionary<String, Any>]
        }
//        let loggedinUserName = defaultValues.string(forKey:"adminUserName")
//        if loggedinUserName == nil{
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)

            let userNameInput = alert.addTextField("Admin User Name:")
            let passwordInput = alert.addTextField("Password")
            passwordInput.isSecureTextEntry = true
            alert.addButton("Accedi") {
                print("User Name: \(userNameInput.text)")
                print("Password: \(passwordInput.text)")
                
                self.userName = userNameInput.text! as String
                self.password = passwordInput.text! as String
                let parameters: Parameters = ["username": self.userName, "password": self.password]
                Alamofire.request("http://web.servicelines.it:82/test/gwapp/WS_Super_Admin_Login.php", parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    print("Result: \(response.result)")                         // response serialization result
                  
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        if utf8Text.lowercased().range(of:"status: 1") != nil {
                            defaultValues.set(self.userName, forKey: "adminUserName")
                            defaultValues.set(self.password, forKey: "adminPassword")
                        }
                        else{
                            SCLAlertView().showInfo("Error", subTitle: "Username o Password errati!")
                            self.tabBarController?.selectedIndex = 1
                        }
                    }
                }
            }
            alert.addButton("Annulla"){
                self.tabBarController?.selectedIndex = 1
            }

            alert.showEdit("Amministrazione Sistema", subTitle: "")
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    var menuItems = [
        ["name":"Limite distanza", "value": "5", "string": "5 meters"],
        ["name":"Limite ore", "value": 3600, "string": "01h:00m"],
        ["name":"Ripetizione alert", "value": 15*60, "string": "00h:15m"],
        ["name":"Orario Sync", "value": 20 * 3600 + 30 * 60, "string":"20h: 30m"],
        ["name":"Limite spazio", "value":100, "string": "100 Mb"]
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)

        // Configure the cell...
        
        let menuItem = menuItems[indexPath.row]
        
//        let key = Array(menuItems.keys)[indexPath.row]
        cell.textLabel?.text = menuItem["name"] as! String?
        let priceString = menuItem["string"] as! String?
        cell.detailTextLabel?.text = priceString
        return cell
    }
    
    func syncSettingsData() {
        let defaultValues = UserDefaults.standard
        defaultValues.set(menuItems, forKey:"settings")
        let parameters: Parameters = ["username": self.userName, "limit_space": menuItems[3]["string"]!, "limit_time": menuItems[1]["string"]!, "limit_distance": menuItems[0]["string"]!]
        Alamofire.request("http://web.servicelines.it:82/test/gwapp/WS_Device_Settings.php", parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var menuItem = menuItems[indexPath.row]
        switch menuItem["name"]  as! String{
        case "Limite distanza":
            let values = (5...100).map { String($0) }
            let initSection = values.index(of: menuItem["value"] as! String)
            let acp = ActionSheetMultipleStringPicker(title: "Distance", rows: [
                values,
                ["Meter", "Feet"]
                ], initialSelection: [initSection ?? 2, 2], doneBlock: {
                    picker, values, indexes in
                    if let selectedValues = indexes as? Array<String> {
                        menuItem["value"] = selectedValues[0]
                        menuItem["string"] = selectedValues[0] + " " + selectedValues[1]
                        print(menuItem)
                        self.menuItems[indexPath.row] = menuItem
                        self.tableView.reloadData()
                        self.syncSettingsData()
                    }
                    return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.tableView.cellForRow(at: indexPath))
            acp?.show()

            break
        case "Limite ore", "Orario Sync", "Ripetizione alert":
            let hourValues = (0...24).map { String($0) }
            let timeValue = TimeInterval(menuItem["value"] as! Int)
            let initHourSection = hourValues.index(of: String(timeValue.timeIntervalAsHours()))
            let minValues = (0...60).map{String($0)}
            let initMinSection = minValues.index(of: String(timeValue.timeIntervalAsMinutes()))
            let acp = ActionSheetMultipleStringPicker(title: "Time Amount", rows: [
                hourValues, ["hrs"], minValues, ["min"]
                ], initialSelection: [initHourSection ?? 0, 0, initMinSection ?? 4, 0], doneBlock: {
                    picker, values, indexes in
                    if let selectedValues = indexes as? Array<String> {
                        let timeval = Int(selectedValues[0])! * 3600 + Int(selectedValues[2])! * 60
                        menuItem["value"] = timeval
                        menuItem["string"] = selectedValues[0] + " " + selectedValues[1] + " " + selectedValues[2] + " " + selectedValues[3]
                        print(menuItem)
                        self.menuItems[indexPath.row] = menuItem
                        self.tableView.reloadData()
                        self.syncSettingsData()
                        if menuItem["name"]  as! String == "Orario Sync"{
                            let root = self.parent as! ViewController
                            root.registerSyncNotification(syncTime: TimeInterval(timeval))
                        }

                    }
                    return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.tableView.cellForRow(at: indexPath))
            acp?.show()
            break
        case "Limite spazio":
            let values = [50, 100, 200, 300, 400, 500, 600, 700, 800]
            let initialSection = values.index(of: menuItem["value"] as! Int)
            let acp = ActionSheetMultipleStringPicker(title: "Limit Size", rows: [
                values, ["MB"]
                ], initialSelection: [initialSection ?? 1, 0], doneBlock: {
                    picker, values, indexes in
                    if let selectedValues = indexes as? Array<Any> {
                        menuItem["value"] = selectedValues[0]
                        menuItem["string"] = String(selectedValues[0] as! Int)  + " " + (selectedValues[1] as! String)
                        self.menuItems[indexPath.row] = menuItem
                        print(menuItem)
                        self.tableView.reloadData()
                        self.syncSettingsData()
                    }
                    else{
                        print("value: \(values)")
                        print("indexes: \(indexes)")
                    }
                    return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.tableView.cellForRow(at: indexPath))
            acp?.show()
            break
        default:
            break
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
