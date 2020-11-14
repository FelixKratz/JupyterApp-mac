//
//  ConsoleController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 13.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Foundation

class ConsoleController {
    private let task : Process
    private let outPipe : Pipe
    private let errPipe : Pipe
    private let inPipe : Pipe
    
    private let outputHandle : FileHandle
    private let inputHandle : FileHandle
    
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    
    var output : String = ""

    
    init() {
        task = Process()
        outPipe = Pipe()
        outputHandle = outPipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        task.standardOutput = outPipe
        inPipe = Pipe()
        inputHandle = inPipe.fileHandleForWriting
        task.standardInput = inPipe
        errPipe = Pipe()
        task.standardError = outPipe
        
        dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandle, queue: nil) {  notification in
            let data = self.outputHandle.availableData
            guard data.count > 0 else {
                self.notificationCenter.removeObserver(self.dataObserver!)
                return
            }
            if let line = String(data: data, encoding: .utf8) {
                self.output = self.output + line
            }
            self.outputHandle.waitForDataInBackgroundAndNotify()
        }
    }
    
    func run(cmd : String, args : String...) {
        /*var env = ProcessInfo.processInfo.environment
        var path : String = env["PATH"]! as String
        path = path + ":" + environment
        env["PATH"] = path
        task.environment = env*/
        task.launchPath = cmd
        task.arguments = args
        task.launch()
    }
    
    func kill() {
        task.terminate()
    }
    
    deinit {
        kill()
    }
}
