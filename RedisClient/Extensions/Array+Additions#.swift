//
//  Array+Additions#.swift
//  RedisClient
//
//  Created by Christian Lobach on 10.06.14.
//  Copyright (c) 2014 Christian Lobach. All rights reserved.
//

import Foundation

extension Array {
    
    func componentsJoinedByString(separator: String) -> String {
        
        var concatenatedString = ""

        let lastObject: String = self[self.count - 1] as String
        
        for component in self {
            
            let stringComponent: String = component as String
            
            concatenatedString += stringComponent
            
            if stringComponent != lastObject {
                concatenatedString += separator
            }
         
        }
        
        return concatenatedString
    }
    
}