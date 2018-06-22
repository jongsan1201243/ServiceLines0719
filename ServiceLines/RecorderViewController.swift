//
//  RecorderViewController.swift
//  ServiceLines
//
//  Created by Mac on 13/06/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import AVFoundation
import SCLAlertView
import SwiftLocation
import CoreLocation
import ActionSheetPicker_3_0
import Alamofire
import Alamofire_Synchronous
//import UserNotifications

class RecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var paramsLabel: UILabel!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
   
    var syncTime = TimeInterval(3600*12)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingLabel.isHidden=true
        activityindicator.isHidden=true
        
        // Do any additional setup after loading the view.
        recordingSession = AVAudioSession.sharedInstance()
        
//        do {
//            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//            try recordingSession.setActive(true)
//            recordingSession.requestRecordPermission() { [unowned self] allowed in
//                DispatchQueue.main.async {
//                    if allowed {
//                        //self.loadRecordingUI()
//                    } else {
//                        // failed to record!
//                    }
//                }
//            }
//        } catch {
//            // failed to record!
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppDelegate.SpaceLimited{
            SCLAlertView().showInfo("Important info", subTitle: "Stai terminando lo spazio disponibile sul device")
        }
    }
    
    
//    @IBAction func alertshowtest(_ sender: Any) {
//        
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: false
//        )
//        let alertView = SCLAlertView(appearance: appearance)
//        alertView.showWait("", subTitle: "This is a more descriptive error text. file name is rec 11123454dsvsdvsdvsdvsvd") // wait
//        
//    }
    
    
    public func setButtonsVisible() {
        let userValues = UserDefaults.standard
        if let fileType = userValues.string(forKey: "tipofile"){
            if fileType == "REC"{
                playButton.isHidden = true
                recordButton.isHidden = false
            }
            else if fileType == "DOC"{
                recordButton.isHidden = true
                playButton.isHidden = false
            }
        }
        
        if let societa = userValues.string(forKey: "societa"), let codice = userValues.string(forKey: "codice"), let tipoFile = userValues.string(forKey: "tipofile"){
            var labelText = "Societa: \(societa) \nCodice: \(codice)  \nTipo File: \(tipoFile)"
            if let nomeDb = userValues.string(forKey: "nome_db"){
                labelText += "\nNominativo: \(nomeDb)"
            }
            if let descriDoc = userValues.string(forKey: "descridoc"){
                labelText += "\nDescrizione Documento: \(descriDoc)"
            }
            
            if let oldSocieta = userValues.string(forKey: "oldSocieta"), let oldCodice = userValues.string(forKey: "oldCodice"){
                if oldSocieta != societa || oldCodice != codice{
                    if self.audioRecorder != nil && self.audioRecorder.isRecording{
                        stopButtonClicked(stopButton)
                    }
                }
            }
            
            paramsLabel.isHidden = false
            paramsLabel.text = labelText
            //paramsLabel.sizeToFit()
            paramsLabel.frame = CGRect(x:20, y:30, width: self.view.frame.width - 40, height: 160)
            paramsLabel.center.x = self.view.center.x
        }
        else{
            paramsLabel.isHidden = true
        }
        self.tabBarController?.selectedIndex = 1
    }
    
    var imagePicker: UIImagePickerController!
   
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var timer: Timer!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
//    @IBOutlet weak var stopButton: UIButton!
//    @IBOutlet weak var pauseButton: UIButton!
//    @IBOutlet weak var recordButton: UIButton!

    @IBAction func playButtonClicked(_ sender: UIButton) {
        displaySwitchCamAndLib()
    }
    
    func displaySwitchCamAndLib(){
        let alertController = UIAlertController(title: "Carica foto", message: "Cosa vuoi fare?", preferredStyle: .alert)
        
        let selectFromLibrary = UIAlertAction(title: "Scegli tra le foto esistenti", style: .default, handler: { (action) -> Void in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let takePhotoWithCam = UIAlertAction(title: "Fai una nuova foto", style: .default, handler: { (action) -> Void in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(selectFromLibrary)
        alertController.addAction(takePhotoWithCam)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        let originImageData = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = originImageData.resizeImage(newWidth: 1024)
        let data = UIImageJPEGRepresentation(imageData, 1.0)
        getFullRecordFilePath(typePref: "DOC_", completionHandler: { success, fileName in
            do{
                if picker.sourceType == .camera{
                    UIImageWriteToSavedPhotosAlbum(imageData, self, nil, nil)
                }
                try data?.write(to: fileName!)
                SCLAlertView().showInfo("Info", subTitle: "l'immagine è stata salvata correttamente", closeButtonTitle: "OK")
            }
            catch{                }
            
        })
        
    }
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        recordingLabel.isHidden=true
        activityindicator.isHidden=true
                if audioRecorder != nil {
                    finishRecording(success: true)
                    recordingLabel.isHidden=true
                    activityindicator.isHidden=true
                }
        
                recordingLabel.isHidden=true
        SCLAlertView().showInfo("Info", subTitle: "Registrazione fermata, il file è stato salvato correttamente!", closeButtonTitle: "OK")
    }
    @IBAction func recordButtonClicked(_ sender: UIButton) {
                if audioRecorder == nil {
                    startRecording()
                }
                else if audioRecorder.isRecording{
                    audioRecorder.pause()
                    self.recordButton.setTitle("REC", for: .normal)
                    self.recordingLabel.text = "La registrazione è in pausa"
                    activityindicator.stopAnimating()
                    SCLAlertView().showInfo("Info", subTitle: "La registrazione è in pausa....")
                }
                else{
                    audioRecorder.record()
                    self.recordButton.setTitle("PA", for: .normal)
                    self.recordingLabel.text = "Rec..."
                    activityindicator.startAnimating()
                }

    }
    
    @IBAction func pauseButtonClicked(_ sender: UIButton) {

    }
    
    var recordingLimit:Int = 60*60
    var distanceLimit = 5 // Meters
    var recordingAlertLimit: Int = 20*60
    
    func startRecording() {
        let userValues = UserDefaults.standard
        if let settings = userValues.array(forKey: "settings") {
            print(settings)
            let settingsArr = settings as! [Dictionary<String, Any>]
            distanceLimit = Int(settingsArr[0]["value"] as! String)!
            recordingLimit = settingsArr[1]["value"] as! Int
            recordingAlertLimit = settingsArr[2]["value"] as! Int
        }
       
        registerDistanceAlert()
        
        getFullRecordFilePath(typePref: "AUD_", completionHandler: { success, fileName in
            self.recordingLabel.isHidden=false
            self.activityindicator.isHidden=false
            self.activityindicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyle.gray
            self.activityindicator.startAnimating()
            self.recordButton.setTitle("PA", for: .normal)
            self.recordingLabel.text = "Rec..."

            self.recordingSession = AVAudioSession.sharedInstance()
            try! self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try! self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission(){ [ unowned self] allowed in
                DispatchQueue.main.async{
                    if allowed{
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        
                        do {
                            self.audioRecorder = try AVAudioRecorder(url: fileName!, settings: settings)
                            self.audioRecorder.delegate = self
                            self.audioRecorder.isMeteringEnabled = true
                            self.audioRecorder.prepareToRecord()
                            self.audioRecorder.record()
                            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.recordingLimit), target: self,   selector: (#selector(RecorderViewController.updateTimer)), userInfo: nil, repeats: false)
                            
                            self.recordButton.setTitle("PA", for: .normal)
                            self.stopButton.isHidden = false
                        } catch {
                            self.finishRecording(success: false)
                        }
                        
                    }
                }
            }
            
        })

        
    }
    
    func updateTimer(){
        
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound (systemSoundID)
        
        notificationCount += 1
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(recordingAlertLimit), target: self,   selector: (#selector(RecorderViewController.updateNotificationTimer)), userInfo: nil, repeats: false)
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        alertView = SCLAlertView(appearance:appearance)
            alertView?.addButton("CONTINUA"){
                if self.timer != nil{
                    self.timer.invalidate()
                    self.timer = nil
                }
            }
            alertView?.addButton("TERMINA REC") {
                if self.timer != nil{
                    self.timer.invalidate()
                    self.timer = nil
                }
                self.stopButtonClicked(self.stopButton)
            }
            alertView?.showNotice("Time Limit", subTitle: "La durata della registrazione ha superato il limite massimo impostato")
    }
    
    var notificationCount = 0
    var alertView:SCLAlertView? = nil
    
    func updateNotificationTimer(){
        DispatchQueue.main.async{
            let systemSoundID: SystemSoundID = 1019
            AudioServicesPlaySystemSound (systemSoundID)
        }
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
        hideAlert()

        if notificationCount < 3 {
            notificationCount += 1
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(recordingAlertLimit), target: self,   selector: (#selector(RecorderViewController.updateNotificationTimer)), userInfo: nil, repeats: false)
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            alertView = SCLAlertView(appearance:appearance)
            alertView?.addButton("CONTINUA"){
                self.notificationCount = 0
                if self.audioRecorder != nil {
                    self.audioRecorder.record()
                }
            }
            alertView?.addButton("TERMINA REC") {
                self.notificationCount = 0
                self.stopButtonClicked(self.stopButton)
            }
            alertView?.showNotice("Time Limit", subTitle: "La durata della registrazione ha superato il limite massimo impostato")
        }
        else{
            
            self.stopButtonClicked(self.stopButton)
            notificationCount = 0
        }
    }
    
    func hideAlert(){
        if alertView != nil {
            alertView?.hideView()
            alertView = nil
        }
    }
    
    func registerDistanceAlert(){
        Location.getLocation(accuracy: .room, frequency: .oneShot, success: { _,location in
            print("Found location \(location) Radius: \(self.distanceLimit)")
            do {
                try Location.monitor(regionAt: location.coordinate, radius: CLLocationDistance(self.distanceLimit), enter: { _ in
                    print("Entered in region!")
                }, exit: { _ in
                    print("Exited from the region")
                    if self.audioRecorder == nil{
                        return
                    }
                    if !self.audioRecorder.isRecording{
                        return
                    }
                    
                    let systemSoundID: SystemSoundID = 1016
                    AudioServicesPlaySystemSound (systemSoundID)
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance:appearance)
                    alertView.addButton("CONTINUA"){
                        self.audioRecorder.record()
                    }
                    alertView.addButton("TERMINA REC") {
                        self.stopButtonClicked(self.stopButton)
                    }
                    alertView.showNotice("Distance Limit", subTitle: "Ti sei spostato dalla posizione iniziale di registrazione. Vuoi continuare a registrare?")

                }, error: { req, error in
                    print("An error has occurred \(error)")
                    req.cancel() // abort the request (you can also use `cancelOnError=true` to perform it automatically
                })
            } catch {
                print("Cannot start heading updates: \(error)")
            }

        }) { (_, last, error) in
            print("Something bad has occurred \(error)")
        }

    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFullRecordFilePath(typePref: String, completionHandler: @escaping (Bool, URL?) -> ()) {
        let deviceUid = UIDevice.current.identifierForVendor!.uuidString
        let deviceName = UIDevice.current.name
        let defaultValues = UserDefaults.standard
        let userName = defaultValues.string(forKey: "username")
        var fileName = ""
        let societa = defaultValues.string(forKey: "societa")
        fileName += societa ?? "societa"
        
        let codice = defaultValues.string(forKey: "codice")
        fileName += "_\(codice ?? "codice")"
        let tipodoc = defaultValues.string(forKey: "tipodoc")

        var url = "http://web.servicelines.it:82/test/gwapp/WS_Audio_File_Start.php"
        if typePref == "DOC_"{
            url = "http://web.servicelines.it:82/test/gwapp/WS_Doc_File_Start.php"
        }

        let params: Parameters = [
            "device_name": deviceName,
            "device_UID": deviceUid,
            "username": userName ?? "",
            "societa": societa ?? "societa",
            "codice": codice ?? "codice",
            "tipodoc": tipodoc ?? ""
        ]
        
        Alamofire.request(url, parameters: params).responseString(){ response in
            let documentsDirectory = self.getDocumentsDirectory()
            let resultString = response.result.value
            if resultString?.lowercased().range(of:"status: 1") != nil {
                let start = resultString?.index((resultString?.startIndex)!, offsetBy: 23)
                let end = resultString?.index((resultString?.endIndex)!, offsetBy: -4)
                fileName = (resultString?[start!..<end!])!
                let path = documentsDirectory.appendingPathComponent(fileName)
                completionHandler(true, path)
            }
            else{
//                SCLAlertView().showError("Server Error", subTitle: resultString!)
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddhhmmss"
                //
                let fileName = typePref + formatter.string(from: date) + (typePref == "DOC_" ? ".jpg" : ".m4a")
                completionHandler(false, documentsDirectory.appendingPathComponent(fileName))
            }
            

        }
        //print(response)

        
//        fileName += typePref
//        
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMddhhmmss"
//        
//        fileName += formatter.string(from: date)
//        
//        if typePref == "_DOC_" {
//            fileName += ".jpg"
//        } else {
//            fileName += ".m4a"
//        }
//        
//        let documentsDirectory = getDocumentsDirectory()
////        let fileName = ""
//        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func finishRecording(success: Bool) {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        if audioRecorder != nil {
            print(audioRecorder.currentTime)
            audioRecorder.stop()
            audioRecorder = nil
        }
        
        if success {
            recordButton.setTitle("REC", for: .normal)
        } else {
            recordButton.setTitle("REC", for: .normal)
            // recording failed :(
        }
        self.stopButton.isHidden = true
    }
    
//    func syncRequest(url: String, param: Parameters) -> Response<AnyObject, NSError> {
//        
//        var outResponse: Response<AnyObject, NSError>!
//        let semaphore: dispatch_semaphore_t! = dispatch_semaphore_create(0)
//        
//        self.request(URLRequest).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
//            
//            outResponse = response
//            dispatch_semaphore_signal(semaphore)
//        }
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        
//        return outResponse
//    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
            self.stopButton.isHidden = true
        }
    }
//    
//    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
//        
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//        UIGraphicsBeginImageContext(newWidth, newHeight)
//        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
