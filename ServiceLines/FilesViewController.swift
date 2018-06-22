//
//  FilesViewController.swift
//  ServiceLines
//
//  Created by Mac on 16/06/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import SCLAlertView
import Alamofire
import RebekkaTouch
import SystemConfiguration

class FilesViewController: UITableViewController, AVAudioPlayerDelegate {

   
    override func viewDidLoad() {
        super.viewDidLoad()

        var configuration = SessionConfiguration()
        configuration.host = ftpServer
        configuration.username = ftpUserName
        configuration.password = ftpPassword
        
//        var operationQueue = OperationQueue()
        self.session = Session(configuration: configuration)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var operationQueue: OperationQueue!
    var session: Session!
    
    var filesList : [[String]] = []
    let textCellIdentifier = "Cell"
    var audioPlayer: AVAudioPlayer!
    //Create a button
//    let infoButton = UIBarButtonItem(title: "Upload All", style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadAllClicked(sender:)))
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    let ftpUserName = "gwapp"
    let ftpPassword = "4ds034x8$!xc$D1"
    let ftpServer = "ftp://webtest.servicelines.it"
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    func activityIndicator(_ title: String) {
        
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: self.tableView.frame.midX - strLabel.frame.width/2, y: self.tableView.frame.midY - strLabel.frame.height/2 , width: 180, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.addSubview(activityIndicator)
        effectView.addSubview(strLabel)
        view.addSubview(effectView)
    }

    let toolbar = UIToolbar()
    
    override func viewDidDisappear(_ animated: Bool) {
        toolbar.isHidden = true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Initialize the toolbar
        
        toolbar.barStyle = UIBarStyle.default
        
        //Set the toolbar to fit the width of the app.
        toolbar.sizeToFit()
        
        //Caclulate the height of the toolbar
        let toolbarHeight = toolbar.frame.size.height
        
        //Get the bounds of the parent view
        let rootViewBounds = self.parent?.view.bounds
        
        //Get the height of the parent view.
//        let rootViewHeight = rootViewBounds?.height
        
        //Get the width of the parent view,
        let rootViewWidth = rootViewBounds?.width
        
        //Create a rectangle for the toolbar
        let rectArea = CGRect(x: 0, y: 20, width: rootViewWidth!, height: toolbarHeight)
        
        //Reposition and resize the receiver
        toolbar.frame = rectArea
        
        let infoButton = UIBarButtonItem(title: "INVIA TUTTI", style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadAllClicked(sender:)))

        toolbar.items = [infoButton]
        
        
        //Add the toolbar as a subview to the navigation controller.
        self.tabBarController?.view.addSubview(toolbar)
//        self.tabBarController?.view.subViews.filter
        let titleLabel = self.tabBarController?.view.subviews.filter{$0 is UILabel}
        self.tabBarController?.view.bringSubview(toFront: (titleLabel?[0])!)
        self.tableView.contentInset = UIEdgeInsets(top: toolbarHeight + 20, left: 0, bottom: 0, right: 0)
        let docPath = getDocumentsDirectory()
        let filelist = getSortedFilesList()
            filesList.removeAll()
            for filename in filelist!{
                let filePath = docPath + "/" + filename
                let fileSize = (try! FileManager.default.attributesOfItem(atPath: filePath)[FileAttributeKey.size] as! NSNumber).uint64Value
                
                let fileDate = (try! FileManager.default.attributesOfItem(atPath: filePath)[FileAttributeKey.modificationDate] as! Date)
                let dateFormatters = DateFormatter()
                dateFormatters.locale = Locale.current
                dateFormatters.timeZone = TimeZone.current
                dateFormatters.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let selectedDateStr = dateFormatters.string(from: fileDate)
//                let selectedDateFromStr = dateFormatters.date(from: selectedDateStr)!
                
                filesList.append([filename, String(fileSize), selectedDateStr])
            }
            tableView.reloadData()
    }
    
    func getSortedFilesList() -> Array<String>?{
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let urlArray = try? FileManager.default.contentsOfDirectory(at: directory,
                                                                       includingPropertiesForKeys: [.contentModificationDateKey],
                                                                       options:.skipsHiddenFiles) {
            
            return urlArray.map { url in
                (url.lastPathComponent, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                .map { $0.0 } // extract file names
            
        } else {
            return nil
        }
    }
    
    func uploadAllClicked(sender:UIBarButtonItem){
        if filesList.count > 0 {
            allFilesUpload(IndexPath(row:filesList.count - 1, section:0))
        }
//        infoButton.isEnabled = false
//        self.uploadAllFiles()
//        session.operationQueue.waitUntilAllOperationsAreFinished()
//        self.effectView.removeFromSuperview()
//        self.showUploadIndicator("Tutti i files sono stati inviati")
//
//        DispatchQueue.main.async {
//            self.session.operationQueue.maxConcurrentOperationCount = 100
//            self.uploadAllFiles()
//            self.session.operationQueue.waitUntilAllOperationsAreFinished()
//            //sleep(500)
//            self.deleteAllFiles()
//            self.filesList.removeAll()
//            self.tableView.reloadData()
//            DispatchQueue.main.async {
//                self.uploadIndicator?.hideView()
//                SCLAlertView().showInfo("Info", subTitle: "Il file è stato inviato!", closeButtonTitle: "OK")
////                self.infoButton.isEnabled = true
//            }
//        }
    }
    var deletingFiles: [String] = []
    
    func uploadAllFiles(){
//        for fileName in filesList {
//            uploadFile(fileName[0])
//        }
//        for var i in (0..<filesList.count).reversed()
//        {
//            requestUploadFile(IndexPath(row:i, section:0))
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        toolbar.isHidden = false;
        
        let root = self.parent as! ViewController
        let recorderViewController = root.viewControllers?[1] as! RecorderViewController
        if (recorderViewController.audioRecorder) != nil && recorderViewController.audioRecorder.isRecording{
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("OK"){
                self.tabBarController?.selectedIndex = 1
            }
            alert.showInfo("Info", subTitle: "Non può muoversi durante la registrazione!")
            
            return
        }
        let defaultValues = UserDefaults.standard
        let loggedIn = defaultValues.string(forKey:"username")
        if loggedIn == nil{
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            let userName = alert.addTextField("User Name:")
            let password = alert.addTextField("Password")
            password.isSecureTextEntry = true
            alert.addButton("Accedi") {
                print("User Name: \(userName.text)")
                print("Password: \(password.text)")
                
                let txtUserName = userName.text! as String
                let txtPassword = password.text! as String
                let parameters: Parameters = ["username": txtUserName, "password": txtPassword]
                Alamofire.request("http://web.servicelines.it:82/test/gwapp/ws_login.php", parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    print("Result: \(response.result)")                         // response serialization result
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        if utf8Text.lowercased().range(of:"status: 1") != nil {
                            defaultValues.set(txtUserName, forKey: "username")
                            defaultValues.set(txtPassword, forKey: "password")
                        }
                        else{
                            SCLAlertView().showInfo("Error", subTitle: "Username o Password errati!", closeButtonTitle: "OK")
                            self.tabBarController?.selectedIndex = 1
                        }
                    }
                }
            }
            alert.addButton("Annulla"){
                self.tabBarController?.selectedIndex = 1
            }

            alert.showEdit("Elenco registrazioni", subTitle: "")
        }

    }
    
    func getDocumentsDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return path
    }
    
    func sendFileUploadInfom(_ fileName: String, fileSize: Int64, level: Int, completionHandler: @escaping (Bool, String)->() ){
        let userName = UserDefaults.standard.string(forKey: "username")
        let params: Parameters = [
            "filesize": fileSize,
            "username": userName ?? "",
            "filename": fileName
        ]
        Alamofire.request("http://web.servicelines.it:82/test/gwapp/WS_File_Transfer.php", parameters: params, encoding: URLEncoding.default).responseJSON { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                if utf8Text.lowercased().range(of:"status: 1") != nil {
                    completionHandler(true, "Success")
                    print("sendUploadInform request successed!")
                }
                else if level < 10{
                    //sleep(500)
                    print("SendUploadInform failed: \(level)")
                    self.sendFileUploadInfom(fileName, fileSize: fileSize, level: level+1, completionHandler: completionHandler)
                }
                else{
                    completionHandler(false, utf8Text)
                }
            }
            
        }
    }

    func allFilesUpload(_ index: IndexPath){
        if !isInternetAvailable(){
            SCLAlertView().showNotice("NetworkError", subTitle: "Il dispositivo non sembra essere connesso ad internet, attiva la connessione!", closeButtonTitle: "OK")
            return
        }
        let fileName = filesList[index.row]

        self.showUploadIndicator("Sto inviando il file " + fileName[0])
        DispatchQueue.main.async {
            self.uploadFile(fileName[0])
            self.session.operationQueue.waitUntilAllOperationsAreFinished()
            let fileSize = Int64(fileName[1])!
            DispatchQueue.main.async {
                //                    self.effectView.removeFromSuperview()
                self.sendFileUploadInfom(fileName[0], fileSize: fileSize, level: 0, completionHandler: {success, error in
                    self.uploadIndicator?.hideView()
                    if success{
                        self.deleteFileByName(fileName[0])
                        self.filesList.remove(at: index.row)
                        self.tableView.reloadData()
                        //SCLAlertView().showInfo("Info", subTitle: "Il file è stato inviato!", closeButtonTitle: "OK")
                        
                        if(index.row > 0){
                            //SCLAlertView().showInfo("Info", subTitle: "Il file è stato inviato!", closeButtonTitle: "OK")                            
                            self.allFilesUpload(IndexPath(row: index.row - 1, section: 0))
                        }
                        else{
                            SCLAlertView().showInfo("Info", subTitle: "Tutti i files sono stati inviati!", closeButtonTitle: "OK")
                        }
                    }
                    else{
                        SCLAlertView().showInfo("Info", subTitle: error, closeButtonTitle: "OK")
                    }
                })
            }
            
        }

    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filesList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        // Configure the cell...
        let fileName = filesList[indexPath.row][0]
        cell.textLabel?.text = fileName
        let sizeText = String(Int(filesList[indexPath.row][1])! / 1024)
        cell.detailTextLabel?.text = sizeText + " Kbyte  " + filesList[indexPath.row][2]
        
        if fileName.contains("AUD"){
            cell.backgroundColor = .cyan
        }
        else{
            cell.backgroundColor = .yellow
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let fileName = filesList[indexPath.row][0]
        let playAction = UITableViewRowAction(style: .normal, title: "PLAY"){
            (rowAction, indexPath) in
            self.requestPlayFile(indexPath)
        }
        
        let stopAction = UITableViewRowAction(style: .normal, title: "STOP"){
            (rowAction, indexPath) in
            self.stopFile(indexPath)
        }
        
        let imagePreviewAction = UITableViewRowAction(style: .normal, title: "ANTEPRIMA"){
            (rowAction, indexPath) in
            self.previewImage(indexPath)
        }
        
        let uploadAction = UITableViewRowAction(style: .normal, title: "INVIA"){
            (rowAction, indexPath) in
            self.requestUploadFile(indexPath)
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "ELIMINA"){
            (rowAction, indexPath) in
            if self.audioPlayer != nil && self.audioPlayer.isPlaying{
                SCLAlertView().showInfo("Info", subTitle: "Impossible cancellare un file mentre lo stai ascoltanto!", closeButtonTitle: "OK")
                return
            }
            self.deleteFile(indexPath)
            SCLAlertView().showInfo("Info", subTitle: "Il file è stato cancellato correttamente", closeButtonTitle: "OK")

        }
        
        playAction.backgroundColor = UIColor.blue
        stopAction.backgroundColor = UIColor.darkGray
        uploadAction.backgroundColor = UIColor.purple
        deleteAction.backgroundColor = UIColor.brown
        
        if fileName.range(of:"AUD") != nil{
            return [deleteAction, uploadAction, stopAction, playAction]
        }else {
            return [deleteAction, uploadAction, imagePreviewAction]
        }
    }
    
    func previewImage(_ indexPath: IndexPath){
//        let appearance = SCLAlertView.SCLAppearance(
//            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
//            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
//            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
//            showCloseButton: false
//        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView()
        
        // Creat the subview
        let subview = UIView(frame: CGRect(x:0,y:0,width:300,height:340))
        
        // Add textfield 1
        let imageView = UIImageView(frame: CGRect(x:10,y:10,width:280,height:320))
        let imageFilename = getDocumentsDirectory() + "/" + filesList[indexPath.row][0]
        //let pathURL = URL(string: audioFilename)!
//        let url = URL(fileURLWithPath: imageFilename)
        let image    = UIImage(contentsOfFile: imageFilename)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        subview.addSubview(imageView)
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        
        alert.showInfo("Anteprima", subTitle: "", closeButtonTitle: "CHIUDI")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.effectView.removeFromSuperview()
    }
    
    var recordingSession: AVAudioSession!

    func requestPlayFile(_ indexPath:IndexPath){
        let fileName = filesList[indexPath.row][0]
        activityIndicator("Playing file \(fileName) ...")
        DispatchQueue.main.async {
            self.playFile(fileName)
            DispatchQueue.main.async {
//                self.effectView.removeFromSuperview()
                //                self.infoButton.isEnabled = true
            }
        }
//        recordingSession = AVAudioSession.sharedInstance()
//        
//                do {
//                    try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//                    try recordingSession.setActive(true)
//                    self.playFile(fileName)
//                } catch {
//                    // failed to record!
//                }

    }
    
    func playFile(_ fileName: String){
        let audioFilename = getDocumentsDirectory() + "/" + fileName
        //let pathURL = URL(string: audioFilename)!
        let url = URL(fileURLWithPath: audioFilename)
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
        }catch{
            
        }
    }
    
    func stopFile(_ indexPath: IndexPath){
        if audioPlayer != nil{
            audioPlayer.stop()
        }
        self.effectView.removeFromSuperview()
    }
   
    func deleteFileByName(_ fileName: String){
        let filePath = getDocumentsDirectory() + "/" + fileName
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(atPath: filePath)
        }
        catch {
        }
    }
    
    func deleteAllFiles(){
        for fileName in filesList {
            let fileSize = Int64(fileName[1])!
            self.sendFileUploadInfom(fileName[0], fileSize: fileSize, level: 0, completionHandler: {success, errorMessage in
                if success {
                    //self.deletingFiles.append(fileName[0])
                    self.deleteFileByName(fileName[0])
                }
                else{
                    SCLAlertView().showError("Server Error", subTitle: errorMessage, closeButtonTitle: "OK")
                }
            })

        }
        //deletingFiles.removeAll()
    }

    func deleteFile(_ indexPath: IndexPath){
        let fileName = filesList[indexPath.row]
        let filePath = getDocumentsDirectory() + "/" + fileName[0]
        
        let fileManager = FileManager.default
        
        do{
            try fileManager.removeItem(atPath: filePath)
            self.filesList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        catch {
            
        }
    }
    
    var uploadIndicator: SCLAlertView?
    
    func showUploadIndicator(_ message: String){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        // Initialize SCLAlertView using custom Appearance
        uploadIndicator = SCLAlertView(appearance:appearance)
        
        uploadIndicator?.showWait("", subTitle: message)
    }
    
    func requestUploadFile(_ indexPath: IndexPath){
        if !isInternetAvailable(){
            SCLAlertView().showNotice("NetworkError", subTitle: "Il dispositivo non sembra essere connesso ad internet, attiva la connessione!", closeButtonTitle: "OK")
            return
        }
        let fileName = filesList[indexPath.row]
//        activityIndicator("Caricamento di ....")
//        self.effectView.removeFromSuperview()
//        SCLAlertView().showWait("Info", subTitle: "Caricamento di ....")
        self.showUploadIndicator("Sto inviando il file " + fileName[0])
        DispatchQueue.main.async {
            self.uploadFile(fileName[0])
            self.session.operationQueue.waitUntilAllOperationsAreFinished()
            let fileSize = Int64(fileName[1])!
            DispatchQueue.main.async {
                //                    self.effectView.removeFromSuperview()
                self.sendFileUploadInfom(fileName[0], fileSize: fileSize, level: 0, completionHandler: {success, error in
                    self.uploadIndicator?.hideView()
                    if success{
                        self.deleteFileByName(fileName[0])
                        self.filesList.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        SCLAlertView().showInfo("Info", subTitle: "Il file è stato inviato!", closeButtonTitle: "OK")
                    }
                    else{
                        SCLAlertView().showInfo("Info", subTitle: error, closeButtonTitle: "OK")
                    }
                })
            }
            
        }

    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func uploadFile(_ fileName: String) {
        let documentDirUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let localPath = documentDirUrl.appendingPathComponent( fileName)
        
        self.session.upload(localPath, path: fileName) {
            (result, error) -> Void in
    }
    

}
}
