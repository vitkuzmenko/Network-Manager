//
//  Response.swift
//  Currencier
//
//  Created by Vitaliy Kuzmenko on 08/07/16.
//  Copyright © 2016 KuzmenkoFamily. All rights reserved.
//

import Alamofire
import ObjectMapper

open class NetworkResponse: NSObject {
    
    open var urlRequest: URLRequest?
    
    open var urlResponse: HTTPURLResponse?
    
    open var value: Any?
    
    open var error: Error?
    
    open var statusCode: Int { return urlResponse?.statusCode ?? 0 }

    public init(dataResponse: DataResponse<Any>) {
        super.init()
        
        self.urlRequest = dataResponse.request
        self.urlResponse = dataResponse.response
        self.value = dataResponse.result.value
        self.error = dataResponse.error
    }
    
}
