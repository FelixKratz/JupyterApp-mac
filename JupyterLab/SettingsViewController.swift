//
//  SettingsViewController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 16.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers

class SettingsViewController : NSViewController {
    @IBOutlet weak var serverIPTextBox: NSTextField!
    @IBOutlet weak var portTextBox: NSTextField!
    @IBOutlet weak var tokenTextBox: NSTextField!
    @IBOutlet weak var customFlagsTextBox: NSTextField!
    @IBOutlet weak var disableServerStart: NSButton!
    @IBOutlet weak var noteBooksInsteadOfLabs: NSButton!
    @IBOutlet weak var clickActionPopUpButtion: NSPopUpButton!
    @IBOutlet weak var terminalPathControl: NSPathControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        serverIPTextBox.stringValue = (Preferences.shared.serverIP == Preferences.defaults.serverIP) ? "" : Preferences.shared.serverIP
        
        portTextBox.stringValue = (Preferences.shared.serverPort == Preferences.defaults.serverPort) ? "" : String(Preferences.shared.serverPort)
        
        tokenTextBox.stringValue = Preferences.shared.customToken
        customFlagsTextBox.stringValue = Preferences.shared.customFlags
        disableServerStart.state = (Preferences.shared.disableJupyterServer) ? NSControl.StateValue.on : NSControl.StateValue.off
        noteBooksInsteadOfLabs.state = (Preferences.shared.useNotebooksOnFolder) ? NSControl.StateValue.on : NSControl.StateValue.off
        
        if (Preferences.shared.useNotebooksOnFile) {
            clickActionPopUpButtion.selectItem(withTitle: "Notebook")
        }
        else {
            clickActionPopUpButtion.selectItem(withTitle: "Lab")
        }
        
        terminalPathControl.url = Preferences.shared.terminalUrl
        
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
    
    @IBAction func clickActionChanged(_ sender: Any) {
        updateStorageObject()
    }
    
    @IBAction func coffeeButtonClicked(_ sender: Any) {
        if let url = URL(string:"https://www.paypal.com/donate?hosted_button_id=378TP7FW2CRYN") {
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
    
    @IBAction func terminalDidChange(_ sender: Any) {
        if let res = terminalPathControl.url {
            Preferences.shared.terminalUrl = res
            Preferences.shared.savePreferences()
        }
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
        Preferences.shared.useNotebooksOnFolder = (noteBooksInsteadOfLabs.state == NSControl.StateValue.on)
        Preferences.shared.useNotebooksOnFile = (clickActionPopUpButtion.selectedItem?.title == "Notebook")
        
        Preferences.shared.savePreferences()
    }
}
