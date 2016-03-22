//
//  API.swift
//  RestClient
//
//  Created by Guizion Labs on 10/03/16.
//  Copyright © 2016 Guizion Labs. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer
import Alamofire

class API <T: MappableBase> {
        
    var path: NSURLRequest
    var queryParams: [String: String]?
    var bodyParams: [String: AnyObject]?
    var method: Alamofire.Method
    var headers: [String: String] = [:]
    var interceptors: [Interceptor] = []
    var logger = Logger()
    var curl: String?
    
    init(path: NSURL, method: Alamofire.Method, queryParams: [String: String]?, bodyParams: [String: AnyObject]?, headers: [String: String]?, interceptors: [Interceptor]?){
        
        self.path = NSURLRequest(URL: path)
        
        if queryParams != nil {
            self.path = ParameterEncoding.URLEncodedInURL.encode(self.path, parameters: queryParams).0
        }
        
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.method = method
        if headers != nil {
            self.headers = headers!
        }
        if interceptors != nil {self.interceptors.appendContentsOf(interceptors!)}
    }
    
    
    func execute( onSucess: (result: T?) -> Void, onError: (ErrorType?) -> Void, always: () -> Void) {
        
        for interceptor in interceptors {
            interceptor.requestInterceptor(self)
        }
        
        let request = Alamofire.request(method, path.URLString, parameters: bodyParams, encoding: ParameterEncoding.JSON, headers: headers)
        self.curl = request.debugDescription
        
        request.responseJSON { (response) -> Void in
            
            for interceptor in self.interceptors {
                interceptor.responseInterceptor(self, response: response)
            }
            
            if Utils.isSucessRequest(response) {
                var instance: T? = nil // For empty results
                if let _ = response.result.value {
                    let json = try! Json.deserialize(response.data!)
                    instance = try! T.newInstance(json, context: EmptyJson)
                }
                onSucess(result: instance)
            }else{
                onError(response.result.error) // TODO: Error Handler
            }
            
            always()
        }
    }
    
}