//
//  SettingsViewController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 16.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa

class SettingsViewController : NSViewController {
    @IBOutlet weak var serverIPTextBox: NSTextField!
    @IBOutlet weak var portTextBox: NSTextField!
    @IBOutlet weak var tokenTextBox: NSTextField!
    @IBOutlet weak var customFlagsTextBox: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        serverIPTextBox.stringValue = (Preferences.shared.serverIP == Preferences.defaults.serverIP) ? "" : Preferences.shared.serverIP
        
        portTextBox.stringValue = (Preferences.shared.serverPort == Preferences.defaults.serverPort) ? "" : String(Preferences.shared.serverPort)
        
        tokenTextBox.stringValue = Preferences.shared.customToken
        
        customFlagsTextBox.stringValue = Preferences.shared.customFlags
        self.view.window?.styleMask.remove(.resizable)
    }
    
    override func viewWillDisappear() {
        updateStorageObject()
        
        super.viewWillDisappear()
    }
    
    @IBAction func generateButtonClicked(_ sender: Any) {
        tokenTextBox.stringValue = randomString(length: 30)
    }
    
    @IBAction func customFlagsChange(_ sender: Any) {
        updateStorageObject()
    }
    
    @IBAction func serverIPdidChange(_ sender: Any) {
        updateStorageObject()
    }
    
    @IBAction func portDidChange(_ sender: Any) {
        updateStorageObject()
    }
    
    @IBAction func tokenDidChange(_ sender: Any) {
        updateStorageObject()
    }
    
    func updateStorageObject() {
        if (serverIPTextBox.stringValue != "") {
            Preferences.shared.serverIP = serverIPTextBox.stringValue
        }
        else {
            Preferences.shared.serverIP = Preferences.defaults.serverIP
        }
        if (portTextBox.stringValue != "") {
            Preferences.shared.serverPort = Int(portTextBox.stringValue) ?? Preferences.defaults.serverPort
        }
        else {
            Preferences.shared.serverPort = Preferences.defaults.serverPort
        }
        
        Preferences.shared.customToken = tokenTextBox.stringValue
        
        Preferences.shared.customFlags = customFlagsTextBox.stringValue

        Preferences.shared.savePreferences()
    }
}
