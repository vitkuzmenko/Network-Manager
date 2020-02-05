//
//  NetworkManager.swift
//  Locals
//
//  Created by Vitaliy Kuzmenko on 01/08/16.
//  Copyright © 2016 Locals. All rights reserved.
//

import ObjectMapper
import Alamofire
import Reachability

public class NetworkManager: NSObject {

    var reachability = try? Reachability()
    
    var isReachable: Bool { return reachability?.connection ?? .unavailable != .unavailable }
    
    let logRequest = true
    
    public var defaultEncoding: ParameterEncoding = URLEncoding.default
    
    public static let `default` = NetworkManager()
    
    public var authHttpHeaderFields: [String: String] = [:]
    
    public var logConfiguration: (url: Bool, headers: Bool, body: Bool) = (true, false, true)
    
    @discardableResult public class func request(_ url: URLConvertible, method: HTTPMethod = .get, parameters: [String: Any]? = nil, encoding: ParameterEncoding? = nil, httpHeaderFields: [String: String]? = nil, complete: ((NetworkResponse) -> Void)? = nil) -> DataRequest? {
        return NetworkManager.default.request(url, method: method, parameters: parameters, encoding: encoding, httpHeaderFields: httpHeaderFields, complete: complete)
    }
    
    public class func upload(_ url: URLConvertible, parameters: [String: Any]? = nil, files: [String: (name: String, data: Data, mime: String)]? = nil, httpHeaderFields: [String: String]? = nil, uploadProgress: ((Float) -> Void)? = nil, downloadProgress: ((Float) -> Void)? = nil, beginUploading: ((UploadRequest?, Error?) -> Void)? = nil, complete: ((NetworkResponse) -> Void)? = nil) {
        return NetworkManager.default.upload(url, parameters: parameters, files: files, httpHeaderFields: httpHeaderFields, uploadProgress: uploadProgress, downloadProgress: downloadProgress, beginUploading: beginUploading, complete: complete)
    }
    
    /**
     Perform request with error detection
     
     - parameter method:     HTTP Method
     - parameter url:        Request URL
     - parameter parameters: Request Body parameters
     - parameter complete:   completion closure
     */
    func request(_ url: URLConvertible, method: HTTPMethod = .get, parameters: [String: Any]? = nil, encoding: ParameterEncoding? = nil, httpHeaderFields: [String: String]? = nil, complete: ((NetworkResponse) -> Void)? = nil) -> DataRequest? {
        
        guard let reachability = self.reachability, reachability.connection != .unavailable else { return nil }
        
        let encoding = encoding ?? defaultEncoding
        
        guard let urlRequest = try? URLRequest(url: url, method: method) else { return nil }
        guard var encodedUrlRequest = try? encoding.encode(urlRequest, with: parameters) else { return nil }
        
        for (key, value) in authHttpHeaderFields {
            encodedUrlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        for (key, value) in httpHeaderFields ?? [:] {
            encodedUrlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        #if DEBUG
        log(encodedUrlRequest)
        #endif
        
        let dataRequest = Alamofire.request(encodedUrlRequest)
        
        dataRequest.responseJSON { (dataResponse) in
            let networkResponse = NetworkResponse(dataResponse: dataResponse)
            complete?(networkResponse)
        }
        
        return dataRequest
    }
    
    func upload(_ url: URLConvertible, parameters: [String: Any]? = nil, files: [String: (name: String, data: Data, mime: String)]? = nil, httpHeaderFields: [String: String]? = nil, uploadProgress: ((Float) -> Void)? = nil, downloadProgress: ((Float) -> Void)? = nil, beginUploading: ((UploadRequest?, Error?) -> Void)? = nil, complete: ((NetworkResponse) -> Void)? = nil) {
        
        guard let reachability = self.reachability, reachability.connection != .unavailable else { return }
        
        Alamofire.upload(multipartFormData: { multipart in
            
            if let parameters = parameters {
                
                let flatParams = DictionarySerializer(dict: parameters).flatKeyValue()
                
                for (key, value) in flatParams {
                    if let data = value.data(using: .utf8) {
                        multipart.append(data, withName: key)
                    }
                }
            }
            
            if let files = files {
                for (key, file) in files {
                    multipart.append(file.data, withName: key, fileName: file.name, mimeType: file.mime)
                }
            }
            
        }, usingThreshold: 0, to: url, method: .post, headers: authHttpHeaderFields, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseJSON { (dataResponse) in
                    let networkResponse = NetworkResponse(dataResponse: dataResponse)
                    complete?(networkResponse)
                }
                uploadRequest.uploadProgress(closure: { (p) in
                    uploadProgress?(Float(p.fractionCompleted))
                })
                uploadRequest.downloadProgress { (p) in
                    downloadProgress?(Float(p.fractionCompleted))
                }
                beginUploading?(uploadRequest, nil)
            case .failure(let encodingError):
                beginUploading?(nil, encodingError)
            }
        })
    }
    
    fileprivate func log(_ request: URLRequest) {
        
        var logs: [String] = ["--- NEW REQUEST ---"]
        
        if logConfiguration.url {
            let httpMethod = request.httpMethod ?? "Unknown HTTP Method"
            let url = request.url?.absoluteString ?? "URL is nil"
            logs.append(String(format: "%@ %@", httpMethod, url))
        }
        
        if logConfiguration.headers {
            logs.append("--- HEADER ---")
            logs.append(request.allHTTPHeaderFields?.description ?? "Headers is nil")
        }

        if let body = request.httpBody, logConfiguration.body, let _body = String(data: body, encoding: .utf8) {
            logs.append(_body)
        }
        
        print(logs.joined(separator: "\n\n"))
    }
    
    public func setAuthHeader(value: String, key: String) {
        authHttpHeaderFields[key] = value
    }
    
    public func clearAuthHeaderFields() {
        authHttpHeaderFields = [:]
    }
}
