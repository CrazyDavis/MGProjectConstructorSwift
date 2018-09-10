//
//  MGConnectResponse.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/9/7.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Alamofire

public class MGConnectResponse {
    
    private let response: DataResponse<String>
    
    private let statusCode: Int? = nil
    
    init(_ response: DataResponse<String>) {
        self.response = response
    }
    
    public func getContentString() -> String? {
        return response.result.value
    }
    
    public func getStatusCode() -> Int? {
        return response.response?.statusCode
    }
}
