//
//  Interceptors.swift
//  RestClient
//
//  Created by Guizion Labs on 11/03/16.
//  Copyright © 2016 Guizion Labs. All rights reserved.
//

import Foundation
import Genome
import Alamofire

public protocol Interceptor{
    
    init()
    
    func requestInterceptor<T: JsonConvertibleType>(api: API<T>)
    func responseInterceptor<T: JsonConvertibleType>(api: API<T>, response: Alamofire.Response<AnyObject, NSError>)
}