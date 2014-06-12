//
//  RedisClient.swift
//  RedisClient
//
//  Created by Christian Lobach on 10.06.14.
//  Copyright (c) 2014 Christian Lobach. All rights reserved.
//

import Foundation

let RedisClientErrorDomain = "RedisClientErrorDomain"

enum RedisClientErrorCode: Int {
    case inputStreamCreationFailed = 1
    case outputStreamCreationFailed
}

class RedisClient : NSObject, NSStreamDelegate {
    
    var host: String
    var port: Int
    
    var connections: RedisConnection[] = []
    
    init(host: String = "127.0.0.1", port: Int = 6379) {
        self.host = host
        self.port = port
    }
    
    // MARK: - Converting Redis commands to RESP strings

    func respStringForRedisCommand(redisCommand: String) -> String {
        let components = redisCommand.componentsSeparatedByString(" ") // this is fragile
        var bulkStrings: String[] = []
        for component in components {
            bulkStrings.append(self.bulkStringFromString(component))
        }
        
        let array = self.stringFromArrayOfBulkStrings(bulkStrings)
        return array
    }

    func stringFromArrayOfBulkStrings(bulkStrings: String[]) -> String {
        let count = bulkStrings.count
        
        let strings = bulkStrings.componentsJoinedByString("")
        let arrayString = "*\(count)\r\n\(strings)"
        return arrayString
    }
    
    func bulkStringFromString(inputString: String) -> String {
        let length = countElements(inputString)
        let bulkString = "$\(length)\r\n\(inputString)\r\n"
        return bulkString
    }
    
    // MARK: - Sending commands
    
    func redisCommand(command: String, callback: ((String?) -> Void)?) {
        
        let connection = RedisConnection(host: self.host, port: self.port)
        
        connection.onResponse = callback
        
        connection.onConnectionEnd = {
            var indexToRemove: Int?
            for (idx, c) in enumerate(self.connections) {
                if c == connection {
                    indexToRemove = idx
                }
            }
            if let i = indexToRemove {
                self.connections.removeAtIndex(i)
            }

        }
        
        connection.executeCommand(respStringForRedisCommand(command))
    }
    
}