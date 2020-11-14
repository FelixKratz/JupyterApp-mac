//
//  ViewController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 09.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa
import WebKit

var baseURL : String = "http://127.0.0.1"
var basePort : Int = 8887

class ViewController: NSViewController, WKUIDelegate {
    var populated : Bool = false
    @IBOutlet weak var webView: WKWebView!
    var timer : Timer = Timer()
    var outputTimer : Timer = Timer()
    var websiteController : WebsiteController = WebsiteController()
    var consoleController : ConsoleController = ConsoleController()
    var directory : String = ""
    
    func setupView() -> Void {
        view.setFrameSize(NSSize(width: 1024, height: 1024))
        self.view.window?.tabbingMode = .preferred
    }
    
    func populateWebView(url : String) -> Void {
        DispatchQueue.main.async {
            if (!self.populated) {
                self.webView.load(URLRequest(url: URL(string:url)!))
                self.populated = true
                self.timer.invalidate()
            }
        }
    }
    
    func timerTick(timer : Timer) -> Void {
        websiteController.pingHost()
    }
    
    func timerTickOutput(timer : Timer) -> Void {
        print(consoleController.output)
    }
    
    func setupTimer() -> Void {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: timerTick(timer:))
        outputTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(5), repeats: true, block: timerTickOutput(timer:))
        timer.fire()
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func displayFolderPicker() -> String {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose jupyter directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = false;
        dialog.canChooseDirectories = true;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                return result.path
            }
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basePort += 1
        let auth_token : String = randomString(length: 30)
        websiteController = WebsiteController(_viewController: self, _baseURL: baseURL, _port: basePort, _token: auth_token)
        self.setupView()
        self.setupTimer()
        
        directory = displayFolderPicker()
        
        consoleController.run(cmd: "/Users/felix/anaconda3/bin/jupyter", args: "lab", "--port=" + String(basePort), "--port-retries=0", "--NotebookApp.token=" + auth_token, "--NotebookApp.open_browser=false", "--NotebookApp.notebook_dir=" + directory)
        
    }
    
    override func viewDidAppear() {
        var substr : [Substring] = directory.split(separator: "/").reversed()
        var dropped : Bool = false
        while substr.count > 3 {
            substr = substr.dropLast()
            dropped = true
        }
        substr = substr.reversed()
        self.view.window?.title = "JupyterLab - " + (dropped ? ".../" : "/") + substr.joined(separator: "/")
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        consoleController.kill()
    }
}

