//
//  MGAlamofireConnect.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/9/7.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Alamofire

//使用第三方 Alamofire 連線
class MGAlamofireConnect {
    
    //同步連線
    static func connect(with requestContent: MGRequestContent) -> MGConnectResponse? {
        let url = requestContent.getURL()!
        let params = requestContent.params
        let headers = requestContent.headers
        
        let httpMethod: HTTPMethod
        switch requestContent.method {
        case .get: httpMethod = .get
        case .post: httpMethod = .post
        }
        
        /*
         創建request分三種情形, 依照優先順序
         1. uploads不為空: 需要上傳的檔案, params有效, contentData失效
         2. contentData不為空: 需要帶入httpBody的資料, params失效, uploads失效
         3. uploads, contentData皆空: 無需要上傳也無需要帶入httpBody的資料, params有效
         */
        if let uploads = requestContent.uploads {
            if let response = upload(uploads, url: url, method: httpMethod, param: params, headers: headers) {
                return MGConnectResponse.init(response)
            }
        
        } else if let contentData = requestContent.contentData {
            
            if let response = connect(with: contentData, url: url, method: httpMethod, headers: requestContent.headers) {
                return MGConnectResponse.init(response)
            }
            
        } else {
            let response = connect(url, method: httpMethod, param: params, isParamJson: requestContent.paramIsJson, headers: requestContent.headers, cacheEnable: requestContent.network)
            return MGConnectResponse.init(response)
        }
        return nil
    }
    
    //一般連線(同步)
    static func connect(_ url: URL, method: HTTPMethod,
                        param: Parameters?, isParamJson: Bool,
                        headers: HTTPHeaders, cacheEnable: Bool) -> DataResponse<String> {
        let data: DataRequest = generatorRequest(url, method: method, param: param, isParamJson: isParamJson, headers: headers, cacheEnable: cacheEnable)
        return data.responseString(String.Encoding.utf8)
    }
    
    //夾帶raw Data
    static func connect(with: Data, url: URL, method: HTTPMethod, headers: HTTPHeaders) -> DataResponse<String>? {
        if let data = generatorRawDataRequest(url, method: method, contentData: with, headers: headers) {
            return data.responseString(String.Encoding.utf8)
        }
        return nil
    }
    
    //上傳檔案
    static func upload(_ with: [String:Any], url: URL, method: HTTPMethod, param: [String : String], headers: HTTPHeaders) -> DataResponse<String>? {
        let result = Alamofire.SessionManager.default.uploadData(url, method: method,
                                                                 data: with, param: param,
                                                                 header: headers)
        
        //上傳檔案後的結果
        switch result {
        case .success(let upload, _, _):
            /*
             upload 上傳的 UploadRequest
             fromDisk 是否從 dick 上傳
             streamFileURL 上傳檔案的url
             */
            return upload.responseString(String.Encoding.utf8)
        case .failure(_):
            //                case .failure(let encodingError):
            return nil
        }
    }
    
    //創建帶入RawData的request
    private static func generatorRawDataRequest(_ url: URL,
                                              method: HTTPMethod,
                                              contentData: Data,
                                              headers: HTTPHeaders) -> DataRequest? {
        //這有可能拋出錯誤, 若是出現錯誤直接返回nil
        var request = try? URLRequest(url: url, method: method, headers: headers)
        request?.httpBody = contentData
        if let request = request {
            return Alamofire.request(request)
        }
        return nil
    }
    
    //創建一般request
    private static func generatorRequest(_ url: URL, method: HTTPMethod,
                                       param: Parameters?, isParamJson: Bool,
                                       headers: HTTPHeaders, cacheEnable: Bool) -> DataRequest {
        if cacheEnable {
            return Alamofire.request(url,
                                     method: method,
                                     parameters: param,
                                     encoding: isParamJson ? JSONEncoding.default : URLEncoding.default,
                                     headers: headers)
        } else {
            return SessionManager.default.requestWithoutCache(url,
                                                              method: method,
                                                              parameters: param,
                                                              encoding: isParamJson ? JSONEncoding.default : URLEncoding.default,
                                                              headers: headers)
        }
    }
}
