//
//  MGNetworkUtilsEx.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/9/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift

public extension MGNetworkUtils {
    
    //帶入 MGRequestContent, 同步回傳
    public func connect(with requestContent: MGRequestContent) -> MGNetworkResponse {
        let url = requestContent.getURL()!
        let params = requestContent.params
        let headers = requestContent.headers
        let encoding = requestContent.paramEncoding
        
        let httpMethod: MGNetworkUtils.Method
        switch requestContent.method {
        case .get: httpMethod = .get
        case .post: httpMethod = .post
        }
        
        var response: MGNetworkResponse
        
        /*
         創建request分三種情形, 依照優先順序
         1. uploads不為空: 需要上傳的檔案, params有效, contentData失效
         2. download
         3. uploads, contentData皆空, 一般request
         */
        if let uploads = requestContent.uploads {
            response = upload(url: url, datas: uploads, params: params, paramEncoding: encoding, headers: headers)
            
        } else if let downloadPath = requestContent.contentHandler.downloadInPath {
            let saveInUrl = URL.init(string: downloadPath)!
            response = download(url: url, destination: saveInUrl, params: params, headers: headers)
            
        } else {
            switch httpMethod {
            case .get:
                response = get(url: url, params: params, paramEncoding: encoding, headers: headers)
            case .post:
                response = post(url: url, params: params, paramEncoding: encoding, headers: headers)
            }
        }
        return response
    }
    
    //帶入 MGRequestContent, 異步回傳
    public func connect(with requestContent: MGRequestContent, completeHandler: ((MGNetworkResponse) -> Void)?) {
        let url = requestContent.getURL()!
        let params = requestContent.params
        let headers = requestContent.headers
        let encoding = requestContent.paramEncoding
        
        let httpMethod: MGNetworkUtils.Method
        switch requestContent.method {
        case .get: httpMethod = .get
        case .post: httpMethod = .post
        }
        
        /*
         創建request分三種情形, 依照優先順序
         1. uploads不為空: 需要上傳的檔案, params有效, contentData失效
         2. download
         3. uploads, contentData皆空, 一般request
         */
        if let uploads = requestContent.uploads {
            upload(url: url, datas: uploads, params: params, paramEncoding: encoding, headers: headers, completeHandler: completeHandler)
            
        } else if let downloadPath = requestContent.contentHandler.downloadInPath {
            let saveInUrl = URL.init(string: downloadPath)!
            download(url: url, destination: saveInUrl, params: params, headers: headers, completeHandler: completeHandler)
            
        } else {
            switch httpMethod {
            case .get:
                get(url: url, params: params, paramEncoding: encoding, headers: headers, completeHandler: completeHandler)
            case .post:
                post(url: url, params: params, paramEncoding: encoding, headers: headers, completeHandler: completeHandler)
            }
        }
    }
}
