//
//  RedisConnection.swift
//  RedisClient
//
//  Created by Christian Lobach on 11.06.14.
//  Copyright (c) 2014 Christian Lobach. All rights reserved.
//

import Foundation

class RedisConnection : NSObject, NSStreamDelegate {

    var host: String
    var port: Int
    
    var onConnectionEnd: ((Void) -> (Void))?

    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?

    var command: String?
    
    var dataSent = false
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func executeCommand(respArray: String) {
        self.command = respArray
        connect()
    }

    func sendData() {
        dataSent = true
        let cString = self.command!.nulTerminatedUTF8
        let length = countElements(self.command!)
        if let outputStream = self.outputStream {
            outputStream.write(cString, maxLength: length)
        }
    }
    
    // MARK: - Connect and Disconnect
    
    func connect() -> (Bool, NSError?) {
        
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
            inputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
        if let outputStream = self.outputStream {
            outputStream.close()
            outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
        
        if let closed = self.onConnectionEnd {
            closed()
        }
        
    }

    // MARK: - NSStreamDelegate
    
    func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent) {

        if aStream == self.inputStream {
            
            switch eventCode {
            case NSStreamEvent.HasBytesAvailable:
                // TODO: parse
                println()
            
            case NSStreamEvent.ErrorOccurred:
                let error = aStream.streamError
                println(error.localizedDescription)
                disconnect();
            case NSStreamEvent.EndEncountered:
                disconnect();
                
            default:
                return
            }
        } else if aStream == self.outputStream {
            switch eventCode {
            case NSStreamEvent.HasSpaceAvailable:
                if (!dataSent) {
                    sendData()
                }
                
            case NSStreamEvent.ErrorOccurred:
                let error = aStream.streamError
                println(error.localizedDescription)
                disconnect();
            default:
                return
            }
        }
        
    }

}