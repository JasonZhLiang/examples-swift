//
//  ViewController.swift
//  Basic Example
//
//  Created by brainCloud Support on 2018-08-14.
//  Copyright © 2018 brainCloud Support. All rights reserved.

import UIKit
import BrainCloud

class MainScene: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource   {
   
    let ENTITY_TYPE = "Person"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    var pickerData = [] as Array<String>
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    var lastRow = 0
    var entities = Array<AnyObject>()
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(lastRow != row) {
           
            
            var entity = entities[row] as! Dictionary<String, AnyObject>
            
            entityType.text = entity["entityType"] as? String
            name.text = entity["data"]?["name"] as? String
            age.text = entity["data"]?["age"] as? String
            
            lastRow = row;
        }
        
        return pickerData[row]
    }
    
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        deviceTokenLabel.text = AppDelegate.pushToken
        
        AppDelegate._bc.entityService.getEntitiesByType(
            ENTITY_TYPE,
            completionBlock: onGetEntitiesByType,
            errorCompletionBlock: onGetEntitiesByTypeFailed,
            cbObject: nil)
    }
    
    func onGetEntitiesByType(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        print("\n\(serviceOperation!) Success \(jsonData!)")
        
        self.entityLog.text = "\n\(serviceOperation!) Success \(jsonData!)"
        
        let data = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            entities = json["data"]!["entities"] as! Array<AnyObject>;
            
            pickerData = []
            
            for entity in entities {
                let entityData = entity as! Dictionary<String, AnyObject>
                pickerData.append(entityData["entityId"] as! String);
            }
            
            entityIdPicker.reloadAllComponents()
            
            print(entities);
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    func onGetEntitiesByTypeFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.entityLog.text = "\(serviceOperation!) Failed \(jsonError!)"
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var entityIdPicker: UIPickerView!
    @IBOutlet weak var entityType: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    
    @IBOutlet weak var entityLog: UITextView!
    
    @IBAction func onCreateEntity(_ sender: Any) {
        let jsonData = "{ \"name\": \"\(name.text!)\", \"age\": \"\(age.text!)\" }"
        let jsonAcl = "{ \"other\": 0 }"
        
        AppDelegate._bc.entityService.createEntity(ENTITY_TYPE,
                                                   jsonEntityData: jsonData,
                                                   jsonEntityAcl: jsonAcl,
                                                   completionBlock: onCreateEntity,
                                                   errorCompletionBlock: onCreateEntityFailed,
                                                   cbObject: nil)
        
        
    }
    
    func onCreateEntity(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        print("\n\(serviceOperation!) Success \(jsonData!)")
        
        self.entityLog.text = "\n\(serviceOperation!) Success \(jsonData!)"
        
        AppDelegate._bc.entityService.getEntitiesByType(
            ENTITY_TYPE,
            completionBlock: onGetEntitiesByType,
            errorCompletionBlock: onGetEntitiesByTypeFailed,
            cbObject: nil)
        
        
    }
    
    func onCreateEntityFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.entityLog.text = "\(serviceOperation!) Failed \(jsonError!)"
        
    }
    
    @IBAction func onDeleteEntity(_ sender: Any) {
        AppDelegate._bc.entityService.delete(pickerData[entityIdPicker.selectedRow(inComponent: 0)],
                                             version: -1,
                                             completionBlock: onDeleteEntity,
                                             errorCompletionBlock: onDeleteEntityFailed,
                                             cbObject: nil)
    }
    
    func onDeleteEntity(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        self.entityLog.text = "\(serviceOperation!) Success \(jsonData!)"
        
        AppDelegate._bc.entityService.getEntitiesByType(
            ENTITY_TYPE,
            completionBlock: onGetEntitiesByType,
            errorCompletionBlock: onGetEntitiesByTypeFailed,
            cbObject: nil)
    }
    
    func onDeleteEntityFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.entityLog.text = "\(serviceOperation!) Failed \(jsonError!)"
        
    }
    
    @IBOutlet weak var entityMenu: UIStackView!
    @IBOutlet weak var pushNotificationMenu: UIStackView!
    @IBOutlet weak var relayMenu: UIStackView!
    
    @IBAction func onChangeMenu(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            entityMenu.isHidden = false;
            pushNotificationMenu.isHidden = true;
            relayMenu.isHidden = true;
        } else if(sender.selectedSegmentIndex == 1) {
            entityMenu.isHidden = true;
            pushNotificationMenu.isHidden = false;
            relayMenu.isHidden = true;
        } else if(sender.selectedSegmentIndex == 2) {
            AppDelegate._bc.playerStateService.logout(
                nil,
                errorCompletionBlock: nil,
                cbObject: nil)
            
            AppDelegate._bc.getBCClient()
                .authenticationService.clearSavedProfile()
            AppDelegate._bc.storedAnonymousId = ""
            AppDelegate._bc.storedProfileId = ""
            
            UserDefaults.standard.set(false, forKey: "HasAuthenticated")
            
            self.performSegue(withIdentifier: "onLogout", sender: nil)
        } else if (sender.selectedSegmentIndex == 3) {
            entityMenu.isHidden = true;
            pushNotificationMenu.isHidden = true;
            relayMenu.isHidden = false;
        }
    }
    
    
    /**
        Push Notifications
     */
    
    @IBOutlet weak var deviceToken: UILabel!
    
    @IBAction func onRegisterPushNotificationsClicked(_ sender: Any) {
       
        deviceTokenLabel.text = AppDelegate.pushToken
        AppDelegate._bc.pushNotificationService.registerDeviceToken(
            PlatformObjc.iOS(),
            deviceToken: AppDelegate.pushToken,
            completionBlock: onPushNotificationSuccess,
            errorCompletionBlock: nil,
            cbObject: nil)
    }
    
    @IBAction func onDeregisterPushNotificationsClicked(_ sender: Any) {
        AppDelegate._bc.pushNotificationService.deregisterAllPushNotificationDeviceTokens(
            onPushNotificationSuccess,
            errorCompletionBlock: nil,
            cbObject: nil)
    }
    
    @IBAction func onSendPushNotificationsClicked(_ sender: Any) {
        AppDelegate._bc.pushNotificationService.sendSimplePushNotification(
            AppDelegate._bc.storedProfileId,
            message: "Message_" + String(describing: arc4random_uniform(2000)),
            completionBlock: onPushNotificationSuccess,
            errorCompletionBlock: nil,
            cbObject: nil)
    }
    
    @IBOutlet weak var pushLog: UILabel!
    
    func onPushNotificationSuccess(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        self.pushLog.text = "\(serviceOperation!) Success \(jsonData!)"
        
    }
    
    func onPushNotificationFailure(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        
        self.pushLog.text = "\(serviceOperation!) Failed \(jsonError!)"
    }
    
    
    @IBOutlet weak var relayLog: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
    
    @IBAction func onFindOrCreateLobbyClicked(_ sender: Any) {
        AppDelegate._bc.getBCClient()?.relayService.disconnect();
        AppDelegate._bc.getBCClient()?.rttService.disableRTT();
        
        sendBtn.isEnabled = false;
        relayLog.text = "Enabling RTT... ";
        
        AppDelegate._bc.getBCClient()?.rttService.enable(onRTTEnabled,
            failureCompletionBlock: onRTTFailed,
            cbObject: nil);
    }
    
    func onRTTEnabled(cbObject: NSObject?) {
        self.relayLog.text = self.relayLog.text! + "Enabled\n";
        self.relayLog.text = self.relayLog.text! + "Find or Create Lobby...\n";
        
        AppDelegate._bc.getBCClient()?.rttService.registerLobbyCallback(onLobbyEvent, cbObject: nil);
        
        AppDelegate._bc.lobbyService.findOrCreateLobby("Relay_lobbyT_v2", rating: 0, maxSteps: 1, algo: "{\"strategy\":\"ranged-absolute\",\"alignment\":\"center\",\"ranges\":[1000]}", filterJson: "{}", otherUserCxIds: [], isReady: true, extraJson: "{}", teamCode: "all", settings: "{}", completionBlock: onFindLobbySuccess, errorCompletionBlock: onFindLobbyFailed, cbObject: nil);
    }
    
    func onRTTFailed(message:String?, cbObject: NSObject?) {
        self.relayLog.text = self.relayLog.text! + "Failed: \(message!)\n";
    }
    
    func onFindLobbySuccess(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        // We do nothing here, we wait for RTT lobby events
    }
    
    func onFindLobbyFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.relayLog.text = self.relayLog.text! + "  Failed \(jsonError!)\n";
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func onLobbyEvent(eventJsonStr:String?, cbObject: NSObject?) {
        let eventJson = self.convertToDictionary(text:eventJsonStr!);
        let jsonData = eventJson?["data"] as! Dictionary<String, Any?>;
        
        let operation = eventJson?["operation"] as! String;
        self.relayLog.text = self.relayLog.text! + "Lobby event: \(operation)\n";
        
        if (operation == "ROOM_READY")
        {
            let jsonConnectData = jsonData["connectData"] as! Dictionary<String, Any?>;
            let address = jsonConnectData["address"] as! String;
            let jsonPorts = jsonConnectData["ports"] as! Dictionary<String, Any?>;
            let tcpPort = jsonPorts["tcp"] as! NSInteger;
            let passcode = jsonData["passcode"] as! String;
            let lobbyId = jsonData["lobbyId"] as! String;
            connectToRelay(lobbyId:lobbyId, passcode:passcode, host:address, port:tcpPort);
        }
        else if (operation == "DISBANDED")
        {
            let jsonReason = jsonData["reason"] as! Dictionary<String, Any?>;
            if (jsonReason["code"] as! NSInteger != RTT_ROOM_READY) // Did we disband for the wrong reason?
            {
                let errMessage = jsonReason["desc"] as! String;
                self.relayLog.text = self.relayLog.text! + "RTT Failed \(errMessage)\n";
            }
        }
    }
    
    func connectToRelay(lobbyId:String, passcode:String, host:String, port:NSInteger) {
        self.relayLog.text = self.relayLog.text! + "Connecting to Relay Server...\n";
        AppDelegate._bc.getBCClient()?.relayService.registerSystemCallback(onRelaySystemMessage, cbObject: nil);
        AppDelegate._bc.getBCClient()?.relayService.registerCallback(onRelayMessage, cbObject: nil);
        AppDelegate._bc.getBCClient()?.relayService.connect(BCRelayConnectionType.CONNECTION_TYPE_TCP, host: host, port: Int32(port), passcode: passcode, lobbyId: lobbyId, connectSuccess:onRelayConnected, connectFailure:onRelayDisconnected, cbObject: nil);
    }
    
    @IBAction func onSendMessageClicked(_ sender: Any) {
        let myProfileId = AppDelegate._bc.getBCClient()?.authenticationService.profileID;
        let myNetId = (AppDelegate._bc.getBCClient()?.relayService.getNetId(forProfileId: myProfileId))!;
        let data: Data? = txtMessage.text?.data(using: .utf8);
        AppDelegate._bc.getBCClient()?.relayService.send(data, toNetId: UInt64(myNetId), reliable: true, ordered: true, channel: 0);
    }
    
    func onRelayConnected(message:String?, cbObject: NSObject?) {
        self.relayLog.text = self.relayLog.text! + "Relay Connected\n";
        sendBtn.isEnabled = true;
    }
    
    func onRelayDisconnected(message:String?, cbObject: NSObject?) {
        self.relayLog.text = self.relayLog.text! + "Relay Disconnected \(message!)\n";
    }
    
    func onRelaySystemMessage(eventJsonStr:String?, cbObject: NSObject?) {
        let eventJson = self.convertToDictionary(text:eventJsonStr!);
        let operation = eventJson?["op"] as! String;
        self.relayLog.text = self.relayLog.text! + "Relay system message: \(operation)\n";
    }
    
    func onRelayMessage(size:Int32, data:Data?, cbObject: NSObject?) {
        let message = String(decoding: data!, as: UTF8.self);
        self.relayLog.text = self.relayLog.text! + "Relay message: \(message)\n";
    }
}

