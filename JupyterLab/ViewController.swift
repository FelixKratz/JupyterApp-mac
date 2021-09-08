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

protocol ConsoleDelegate : AnyObject  {
    func getConsoleController() -> ConsoleController
    func consoleWillDisappear() -> Void
    func getTruncatedPath(count : Int) -> String
    func getViewController() -> ViewController
}

/*
 I took this function from https://stackoverflow.com/a/49728137 but changed the adress to 127.0.0.1 so
 the firewall doesn't ask if you want the application to accept incoming network connections.
 */
func checkTcpPortForListen(port: in_port_t) -> Bool {
    let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
    if socketFileDescriptor == -1 {
        return false
    }

    var addr = sockaddr_in()
    let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
    addr.sin_len = __uint8_t(sizeOfSockkAddr)
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
    addr.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
    addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
    var bind_addr = sockaddr()
    memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))

    if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
        release(socket: socketFileDescriptor)
        return false
    }
    if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
        release(socket: socketFileDescriptor)
        return false
    }
    release(socket: socketFileDescriptor)
    return true
}

func release(socket: Int32) {
    Darwin.shutdown(socket, SHUT_RDWR)
    close(socket)
}

class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, ConsoleDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var timer : Timer = Timer()
    var websiteController : WebsiteController = WebsiteController()
    var consoleController : ConsoleController?
    var directory : String = ""
    var file : String = ""
    var app : String = "lab"
    var isRunning : Bool = false
    var url : String = ""
    var documentController: NSDocumentController = NSDocumentController();
    
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
            if (self.app == "lab") {
                self.url = self.websiteController.baseURL + ":" + String(self.websiteController.port)  + "?token=" + self.websiteController.token
            }
            else if (self.app == "notebook") {
                self.url = self.websiteController.baseURL + ":" + String(self.websiteController.port) + "/notebooks/" + self.file.replacingOccurrences(of: " ", with: "%20") + "?token=" + self.websiteController.token
            }
            
            self.webView.load(URLRequest(url: URL(string:self.url)!))
            self.progressIndicator.stopAnimation(nil)
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
        dialog.canChooseFiles = false;
        dialog.canChooseDirectories = true;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                documentController.noteNewRecentDocumentURL(result)
                return result.path
            }
        }
        return ""
    }
    
    func startJupyterServer() {
        if (!Preferences.shared.disableJupyterServer) {
            consoleController = ConsoleController(_viewController: self)
            consoleController?.runWithUserConfig(cmd: jupyterCommand())
        }
        progressIndicator.startAnimation(nil)
        setupTimer()
        isRunning = true
    }
    
    func jupyterCommand() -> String {
        var port = Preferences.shared.serverPort
        
        while (!checkTcpPortForListen(port: in_port_t(port))) {
            port += 1;
        }
        
        let auth_token : String = randomString(length: 30)
        websiteController = WebsiteController(_viewController: self, _baseURL: baseURL, _port: port, _token: auth_token)

        if (Preferences.shared.useNotebooksOnFolder && file == "" || (file != "" && Preferences.shared.useNotebooksOnFile)) {
            app = "notebook"
        }
        
        return "jupyter " + app
                + " --LabApp.port=" + String(port)
                + " --NotebookApp.port=" + String(port)
                + " --LabApp.port_retries=0"
                + " --NotebookApp.port_retries=0"
                + " --LabApp.token=" + auth_token
                + " --NotebookApp.token=" + auth_token
                + " --LabApp.open_browser=False"
                + " --NotebookApp.open_browser=False"
                + " --LabApp.notebook_dir=\"" + directory + "\""
                + " --NotebookApp.notebook_dir=\"" + directory + "\""
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
        let truncatedPath : String = getTruncatedPath(count: (file == "") ? 3 : 2)
        self.view.window?.title = app + " - " + truncatedPath + "/" + file
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
            Preferences.shared.resetContextAction()
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

