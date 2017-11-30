//
//  MappableModel.swift
//  Currencier
//
//  Created by Vitaliy Kuzmenko on 08/07/16.
//  Copyright © 2016 KuzmenkoFamily. All rights reserved.
//

import ObjectMapper
import Alamofire
//import NetworkManager

public protocol IdentifierHolder {
    var id: Int { get set }
}

extension Array where Element : IdentifierHolder {
    
    public func object(with id: Int) -> Element? {
        return filter({ (object) -> Bool in
            return object.id == id
        }).first
    }
    
    public var ids: [Int] {
        var ids = [Int]()
        for item in self {
            ids.append(item.id)
        }
        return ids
    }
    
    public var idsString: [String] {
        var ids = [String]()
        for item in self {
            ids.append(String(item.id))
        }
        return ids
    }
    
}


public func ==(l: MappableModel, r: MappableModel) -> Bool {
    return l.isEqualTo(object: r)
}

open class MappableModel: Mappable, CustomStringConvertible, IdentifierHolder, Equatable, Hashable {
    
    public var id: Int = 0
    
    open var hashValue: Int {
        return id
    }
    
    public init() { }
    
    public var description: String {
        return "\n" + Mapper().toJSONString(self, prettyPrint: true)! + "\n"
    }
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    open func mapping(map: Map) {
        id <- map["id"]
    }
    
    open func isEqualTo(object: MappableModel) -> Bool {
        if id == 0 || object.id == 0 {
            return false
        } else {
            return id == object.id
        }
    }
    
    open func mapping(object: MappableModel) {
        let json = object.toJSON()
        let map = Map(mappingType: .fromJSON, JSON: json)
        mapping(map: map)
    }
    
}

extension Response {
    
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

extension NetworkManager {
    
    @discardableResult public class func simpleRequest<T: MappableModel>(_ url: String, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, mapArrayPath: String? = nil, complete: (([T]?, ResponseError?) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody) { respose in
            complete?(respose.mapArray(path: mapArrayPath), respose.error)
        }
    }
    
    @discardableResult public class func simpleRequest<T: MappableModel>(_ url: String, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, complete: ((T?, ResponseError?) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody) { respose in
            complete?(respose.map(), respose.error)
        }
    }
    
    @discardableResult public class func simpleRequest(_ url: String, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, complete: ((ResponseError?) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody) { respose in
            complete?(respose.error)
        }
    }
    
    @discardableResult public class func simpleRequest<T: MappableModel>(_ url: URL, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, mapArrayPath: String? = nil, complete: (([T]?, ResponseError?) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url.absoluteString, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody) { respose in
            complete?(respose.mapArray(path: mapArrayPath), respose.error)
        }
    }
    
    @discardableResult public class func simpleRequest<T: MappableModel>(_ url: URL, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, complete: ((T?, ResponseError?) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url.absoluteString, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody) { respose in
            complete?(respose.map(), respose.error)
        }
    }
    
    @discardableResult public class func simpleRequest(_ url: URL, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, complete: ((ResponseError?) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url.absoluteString, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody) { respose in
            complete?(respose.error)
        }
    }
    
}

