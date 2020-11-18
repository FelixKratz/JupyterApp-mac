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

    @IBAction func newTerminalAtFolderClicked(_ sender: Any) {
        guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ViewController else {
            return
        }
        //let out : String = runSynchronousShellWithUserConfig(cmd: "open -a Terminal " + currentViewController.directory) ?? ""
        _ = runSynchronousShell(launchPath: "/usr/bin/open", args: "-a", "Terminal", currentViewController.directory.replacingOccurrences(of: "\\ ", with: " ")) ?? ""
    }
    
    @IBAction func openFolderInFinderClicked(_ sender: Any) {
        guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ViewController else {
            return
        }
        //let out : String = runSynchronousShellWithUserConfig(cmd: "open " + currentViewController.directory) ?? ""
        _ = runSynchronousShell(launchPath: "/usr/bin/open", args: currentViewController.directory.replacingOccurrences(of: "\\ ", with: " ")) ?? ""
    }
    
    @IBAction func showConsoleClicked(_ sender: Any) {
        guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ViewController else {
            guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ConsoleViewController else {
                return
            }
            currentViewController.view.window?.close()
            return
        }
        
        if (currentViewController.consoleDataDelegate != nil) {
            let consoleViewController : ConsoleViewController = (currentViewController.consoleDataDelegate?.getViewController())!
            consoleViewController.view.window?.makeKeyAndOrderFront(self)
            return
        }
        
        let newWindowController = NSApplication.shared.mainWindow?.windowController?.storyboard!.instantiateController(withIdentifier: "console") as! NSWindowController
        guard let consoleViewController = newWindowController.contentViewController as? ConsoleViewController else {
            return
        }
        consoleViewController.delegate = currentViewController
        currentViewController.consoleDataDelegate = consoleViewController
        newWindowController.showWindow(self)
    }
    
    @IBAction func restartClicked(_ sender: Any) {
        func restartFromConsoleWindow() {
            guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ConsoleViewController else {
                return
            }
            let viewController : ViewController = (currentViewController.delegate?.getViewController())!
            viewController.consoleController?.kill()
            viewController.startJupyterServer()
        }
        
        guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ViewController else {
            return restartFromConsoleWindow()
        }
        currentViewController.consoleController?.kill()
        currentViewController.startJupyterServer()
    }
    
    @IBAction func terminateClicked(_ sender: Any) {
        func terminateFromConsoleWindow() {
            guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ConsoleViewController else {
                return
            }
            currentViewController.delegate?.getViewController().consoleController?.kill()
        }
        
        guard let currentViewController = NSApplication.shared.mainWindow?.contentViewController as? ViewController else {
            return terminateFromConsoleWindow()
        }
        currentViewController.consoleController?.kill()
    }
    

    
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

