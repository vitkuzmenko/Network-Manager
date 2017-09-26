//
//  DictionarySerializer.swift
//  Locals
//
//  Created by Vitaliy Kuzmenko on 02/08/16.
//  Copyright © 2016 Locals. All rights reserved.
//

import Foundation

extension String {
    
    var URLEncode: String {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "_.-~")
        return addingPercentEncoding(withAllowedCharacters: set) ?? self
    }
    
} 


open class DictionarySerializer {
    
    var dict: [String: Any]
    
    public init(dict: [String: Any]) {
        self.dict = dict
    }
    
    open func getParametersInFormEncodedString() -> String {
        return serialize(dict: dict)
    }
    
    open func serialize(dict: [String: Any], nested: String? = nil) -> String {
        
        var strings: [String] = []
        
        for (key, value) in dict {
            
            var string = key
            
            if let nested = nested {
                string = String(format: "%@[%@]", nested, key)
            }
            
            string = serialize(value: value, withString: string, nested: nested)
            strings.append(string)
        }
        
        return strings.joined(separator: "&")
    }
    
    open func serialize(array: [Any], nested: String? = nil) -> String {
        
        var strings: [String] = []
        
        for value in array {
            var string = ""
            
            if let nested = nested {
                string = String(format: "%@[]", nested)
            }
            
            string = serialize(value: value, withString: string, nested: nested)
            strings.append(string)
        }
        
        return strings.joined(separator: "&")
    }
    
    open func serialize(value: Any, withString string: String, nested: String? = nil) -> String {
        var string = string
        
        if let value = value as? String {
            string = String(format: "%@=%@", string, value.URLEncode)
        } else if let value = value as? NSNumber {
            string = String(format: "%@=%@", string, value.stringValue.URLEncode)
        } else if let value = value as? [String: Any] {
            string = serialize(dict: value, nested: string)
        } else if let value = value as? [Any] {
            string = serialize(array: value, nested: string)
        }
        
        return string
    }
    
}

