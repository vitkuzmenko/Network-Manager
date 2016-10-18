//
//  Response.swift
//  Currencier
//
//  Created by Vitaliy Kuzmenko on 08/07/16.
//  Copyright © 2016 KuzmenkoFamily. All rights reserved.
//

import ObjectMapper

open class Response: NSObject {
    
    open var URLRequest: URLRequest?
    
    open var URLResponse: URLResponse?
    
    open var JSON: Any?
    
    open var error: ResponseError?
    
    open var statusCode: Int = 0
    
    open var success: Bool {
        return error == nil && (statusCode == 200 || statusCode == 201)
    }
    
    public init(URLRequest: URLRequest?, response: URLResponse?) {
        super.init()
        
        self.URLRequest = URLRequest
        self.URLResponse = response
    }
    
    open func map<T: MappableModel>(path: String? = nil) -> T? {
        if let path = path {
            let dict = JSON as? [String: Any]
            return Mapper<T>().map(JSONObject: dict?[path])
        } else {
            return Mapper<T>().map(JSONObject: JSON)
        }
    }
    
    open func mapArray<T: MappableModel>(path: String? = nil) -> [T]? {
        if let path = path {
            let dict = JSON as? [String: Any]
            return Mapper<T>().mapArray(JSONObject: dict?[path])
        } else {
            return Mapper<T>().mapArray(JSONObject: JSON)
        }
    }
    
}
