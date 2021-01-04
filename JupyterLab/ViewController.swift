//
//  ViewController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 09.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa
import WebKit

var baseURL : String = Preferences.shared.serverIP
var basePort : Int = Preferences.shared.serverPort - 1

protocol ConsoleDelegate : class  {
    func getConsoleController() -> ConsoleController
    func consoleWillDisappear() -> Void
    func getTruncatedPath(count : Int) -> String
    func getViewController() -> ViewController
}

class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, ConsoleDelegate {
    @IBOutlet weak var webView: WKWebView!
    var timer : Timer = Timer()
    var websiteController : WebsiteController = WebsiteController()
    var consoleController : ConsoleController?
    var directory : String = ""
    var file : String = ""
    var app : String = "lab"
    var isRunning : Bool = false
    
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
    
    func populateWebView() -> Void {
        DispatchQueue.main.async {
            var url : String = ""
            if (self.app == "lab") {
                url = self.websiteController.baseURL + ":" + String(self.websiteController.port) + (self.file == "" ? "" : ("/tree/" + self.file.replacingOccurrences(of: " ", with: "%20"))) + "?token=" + self.websiteController.token
            }
            else if (self.app == "notebook") {
                url = self.websiteController.baseURL + ":" + String(self.websiteController.port) + "/notebooks/" + self.file.replacingOccurrences(of: " ", with: "%20")
            }
            
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
                return result.path.replacingOccurrences(of: " ", with: "\\ ")
            }
        }
        return ""
    }
    
    func startJupyterServer() {
        if (!Preferences.shared.disableJupyterServer) {
            consoleController = ConsoleController(_viewController: self)
            consoleController?.runWithUserConfig(cmd: jupyterCommand())
        }
        setupTimer()
        isRunning = true
    }
    
    func jupyterCommand() -> String {
        basePort += 1
        let auth_token : String = randomString(length: 30)
        websiteController = WebsiteController(_viewController: self, _baseURL: baseURL, _port: basePort, _token: auth_token)

        if (Preferences.shared.useNotebooks) {
            app = "notebook"
        }
        
        return "jupyter " + app
                + " --port=" + String(basePort)
                + " --port-retries=0"
                + " --NotebookApp.token=" + auth_token
                + " --NotebookApp.open_browser=False"
                + " --NotebookApp.notebook_dir=" + directory
                + " " + Preferences.shared.customFlags
    }
    
    func setupWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        // for _blank target or non-mainFrame target
        webView.load(navigationAction.request)
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupWebView()
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
        
        if (isRunning) { return }
        
        if (Preferences.shared.didStartFromContextAction) {
            directory = Preferences.shared.folderPathForContextAction
            file = Preferences.shared.fileNameForContextAction
            Preferences.shared.didStartFromContextAction = false
        }
        else {
            directory = displayFolderPicker()
        }
        if (directory == "") { directory = "~" }
        startJupyterServer()
        changeTitle()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if (Preferences.shared.terminate) {
            print("Disappear kill")
            consoleController?.kill()
        }
    }
    
    deinit {
        print("ViewController deinit")
        consoleController?.kill()
    }
}

