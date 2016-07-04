//
//  Logger.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import Foundation

private enum LoggerStatus : String {
    case Info = "Info: "
    case Success = "Success: "
    case Error = "Error: "
}

class Logger {
    
    private func log(withLog log: String, status: LoggerStatus) {
        print(status.rawValue + log)
    }
    
    func info(withLog log: String) {
        self.log(withLog: log, status: .Info)
    }
    
    func success(withLog log: String) {
        self.log(withLog: log, status: .Success)
    }
    
    func error(withLog log: String) {
        self.log(withLog: log, status: .Error)
    }
}
