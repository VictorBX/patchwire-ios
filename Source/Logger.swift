//
//  Logger.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

class Logger {
    
    private enum Status : String {
        case info = "Info"
        case success = "Success"
        case error = "Error"
    }
    
    func info(message: String) {
        log(message: message, status: .info)
    }
    
    func success(message: String) {
        log(message: message, status: .success)
    }
    
    func error(message: String) {
        log(message: message, status: .error)
    }
    
    private func log(message: String, status: Status) {
        print(status.rawValue + ": " + message)
    }
}
