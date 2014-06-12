//
//  RedisClient+Commands.swift
//  RedisClient
//
//  Created by Christian Lobach on 10.06.14.
//  Copyright (c) 2014 Christian Lobach. All rights reserved.
//

import Foundation

typealias SimpleStringCallback = ((String?) -> (Void))

extension RedisClient {
    
    func PING(callback: SimpleStringCallback? = nil) {
        redisCommand("PING", callback:callback)
    }
    
}