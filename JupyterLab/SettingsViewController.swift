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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        serverIPTextBox.stringValue = Preferences.shared.folderPathForContextAction//(Preferences.shared.serverIP == Preferences.defaults.serverIP) ? "" : Preferences.shared.serverIP
        
        portTextBox.stringValue = Preferences.shared.fileNameForContextAction//(Preferences.shared.serverPort == Preferences.defaults.serverPort) ? "" : String(Preferences.shared.serverPort)
        
        tokenTextBox.stringValue = Preferences.shared.customToken
        self.view.window?.styleMask.remove(.resizable)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        updateStorageObject()
    }
    
    @IBAction func generateButtonClicked(_ sender: Any) {
        tokenTextBox.stringValue = randomString(length: 30)
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
        Preferences.shared.serverIP = serverIPTextBox.stringValue
        Preferences.shared.serverPort = Int(portTextBox.stringValue) ?? Preferences.defaults.serverPort
        Preferences.shared.customToken = tokenTextBox.stringValue
        
        Preferences.shared.savePreferences()
    }
}
