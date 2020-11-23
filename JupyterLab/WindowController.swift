//
//  WindowController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 13.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa

class WindowController : NSWindowController {
    @IBAction override func newWindowForTab(_ sender: Any?) {
        let delegate = NSApp.delegate as! AppDelegate
        let newWindowController = delegate.storyBoard.instantiateController(withIdentifier: "jupyter") as! NSWindowController
        let newWindow = newWindowController.window!
        newWindow.windowController = self
        newWindowController.showWindow(self)
    }
}
