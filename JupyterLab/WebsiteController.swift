//
//  WebsiteController.swift
//  JupyterLab
//
//  Created by Felix Kratz on 13.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Foundation
import WebKit

class WebsiteController {
    let baseURL : String
    var port : Int
    private let viewController : ViewController?
    let token : String
    
    init() {
        viewController = nil
        baseURL = ""
        port = 0
        token = ""
    }
    init(_viewController : (ViewController), _baseURL : String, _port : Int, _token : String) {
        viewController = _viewController
        baseURL = _baseURL
        port = _port
        token = _token
    }
    
    func completionHandler(_ : Data?, response : URLResponse?, error : Error?) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode == 200) {
                viewController?.populateWebView()
            }
        }
    }
    
    func pingHost() {
        let url = URL(string: baseURL + ":" + String(port))
        let task = URLSession.shared.dataTask(with: url!, completionHandler: self.completionHandler);
        task.resume()

    }
}
