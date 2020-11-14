//
//  AppDelegate.swift
//  JupyterLab
//
//  Created by Felix Kratz on 09.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    @IBAction func newFileClicked(_ sender: Any) {
        let window : WindowController = NSApplication.shared.mainWindow?.windowController as! WindowController
        window.newWindowForTab(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

