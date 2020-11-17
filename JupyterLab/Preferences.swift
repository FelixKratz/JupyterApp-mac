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

    var defaultServerIP : String = "http://127.0.0.1"
    var defaultServerPort : Int = 8888
    
    var serverIP : String = ""
    var serverPort : Int = 0
    var customToken : String = ""
    
    init() {
        loadPreferences()
    }
    
    func savePreferences() -> Void {
        let defaults = UserDefaults.standard
        defaults.set(serverIP, forKey: "serverIP")
        defaults.set(serverPort, forKey: "serverPort")
        defaults.set(customToken, forKey: "customToken")
        
        baseURL = serverIP
        basePort = serverPort - 1
    }
    
    func loadPreferences() -> Void {
        let defaults = UserDefaults.standard
        serverIP = defaults.string(forKey: "serverIP") ?? defaultServerIP
        serverPort = (defaults.integer(forKey: "serverPort") == 0) ? defaultServerPort : defaults.integer(forKey: "serverPort")
        customToken = defaults.string(forKey: "customToken") ?? customToken
    }
}
