//
//  ISO8601CustomDateTransform.swift
//  Network Manager
//
//  Created by Vitaliy Kuzmenko on 24/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 *  @brief  Transform ISO860 date value to NSDate
 */
open class ISO8601CustomDateTransform: DateFormatterTransform {
    
    public init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ"
        
        super.init(dateFormatter: formatter)
    }
    
}
