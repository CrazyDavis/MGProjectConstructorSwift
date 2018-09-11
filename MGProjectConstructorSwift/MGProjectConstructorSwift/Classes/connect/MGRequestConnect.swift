//
//  MGRequestConnect.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/8.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Alamofire
import MGUtilsSwift

typealias MGRequestConnectHandler = (_ request: MGUrlRequest, _ success: Bool) -> Void

/*
 此類針對 Request Builder 進行封裝
 主要處理線程併發
 */
public class MGRequestConnect {
    
    //設置此參數以方便自訂反序列化的處理
    open weak static var responseParserHandler: MGResponseParser?
    
    //可帶入是否自訂處理response
    static func getData(_ request: MGUrlRequest, requestCode: Int, callback: MGRequestCallback) {
        MGThreadUtils.inSubAsync {
            loopRequestStep(request, requestCode: requestCode, callback: callback)
        }
    }
    
    static func getData(_ request: MGUrlRequest, handler: @escaping MGRequestConnectHandler) {
        MGThreadUtils.inSubAsync {
            loopRequestStep(request, requestCode: -1, handler: handler)
        }
    }
    
    //開始循環獲取資料
    private static func loopRequestStep(_ request: MGUrlRequest, requestCode: Int,
                                        callback: MGRequestCallback? = nil, handler: MGRequestConnectHandler? = nil) {
        
        for i in 0..<request.runSort.count {
            
            //開始執行並聯需求
            let runSort = request.runSort[i]
            
            MGThreadUtils.inSubMulti(total: runSort.count) { number in
                //得到執行的urlIndex
                let urlIndex = runSort[number]
                print("執行ApiRequest: urlIndex = \(urlIndex)")
                
                distributionConnect(request, urlIndex: urlIndex)
            }
            
            
            //執行完一個階段, 需要根據設置的連線類型檢查錯誤
            let nextStep = checkExecuteStatus(request, executeIndex: runSort)
            if (!nextStep) {
                
                //有可能不繼續執行下個步驟的為
                //DEFAULT, SUCCESS_BACK
                //若是 DEFAULT 則成功參數返回FALSE 沒有問題
                //若是 SUCCESS_BACK 則是找到了成功的案例, 則返回true
                
                switch request.executeType {
                case .successBack:
                    MGThreadUtils.inMainAsync {
                        callback?.response(request, requestCode: requestCode, success: true)
                        handler?(request, true)
                    }
                    return
                case .errorBack:
                    MGThreadUtils.inMainAsync {
                        callback?.response(request, requestCode: requestCode, success: false)
                        handler?(request, false)
                    }
                    return
                    
                case .all: break
                }
                
            } else {
                //代表可以繼續往下執行
                //同時檢測是否有下個step, 有的話呼叫handler的 multipleRequest
                //方便特殊處理
                if (i < request.runSort.count - 1 && request.requestTag != nil) {
                    responseParserHandler?.multipleRequest(request: request, tag: request.requestTag!, step: i)
                }
            }
            
        }
        
        //執行到最後了
        //DEFAULT, SUCCESS_BACK, ALL
        //若是 ALL          則成功參數返回TRUE 沒有問題
        //若是 DEFAULT      則成功參數返回TRUE 沒有問題
        //若是 SUCCESS_BACK 則是沒有成功, 回傳 FALSE
        MGThreadUtils.inMainAsync {
            switch request.executeType {
            case .successBack:
                callback?.response(request, requestCode: requestCode, success: false)
                handler?(request, false)
            case .errorBack:
                callback?.response(request, requestCode: requestCode, success: true)
                handler?(request, true)
            case .all:
                callback?.response(request, requestCode: requestCode, success: true)
                handler?(request, true)
            }
        }
        
    }
    
    
    /*
     檢查某階段的request執行狀態, 根據不同的設置有不同的處理方式
     @param executeIndex: 代表此階段執行了這些index的url, 所以檢查是針對這些request做檢查
     回傳: 代表是否需要繼續執行下個階段, 而非是否發生錯誤
     */
    private static func checkExecuteStatus(_ request: MGUrlRequest, executeIndex: [Int]) -> Bool {
        switch request.executeType {
            
        //全部執行完畢才返回, 所以不檢查錯誤
        case .all: return true
            
        //當某階段全部成功後即返回
        case .successBack:
            //只要有一個沒有成功, 就直接跳出並且返回true代表需要繼續往下執行
            for run in executeIndex where !request.response[run].isSuccess {
                return true
            }
            return false
            
        //當出現錯後即刻返回
        case .errorBack:
            for run in executeIndex where !request.response[run].isSuccess {
                return false
            }
            return true
        }
    }
    
    
    //開始處理request, 從本地快取撈資料, 或者使用 get, post取資料
    private static func distributionConnect(_ request: MGUrlRequest, urlIndex: Int) {
        
        //接著判斷是否需要從本地撈取資料, 以及本地有無資料存在
        //資料庫快取部分尚未完成, 因此這部分直接略過
        if (request.content[urlIndex].locale.load) {
            return
        }
        
        startConnect(request, urlIndex: urlIndex)
    }
    
    //確定要從網路撈取資料了
    private static func startConnect(_ request: MGUrlRequest, urlIndex: Int) {
        print("連線開始: \(request.content[urlIndex])")
        let requestContent = request.content[urlIndex]
        
        if let response = MGAlamofireConnect.connect(with: requestContent) {
            responseDataHandle(request, response: response, urlIndex: urlIndex)
        }
        
    }
    
    //檔案處理回傳
    private static func responseDataHandle(_ request: MGUrlRequest, response: MGConnectResponse, urlIndex: Int) {
        
        //如果 response 是 nil, 則不解析, 也不反序列化, 直接將結果加入response
        guard let handler = responseParserHandler else {
            return
        }
        
        //首先判斷 連線的狀態 code
        //判斷api是否成功 - 呼叫外部回調檢查是否成功
        //        let isRequestSuccess = handler.isResponseStatsSuccess(response)
        //        let headerFields = response.response?.allHeaderFields ?? [:]
        
        //        print("連線完畢: 狀態 - \(String(describing: response.response?.statusCode)), header - \(headerFields)")
        
        //判斷下載檔案還是反序列化
        //若兩個同時設置, 則反序列化失效
        let contentHandler = request.content[urlIndex].contentHandler
        if let path = contentHandler.saveInPath {
            let response = handler.download(response)
            request.response[urlIndex] = response
            print("連線返回: 下載檔案: (\(String(describing: response.httpStatus))) 下載到 = \(path) path = \(String(describing: request.content[urlIndex].getURL()?.path)) \(response.isSuccess ? "成功" : "失敗")")
        } else if let deserizalize = contentHandler.deserialize {
            let response = handler.parser(response, deserialize: deserizalize)
            request.response[urlIndex] = response
            print("連線返回: 反序列化: (\(String(describing: response.httpStatus))) path = \(String(describing: request.content[urlIndex].getURL()?.path)) \(response.isSuccess ? "成功" : "失敗")")
        }
    }
    
}

//整個requst結束後回調
public protocol MGRequestCallback: class {
    func response(_ request: MGUrlRequest, requestCode: Int, success: Bool)
}

//所有response的解析
public protocol MGResponseParser: class {
    //如果有多筆request sort, 則每個step結束後都會呼叫此方法
    //前提是request帶有tag, step為當前執行到第幾個step結束
    func multipleRequest(request: MGUrlRequest, tag: String, step: Int)
    
    //解析response的回傳
    func parser(_ response: MGConnectResponse?, deserialize: MGJsonDeserializeDelegate.Type?) -> MGUrlRequest.MGResponse
    
    //下載檔案
    func download(_ response: MGConnectResponse?) -> MGUrlRequest.MGResponse
}
