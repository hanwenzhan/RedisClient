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
    
    var inputStream: NSInputStream?;
    var outputStream: NSOutputStream?;
    
    func connect(host: String = "127.0.0.1", port: Int = 6379) -> (Bool, NSError?) {
        
        var error: NSError?
        
        NSStream.getStreamsToHostWithName(host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        if let inputStream = self.inputStream {
            inputStream.delegate = self
            inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            inputStream.open()
        } else {
            error = NSError.errorWithDomain(RedisClientErrorDomain, code: RedisClientErrorCode.inputStreamCreationFailed.toRaw(), userInfo: nil)
            return (false, error)
        }
        
        if let outputStream = self.outputStream {
            outputStream.delegate = self
            outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            outputStream.open()
        } else {
            error = NSError.errorWithDomain(RedisClientErrorDomain, code: RedisClientErrorCode.outputStreamCreationFailed.toRaw(), userInfo: nil)
            return (false, error)
        }

        return (true, nil)        
    }

    func disconnect() {
        if let inputStream = self.inputStream {
            inputStream.close()
        }
        if let outputStream = self.outputStream {
            outputStream.close()
        }
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
    
    func executeCommand(respArray: String) {

        var cString = respArray.nulTerminatedUTF8
        
        if let outputStream = self.outputStream {
            outputStream.write(cString, maxLength: countElements(respArray))
        }
        
    }
    
    // MARK: - NSStreamDelegate
    
    func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent) {
        
        println(eventCode.toRaw())
        
        if eventCode == .ErrorOccurred {
            let error = aStream.streamError
            println(error.localizedDescription)
        }
        
    }
            
}