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
    
    var onResponse: ((String?) -> (Void))?
    var onConnectionEnd: ((Void) -> (Void))?

    // private
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?

    var data = NSMutableData()
    
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

    func rawResponse() -> NSString? {
        if let copiedData = self.data.copy() as? NSData {
            let encoding = NSString.stringEncodingForData(copiedData, encodingOptions: nil, convertedString: nil, usedLossyConversion: nil)
            let response :NSString? = NSString(data: copiedData, encoding: encoding)
            return response
        }
        
        return nil
    }
    
    func parsedResponse() -> String? {
        
        if let rawResponse = rawResponse() {
            if rawResponse.substringToIndex(1) == "+" {
                return rawResponse.substringWithRange(NSRange(location:1, length:rawResponse.length - 3))
            }
        }

        return nil
    }
    
    // MARK: - NSStreamDelegate
    
    func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent) {

        if aStream == self.inputStream {
            
            switch eventCode {
            case NSStreamEvent.HasBytesAvailable:

                var buf = Array<UInt8>(count:1024, repeatedValue: 0)

                var len = 0;
                len = self.inputStream!.read(&buf, maxLength: 1024)
                if len > 0 {
                    data.appendBytes(buf, length: len)
                }
                
                if len < 1024 {
                    if let response = parsedResponse() {
                        if let callback = onResponse {
                            callback(response)
                        }
                    }
                }
                
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