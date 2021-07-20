//
//  ConsoleController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 13.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Foundation

func runSynchronousShellWithUserConfig(cmd: String) -> String? {
    let task = Process()

    let pipe = Pipe()
    task.standardOutput = pipe
    task.currentDirectoryPath = "/"
    task.launchPath = "/usr/bin/env"
    task.arguments = ["bash", "-i", "-l", "-c", cmd]
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output
}

func runSynchronousShell(launchPath: String, args : String...) -> String? {
    let task = Process()

    let pipe = Pipe()
    task.standardOutput = pipe
    task.currentDirectoryPath = "/"
    task.launchPath = launchPath
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output
}


class ConsoleController {
    
    private let task : Process
    private let outPipe : Pipe
    private let inPipe : Pipe
    private let errPipe : Pipe
    
    private let outputHandle : FileHandle
    private let errorHandle : FileHandle
    private let inputHandle : FileHandle
    
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    weak var viewController : ViewController?
    var output : String = ""
    var formattedOutput : String = ""
    
    init(_viewController : ViewController?) {
        viewController = _viewController
        
        task = Process()
        outPipe = Pipe()
        outputHandle = outPipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        
        inPipe = Pipe()
        inputHandle = inPipe.fileHandleForWriting
        
        errPipe = Pipe()
        errorHandle = errPipe.fileHandleForReading
        
        task.standardOutput = outPipe
        task.standardInput = inPipe
        task.standardError = outPipe
        
        dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandle, queue: nil) {  notification in
            let data = self.outputHandle.availableData
            guard data.count > 0 else {
                self.notificationCenter.removeObserver(self.dataObserver!)
                return
            }
            if let line = String(data: data, encoding: .utf8) {
                self.output += line
            }
            if (self.viewController != nil) {
                self.viewController?.consoleDataDelegate?.updateConsoleData()
            }
            self.outputHandle.waitForDataInBackgroundAndNotify()
            self.formatOutput()
        }
    }
    
    func run(cmd : String, args : String...) {
        task.launchPath = cmd
        task.arguments = args
        task.launch()
    }
    
    func formatOutput() {
        if (output == "") { return }
        
        output = yeetBackspaces(string: output)
        output = yeetLines(string: output)
        
        formattedOutput += output
        output = ""
    }
    
    func yeetBackspaces(string : String) -> String {
        var newString = string
        let target : Character = "\u{8}"
        if (!string.contains(target)) { return string }
        
        if (string.first == target) {
            formattedOutput = String(formattedOutput.dropLast())
            return String(string.dropFirst())
        }
        
        guard let index = string.firstIndex(of: target) else { return string }
        let prevIndex = string.index(before: index)
        
        newString.remove(at: index)
        newString.remove(at: prevIndex)
        
        return yeetBackspaces(string: newString)
    }
    
    func yeetLines(string : String) -> String {
        var newString = string
        let target : Character = "\r"
        if (!string.contains(target)) { return string }
        
        while true {
            if (newString.first == target) {
                if (formattedOutput.contains("\n")) {
                    if formattedOutput.last != "\n" {
                        formattedOutput = String(formattedOutput.dropLast())
                        continue
                    }
                    else { break }
                }
                else {
                    formattedOutput = ""
                    break
                }
            }
            
            guard let index = newString.firstIndex(of: target) else { return newString }
            
            if (newString[newString.index(before: index)] == "\n") {
                break
            }
            newString.remove(at: newString.index(before: index))
        }
        
        guard let index = newString.firstIndex(of: target) else { return newString }
        
        newString.remove(at: index)
        return yeetLines(string: newString)
    }
    
    func runWithUserConfig(cmd : String) {
        task.currentDirectoryPath = "/"
        run(cmd: "/usr/bin/env", args: "zsh", "-i", "-l", "-c", cmd)
    }
    
    func kill() {
        task.terminate()
    }
    
    deinit {
        print("ConsoleController deinit")
        kill()
    }
}
