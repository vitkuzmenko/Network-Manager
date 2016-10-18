//
//  Error.swift
//  Currencier
//
//  Created by Vitaliy Kuzmenko on 08/07/16.
//  Copyright © 2016 KuzmenkoFamily. All rights reserved.
//

import Foundation

open class ResponseError: Error {
    
    public enum ViewType: String {
        case error, warning, info
    }
    
    open var errorCode: String = ""
    
    open var localizedDescription: String = ""
    
    open var errorType: ViewType = .error
    
    open var request: URLRequest?
    
    public init(errorCode: String, localizedDescription: String = "", errorType: ViewType = .error) {
        self.errorCode = errorCode
        self.localizedDescription = localizedDescription.isEmpty ? NSLocalizedString(errorCode, comment: "") : localizedDescription
        self.errorType = errorType
    }
    
    open var description: String {
        return String(format: "Error: %@ Description: %@", errorCode, localizedDescription)
    }
    
}
