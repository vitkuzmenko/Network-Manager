//
//  Response.swift
//  Currencier
//
//  Created by Vitaliy Kuzmenko on 08/07/16.
//  Copyright © 2016 KuzmenkoFamily. All rights reserved.
//

import ObjectMapper

open class Response: NSObject {
    
    var URLRequest: URLRequest?
    
    var URLResponse: URLResponse?
    
    var JSON: Any?
    
    var error: AppError?
    
    var statusCode: Int = 0
    
    var success: Bool {
        return error == nil && (statusCode == 200 || statusCode == 201)
    }
    
    init(URLRequest: URLRequest?, response: URLResponse?) {
        super.init()
        
        self.URLRequest = URLRequest
        self.URLResponse = response
    }
    
    func map<T: MappableModel>(path: String? = nil) -> T? {
        if let path = path {
            let dict = JSON as? [String: Any]
            return Mapper<T>().map(JSONObject: dict?[path])
        } else {
            return Mapper<T>().map(JSONObject: JSON)
        }
    }
    
    func mapArray<T: MappableModel>(path: String? = nil) -> [T]? {
        if let path = path {
            let dict = JSON as? [String: Any]
            return Mapper<T>().mapArray(JSONObject: dict?[path])
        } else {
            return Mapper<T>().mapArray(JSONObject: JSON)
        }
    }
    
}
