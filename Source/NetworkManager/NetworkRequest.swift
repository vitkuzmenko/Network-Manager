//
//  NetworkRequest.swift
//  Network Manager
//
//  Created by Vitaliy Kuzmenko on 18/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation
import Alamofire

open class NetworkRequest {
    
    var _request: Request
    
    var request: URLRequest? {
        return _request.request
    }
    
    init(_request: DataRequest) {
        self._request = _request
    }
    
    open func cancel() {
        _request.cancel()
    }
    
}
