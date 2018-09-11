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
    
    //一般連線回傳
    private var response: DataResponse<String>? = nil
    
    //下載檔案的回傳類型
    private var downloadResponse: DownloadResponse<String>? = nil
    
    //裝的回傳類型
    private let responseType: ResponseType
    
    private enum ResponseType {
        case normal
        case download
    }
    
    private let statusCode: Int? = nil
    
    init(_ response: DataResponse<String>) {
        self.responseType = .normal
        self.response = response
    }
    
    init(_ response: DownloadResponse<String>) {
        self.responseType = .download
        self.downloadResponse = response
    }
    
    public func getContentString() -> String? {
        switch responseType {
        case .normal:
            return response?.result.value
        case .download:
            return downloadResponse?.result.value
        }
    }
    
    public func getStatusCode() -> Int? {
        switch responseType {
        case .normal:
            return response?.response?.statusCode
        case .download:
            return downloadResponse?.response?.statusCode
        }
    }
}
