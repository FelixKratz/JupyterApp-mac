//
//  Preferences.swift
//  JupyterLab
//
//  Created by Felix Kratz on 16.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

class Preferences {
    
    static let shared = Preferences()

    struct defaults {
        static let disableJupyterServer : Bool = false
        static let useNotebooks : Bool = false
        static let serverIP : String = "http://127.0.0.1"
        static let serverPort : Int = 8888
    }
    
    private let settingsFile : UserDefaults = UserDefaults.standard
    
    var serverIP : String = ""
    var serverPort : Int = 0
    var customToken : String = ""
    var customFlags : String = ""
    var disableJupyterServer : Bool = false
    var useNotebooks : Bool = false
    
    var folderPathForContextAction : String = ""
    var fileNameForContextAction : String = ""
    var didStartFromContextAction : Bool = false
    
    init() {
        loadPreferences()
    }
    
    func savePreferences() -> Void {
        settingsFile.set(serverIP, forKey: "serverIP")
        settingsFile.set(serverPort, forKey: "serverPort")
        settingsFile.set(customToken, forKey: "customToken")
        settingsFile.set(disableJupyterServer, forKey: "disableJupyterServer")
        settingsFile.set(useNotebooks, forKey: "useNotebooks")
        settingsFile.set(customFlags, forKey: "customFlags")
        
        baseURL = serverIP
        basePort = serverPort - 1
    }
    
    func loadPreferences() -> Void {
        serverIP = settingsFile.string(forKey: "serverIP") ?? Preferences.defaults.serverIP
        serverPort = (settingsFile.integer(forKey: "serverPort") == 0) ? Preferences.defaults.serverPort : settingsFile.integer(forKey: "serverPort")
        customToken = settingsFile.string(forKey: "customToken") ?? customToken
        disableJupyterServer = settingsFile.bool(forKey: "disableJupyterServer")
        useNotebooks = settingsFile.bool(forKey: "useNotebooks")
        customFlags = settingsFile.string(forKey: "customFlags") ?? ""
    }
}
