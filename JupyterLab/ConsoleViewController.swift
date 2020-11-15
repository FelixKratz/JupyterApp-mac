//
//  ConsoleViewController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 14.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa

protocol ConsoleDataDelegate : class {
    func updateConsoleData() -> Void
    func getViewController() -> ConsoleViewController
}

class ConsoleViewController : NSViewController, ConsoleDataDelegate {
    weak var delegate : ConsoleDelegate?

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    
    func getViewController() -> ConsoleViewController {
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setFrameSize(NSSize(width: 720, height: 480))
        textView.font = NSFont.init(name: "Andale Mono", size: 15)
    }
    
    override func viewDidAppear() {
        updateConsoleData()
        let path : String = delegate?.getTruncatedPath(count: 3) ?? "Error"
        self.view.window?.title = "Console - " + path
    }
    
    func updateConsoleData() {
        textView.string = delegate?.getConsoleController().formattedOutput ?? "Nope"
        scrollView.contentView.documentView?.scrollToEndOfDocument(nil)
    }
    
    override func viewWillDisappear() {
        delegate?.consoleWillDisappear()
    }
}
