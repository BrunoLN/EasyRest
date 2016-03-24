//
//  Router.swift
//  RestClient
//
//  Created by Guizion Labs on 16/03/16.
//  Copyright © 2016 Guizion Labs. All rights reserved.
//

import Foundation
import Genome
import Alamofire


public protocol Routable {
    var base: String {get}
    var rule: Rule {get}
    
    func builder<T: JsonConvertibleType>(type: T.Type) throws -> APIBuilder<T>
    
    func authenticator () -> authenticatorClass?
    associatedtype authenticatorClass: Authentication
}

extension Routable {
    
    public func builder<T: JsonConvertibleType>(type: T.Type) throws -> APIBuilder<T> {
        
        if self.rule.isAuthenticable && authenticator()?.getToken() == nil {
            throw AuthenticationRequired()
        }
        
        let builder = APIBuilder<T>()
        if let auth = authenticator() {
            builder.addInsterceptor(auth)
        }
        
        builder.logger = Logger()
        
        try builder.addParameteres(self.rule.parameters)
        return builder.resource(self.base + self.rule.path, method: self.rule.method)
    }
}