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
    let storyBoard : NSStoryboard = NSStoryboard.init(name: "Main", bundle: nil)
    let jupyterWindowController : WindowController = WindowController()

    @IBAction func openInBrowserClicked(_ sender: Any) {
        guard let currentViewController = NSApp.mainWindow?.contentViewController as? ViewController else {
            return
        }
        //let out : String = runSynchronousShellWithUserConfig(cmd: "open -a Terminal " + currentViewController.directory) ?? ""
        if let url = URL(string: currentViewController.url) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func newTerminalAtFolderClicked(_ sender: Any) {
        guard let currentViewController = NSApp.mainWindow?.contentViewController as? ViewController else {
            return
        }
        //let out : String = runSynchronousShellWithUserConfig(cmd: "open -a Terminal " + currentViewController.directory) ?? ""
        _ = runSynchronousShell(launchPath: "/usr/bin/open", args: "-a", "Terminal", currentViewController.directory.replacingOccurrences(of: "\\ ", with: " ")) ?? ""
    }
    
    @IBAction func openFolderInFinderClicked(_ sender: Any) {
        guard let currentViewController = NSApp.mainWindow?.contentViewController as? ViewController else {
            return
        }
        //let out : String = runSynchronousShellWithUserConfig(cmd: "open " + currentViewController.directory) ?? ""
        _ = runSynchronousShell(launchPath: "/usr/bin/open", args: currentViewController.directory.replacingOccurrences(of: "\\ ", with: " ")) ?? ""
    }
    
    @IBAction func showConsoleClicked(_ sender: Any) {
        guard let currentViewController = NSApp.mainWindow?.contentViewController as? ViewController else {
            guard let currentViewController = NSApp.mainWindow?.contentViewController as? ConsoleViewController else {
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
        
        let newWindowController = storyBoard.instantiateController(withIdentifier: "console") as! NSWindowController
        guard let consoleViewController = newWindowController.contentViewController as? ConsoleViewController else {
            return
        }
        consoleViewController.delegate = currentViewController
        currentViewController.consoleDataDelegate = consoleViewController
        newWindowController.showWindow(self)
    }
    
    @IBAction func restartClicked(_ sender: Any) {
        func restartFromConsoleWindow() {
            guard let currentViewController = NSApp.mainWindow?.contentViewController as? ConsoleViewController else {
                return
            }
            let viewController : ViewController = (currentViewController.delegate?.getViewController())!
            viewController.consoleController?.kill()
            viewController.startJupyterServer()
        }
        
        guard let currentViewController = NSApp.mainWindow?.contentViewController as? ViewController else {
            return restartFromConsoleWindow()
        }
        currentViewController.consoleController?.kill()
        currentViewController.startJupyterServer()
    }
    
    @IBAction func terminateClicked(_ sender: Any) {
        func terminateFromConsoleWindow() {
            guard let currentViewController = NSApp.mainWindow?.contentViewController as? ConsoleViewController else {
                return
            }
            currentViewController.delegate?.getViewController().consoleController?.kill()
        }
        
        guard let currentViewController = NSApp.mainWindow?.contentViewController as? ViewController else {
            return terminateFromConsoleWindow()
        }
        currentViewController.consoleController?.kill()
    }
    
    @IBAction func newFileClicked(_ sender: Any) {
        guard let window : WindowController = NSApp.mainWindow?.windowController as? WindowController else {
            let windowController : WindowController = storyBoard.instantiateController(withIdentifier: "jupyter") as! WindowController
            windowController.window?.windowController = jupyterWindowController
            windowController.window?.makeKeyAndOrderFront(self)
            return
        }
        window.newWindowForTab(self)
    }
    
    func openWindow(name : String) -> NSWindowController {
        let windowController : NSWindowController = storyBoard.instantiateController(withIdentifier: name) as! NSWindowController
        windowController.showWindow(self)
        return windowController
    }
    
    func openNewJupyterWindow(url : NSURL, dropFile : Bool = false) {
        Preferences.shared.didStartFromContextAction = true
        guard let path = url.path else {
                return
        }
            
        let attributes = try! FileManager.default.attributesOfItem(atPath: path)
        let type = attributes[FileAttributeKey.type] as? FileAttributeType
        if (!(type == FileAttributeType.typeDirectory)) {
            Preferences.shared.fileNameForContextAction = dropFile ? "" : (url.lastPathComponent ?? "")
            Preferences.shared.folderPathForContextAction = url.deletingLastPathComponent?.path.replacingOccurrences(of: " ", with: "\\ ") ?? ""
        }
        else {
            Preferences.shared.folderPathForContextAction = url.path?.replacingOccurrences(of: " ", with: "\\ ") ?? ""
        }
        
        let windowController : WindowController = storyBoard.instantiateController(withIdentifier: "jupyter") as! WindowController
        windowController.window?.windowController = jupyterWindowController
        windowController.window?.makeKeyAndOrderFront(self)
    }
    
    @objc func openFromContextWithURL(_ pboard: NSPasteboard, userData:String, error: NSErrorPointer) {
        if let url = NSURL(from: pboard) {
            openNewJupyterWindow(url: url, dropFile: true)
        }
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for file in filenames {
            openNewJupyterWindow(url: NSURL(fileURLWithPath: file))
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSApp.servicesProvider = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        Preferences.shared.willTerminate()
        print("App termination")
    }
}

