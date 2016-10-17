//
//  Error.swift
//  Currencier
//
//  Created by Vitaliy Kuzmenko on 08/07/16.
//  Copyright © 2016 KuzmenkoFamily. All rights reserved.
//

import Foundation

open class AppError: Error {
    
    public enum ViewType: String {
        case Error, Warning, Info
    }
    
    open var error: NetworkManagerError?
    
    open var errorString: String?
    
    open var localizedDescription: String?
    
    open var errorType: ViewType?
    
    open var request: URLRequest?
    
    public init(error: String, localizedDescription: String = "", errorType: ViewType? = .Error) {
        self.errorString = error
        self.error = NetworkManagerError(rawValue: error)
        self.localizedDescription = localizedDescription.isEmpty ? NSLocalizedString(error, comment: "") : localizedDescription
        self.errorType = errorType
    }
    
    open var description: String {
        return String(format: "Error: %@ Description: %@", errorString!, localizedDescription!)
    }
    
}
