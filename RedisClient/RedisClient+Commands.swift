//
//  RedisClient+Commands.swift
//  RedisClient
//
//  Created by Christian Lobach on 10.06.14.
//  Copyright (c) 2014 Christian Lobach. All rights reserved.
//

import Foundation

protocol Commands {
 
    func PING()
    
}


extension RedisClient : Commands {
    
    func PING() {
        self.executeCommand(self.respStringForRedisCommand("PING"))
    }
    
}