//
//  Logger.swift
//  Patchwire-iOS
//
//  Created by Victor Noel Barrera on 7/3/16.
//  Copyright © 2016 Victor Barrera. All rights reserved.
//

import UIKit

private enum LoggerStatus : String {
    case Info = "Info: "
    case Success = "Success: "
    case Error = "Error: "
}

class Logger: NSObject {
    
    private static func log(withLog log: String, status: LoggerStatus) {
        print(status.rawValue + log)
    }
    
    static func info(withLog log: String) {
        Logger.log(withLog: log, status: .Info)
    }
    
    static func success(withLog log: String) {
        Logger.log(withLog: log, status: .Success)
    }
    
    static func error(withLog log: String) {
        Logger.log(withLog: log, status: .Error)
    }
}
