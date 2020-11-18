//
//  ViewController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 09.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa
import WebKit

var baseURL : String = "http://127.0.0.1"//Preferences.shared.serverIP
var basePort : Int = 8887//Preferences.shared.serverPort - 1

protocol ConsoleDelegate : class  {
    func getConsoleController() -> ConsoleController
    func consoleWillDisappear() -> Void
    func getTruncatedPath(count : Int) -> String
    func getViewController() -> ViewController
}

class ViewController: NSViewController, WKUIDelegate, ConsoleDelegate {
    @IBOutlet weak var webView: WKWebView!
    var timer : Timer = Timer()
    var websiteController : WebsiteController = WebsiteController()
    var consoleController : ConsoleController?
    var directory : String = ""
    var file : String = ""
    
    weak var consoleDataDelegate : ConsoleDataDelegate?
    
    func getViewController() -> ViewController {
        return self
    }
    
    func getConsoleController() -> ConsoleController {
        return consoleController!
    }
    
    func consoleWillDisappear() {
        consoleDataDelegate = nil
    }
    
    func setupView() -> Void {
        view.setFrameSize(NSSize(width: 1024, height: 1024))
        self.view.window?.tabbingMode = .preferred
    }
    
    func populateWebView(url : String) -> Void {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string:url)!))
            self.timer.invalidate()
        }
    }
    
    func timerTick(timer : Timer) -> Void {
        websiteController.pingHost()
    }
    
    func setupTimer() -> Void {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: timerTick(timer:))
        timer.fire()
    }
    
    func displayFolderPicker() -> String {
        let dialog = NSOpenPanel();

        dialog.title = "Choose jupyter directory";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseFiles = true;
        dialog.canChooseDirectories = true;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                //if (result.isFileURL) {
                //    file = result.lastPathComponent
                //   return result.deletingLastPathComponent().path.replacingOccurrences(of: " ", with: "\\ ")
                //}
                return result.path.replacingOccurrences(of: " ", with: "\\ ")
            }
        }
        return ""
    }
    
    func startJupyterServer() {
        consoleController = ConsoleController(_viewController: self)
        basePort += 1
        let auth_token : String = randomString(length: 30)
        websiteController = WebsiteController(_viewController: self, _baseURL: baseURL, _port: basePort, _token: auth_token)
        //consoleController?.run(cmd: "/Users/felix/anaconda3/bin/jupyter", args: "lab", "--port=" + String(basePort), "--port-retries=0", "--NotebookApp.token=" + auth_token, "--NotebookApp.open_browser=false", "--NotebookApp.notebook_dir=" + directory)
        
        var app : String = "lab"
        //if (file != "") {
        //    app = "notebook"
        //}
        
        consoleController?.runWithUserConfig(cmd: "jupyter " + app + " --port=" + String(basePort) + " --port-retries=0 --NotebookApp.token="
                                                  + auth_token + " --NotebookApp.open_browser=false --NotebookApp.notebook_dir=" + directory)
        setupTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        directory = displayFolderPicker()
        if (directory == "") { directory = "~" }
        setupView()
        startJupyterServer()
    }
    
    func changeTitle() {
        let truncatedPath : String = getTruncatedPath()
        self.view.window?.title = "JupyterLab - " + truncatedPath
    }
    
    func getTruncatedPath(count : Int = 3) -> String {
        var substr : [Substring] = directory.split(separator: "/").reversed()
        var dropped : Bool = false
        while substr.count > count {
            substr = substr.dropLast()
            dropped = true
        }
        substr = substr.reversed()
        return ((dropped ? ".../" : "/") + (substr.joined(separator: "/")))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        changeTitle()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        consoleController?.kill()
    }
}

