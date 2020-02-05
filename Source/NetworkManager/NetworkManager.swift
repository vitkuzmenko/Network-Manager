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

extension ResponseError {
    static let noInternetConnection = ResponseError(error: NSLocalizedString("No internet connection", comment: ""), statusCode: -1)
}

public class NetworkManager: NSObject {
    
    open class TestResponse {
        
        var statusCode: Int
        
        var result: String
        
        init(result: String, statusCode: Int = 200) {
            self.result = result
            self.statusCode = statusCode
        }
        
    }
    
    var reachability = try? Reachability()
    
    var isReachable: Bool { return reachability?.connection ?? .unavailable != .unavailable }
    
    let logRequest = true
    
    public enum POSTDataType {
        case json, formData
    }
    
    public var prefferedPostDataType: POSTDataType = .json
    
    public static let `default` = NetworkManager()
    
    public var authHttpHeaderFields: [String: String] = [:]
    
    public var logConfiguration: (url: Bool, headers: Bool, body: Bool) = (true, false, true)
    
    override init() {
        super.init()
        
        initReachibility()
    }
    
    @discardableResult public class func request(_ url: String, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, downloadProgress: ((Float) -> Void)? = nil, testResponse: TestResponse? = nil, complete: ((Response) -> Void)? = nil) -> NetworkRequest? {
        return NetworkManager.default.request(url, method: method, getParameters: getParameters, parameters: parameters, postDataType: postDataType, httpHeaderFields: httpHeaderFields, httpBody: httpBody, downloadProgress: downloadProgress, complete: complete)
    }
    
    public class func upload(_ url: String, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, files: [String: (name: String, data: Data, mime: String)]? = nil, httpHeaderFields: [String: String]? = nil, uploadProgress: ((Float) -> Void)? = nil, downloadProgress: ((Float) -> Void)? = nil, beginUploading: ((NetworkRequest?, ResponseError?) -> Void)? = nil, complete: ((Response) -> Void)? = nil) {
        return NetworkManager.default.upload(url, getParameters: getParameters, parameters: parameters, files: files, httpHeaderFields: httpHeaderFields, uploadProgress: uploadProgress, downloadProgress: downloadProgress, beginUploading: beginUploading, complete: complete)
    }
    
    /**
     Perform request with error detection
     
     - parameter method:     HTTP Method
     - parameter url:        Request URL
     - parameter parameters: Request Body parameters
     - parameter complete:   completion closure
     */
    func request(_ url: String, method: HTTPMethod = .get, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType? = nil, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil, downloadProgress: ((Float) -> Void)? = nil, testResponse: TestResponse? = nil, complete: ((Response) -> Void)? = nil) -> NetworkRequest? {
        
        if !isReachable {
            complete?(noInternetConnectionResponse)
            return nil
        }

        let request = constructRequestForMethod(
            method,
            url: url,
            getParameters: getParameters,
            parameters: parameters,
            postDataType: postDataType ?? prefferedPostDataType,
            httpHeaderFields: httpHeaderFields,
            httpBody: httpBody
        )
        
        if let testResponse = testResponse {
            let httpResponse = HTTPURLResponse(url: request.url!, statusCode: testResponse.statusCode, httpVersion: nil, headerFields: nil)
            let resp = self.complete(request, response: httpResponse, JSON: testResponse.result, error: nil)
            complete?(resp)
            return nil
        } else {
            let req = Alamofire.request(request)
            req.downloadProgress { (p) in
                downloadProgress?(Float(p.fractionCompleted))
            }
            req.responseJSON { (response) in
                let resp = self.complete(request, response: response.response, JSON: response.result.value, error: response.result.error)
                complete?(resp)
            }
            return NetworkRequest(_request: req)
        }
    }
    
    func upload(_ url: String, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, files: [String: (name: String, data: Data, mime: String)]? = nil, httpHeaderFields: [String: String]? = nil, uploadProgress: ((Float) -> Void)? = nil, downloadProgress: ((Float) -> Void)? = nil, beginUploading: ((NetworkRequest?, ResponseError?) -> Void)? = nil, complete: ((Response) -> Void)? = nil) {
        
        if !isReachable {
            complete?(noInternetConnectionResponse)
            return
        }
        
        let urlString = build(url: url, getParameters: getParameters)
        
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
            
        }, usingThreshold: 0, to: urlString, method: .post, headers: authHttpHeaderFields, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let resp = self.complete(response.request, response: response.response, JSON: response.result.value, error: response.result.error)
                    complete?(resp)
                }
                upload.uploadProgress(closure: { (p) in
                    uploadProgress?(Float(p.fractionCompleted))
                })
                upload.downloadProgress { (p) in
                    downloadProgress?(Float(p.fractionCompleted))
                }
                beginUploading?(NetworkRequest(_request: upload), nil)
            case .failure(let encodingError):
                beginUploading?(nil, ResponseError(error: encodingError.localizedDescription))
            }
        })
    }
    
    fileprivate var noInternetConnectionResponse: Response {
        let resp = Response(URLRequest: nil, response: nil)
        resp.error = .noInternetConnection
        return resp
    }
    
    /**
     Request complete processor
     
     - parameter request:  URLRequest
     - parameter response: NSHTTPURLResponse
     - parameter JSON:     Response object
     - parameter error:    NSError
     - parameter complete: closure
     */
    fileprivate func complete(_ request: URLRequest?, response: HTTPURLResponse?, JSON: Any?, error: Error?) -> Response {
        
        let _response = Response(URLRequest: request, response: response)
        
        if let status = response?.statusCode {
            
            _response.statusCode = status
            
            switch status {
            case 200...226 :
                _response.JSON = JSON
                return _response
            default:
                _response.error = self.getError(JSON)
                _response.error?.statusCode = status
                return _response
            }
        }
        
        if let _nsError = error {
            _response.error = ResponseError(error: _nsError.localizedDescription)
        } else if _response.error == nil {
            _response.error = ResponseError(error: "Unknown \(response!.statusCode)")
        }
        
        _response.error?.statusCode = response?.statusCode ?? 0
        
        return _response
    }
    
    /**
     Construct URLRequest for perform request
     
     - parameter method:     HTTP Method
     - parameter url:        Request URL
     - parameter parameters: Request Body parameters
     
     - returns: URLRequest object
     */
    fileprivate func constructRequestForMethod(_ method: HTTPMethod, url: String, getParameters: [String: Any?]? = nil, parameters: [String: Any]? = nil, postDataType: POSTDataType, httpHeaderFields: [String: String]? = nil, httpBody: Data? = nil) -> URLRequest {
        
        let urlString = build(url: url, getParameters: getParameters)
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let httpBody = httpBody {
            request.httpBody = httpBody
        } else {
            switch postDataType {
            case .json:
                fillParametersForJSONDataType(parameters, toRequest: &request)
            case .formData:
                fillParametersForFormDataType(parameters, toRequest: &request)
            }
        }
        
        buildhttpHeaderFields(&request, httpHeaderFields: httpHeaderFields)
        
        if logRequest {
            log(request)
        }
        
        request.cachePolicy = .reloadIgnoringCacheData
        
        return request
    }
    
    fileprivate func build(url: String, getParameters: [String: Any?]?) -> String {
        var completeURL = url
        
        completeURL = url + "?"
        
        if let getParameters = getParameters {
            let safegetParameters = removeNilValues(dictionary: getParameters)
            let serializer = DictionarySerializer(dict: safegetParameters)
            completeURL += serializer.getParametersInFormEncodedString()
        }
        
        completeURL = completeURL.trimmingCharacters(in: CharacterSet(charactersIn: "&?"))
        
        return completeURL
    }
    
    fileprivate func fillParametersForJSONDataType(_ parameters: [String: Any]?, toRequest request: inout URLRequest) {
        guard let parameters = parameters else { return }
        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: parameters,
                options: [.prettyPrinted]
            )
        } catch _ {
            request.httpBody = nil
        }
    }
    
    fileprivate func fillParametersForFormDataType(_ parameters: [String: Any]?, toRequest request: inout URLRequest) {
        guard let parameters = parameters else { return }
        let serializer = DictionarySerializer(dict: parameters)
        let string = serializer.getParametersInFormEncodedString()
        request.httpBody = string.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
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
    
    /**
     Build HTTP header fields for mutable url request
     
     - parameter mutableURLRequest: URLRequest
     - parameter httpHeaderFields:  HTTP Header Fields
     - parameter tokenPolicy:       case of NetworkManagerTokenPolicy enum
     */
    fileprivate func buildhttpHeaderFields(_ request: inout URLRequest, httpHeaderFields: [String: String]?) {
        
        let lang = NSLocalizedString("lang", comment: "")
        
        request.setValue(lang, forHTTPHeaderField: "Accept-Language")
        
        for (key, value) in authHttpHeaderFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let httpHeaderFields = httpHeaderFields {
            for item in httpHeaderFields {
                request.setValue(item.1, forHTTPHeaderField: item.0)
            }
        }
        
        request.timeoutInterval = 30
    }
    
    /**
     Get Error object from server response object
     
     - parameter JSON: server response object
     
     - returns: Error object with NetworkManagerError and localized description
     */
    fileprivate func getError(_ json: Any?) -> ResponseError? {
        
        var error = "", errorDescription = ""
        
        if let json = json as? [String: Any] {
            if let rawError = json["Error"] as? String {
                error = rawError
            } else if let rawErrorCode = json["ErrorCode"] as? String {
                error = rawErrorCode
            }
            
            if let rawErrorDescription = json["ErrorDescription"] as? String {
                errorDescription = rawErrorDescription
            } else if let rawErrorMessage = json["ErrorMessage"] as? String {
                errorDescription = rawErrorMessage
            }
            
        }
        
        let e = ResponseError(error: error, localizedDescription: errorDescription)
        e.JSON = json
        
        return e
    }

    func initReachibility() {
        
        guard let reachability = try? Reachability() else { return }
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.sync {
//                if reachability.isReachableViaWiFi {
//                    print("Reachable via WiFi")
//                } else {
//                    print("Reachable via Cellular")
//                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.sync {
                print("Not reachable")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    public func setAuthHeader(value: String, key: String) {
        authHttpHeaderFields[key] = value
    }
    
    public func clearAuthHeaderFields() {
        authHttpHeaderFields = [:]
    }
}
