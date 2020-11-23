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
    @IBOutlet weak var disableServerStart: NSButton!
    @IBOutlet weak var noteBooksInsteadOfLabs: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        serverIPTextBox.stringValue = (Preferences.shared.serverIP == Preferences.defaults.serverIP) ? "" : Preferences.shared.serverIP
        
        portTextBox.stringValue = (Preferences.shared.serverPort == Preferences.defaults.serverPort) ? "" : String(Preferences.shared.serverPort)
        
        tokenTextBox.stringValue = Preferences.shared.customToken
        customFlagsTextBox.stringValue = Preferences.shared.customFlags
        disableServerStart.state = (Preferences.shared.disableJupyterServer) ? NSControl.StateValue.on : NSControl.StateValue.off
        noteBooksInsteadOfLabs.state = (Preferences.shared.useNotebooks) ? NSControl.StateValue.on : NSControl.StateValue.off
        
        self.view.window?.styleMask.remove(.resizable)
    }
    
    override func viewWillDisappear() {
        updateStorageObject()
        
        super.viewWillDisappear()
    }
    
    @IBAction func disableAutomaticServerStartToggled(_ sender: Any) {
        updateStorageObject()
    }
    
    @IBAction func useNotebooksInsteadOfLabsToggled(_ sender: Any) {
        updateStorageObject()
    }
    
    @IBAction func coffeeButtonClicked(_ sender: Any) {
        if let url = URL(string: "https://www.github.com/FelixKratz") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func generateButtonClicked(_ sender: Any) {
        tokenTextBox.stringValue = randomString(length: 30)
        updateStorageObject()
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
        Preferences.shared.disableJupyterServer = (disableServerStart.state == NSControl.StateValue.on)
        Preferences.shared.useNotebooks = (noteBooksInsteadOfLabs.state == NSControl.StateValue.on)
        
        Preferences.shared.savePreferences()
    }
}
