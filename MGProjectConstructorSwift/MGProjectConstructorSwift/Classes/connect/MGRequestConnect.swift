//
//  MGRequestConnect.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/8.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift

//以block closure 回調
public typealias MGRequestConnectHandler = (_ request: MGUrlRequest, _ success: Bool) -> Void

//以block closure 處理 MGResponseParser的multiRequest
public typealias HandleMutliRequest = (_ request: MGUrlRequest, _ tag: String, _ step: Int) -> Void

//以block closure 處理 MGResponseParser的parser
public typealias HandleParser = (_ response: MGNetworkResponse, _ deserialize: MGSwiftyJsonDelegate.Type) -> MGUrlRequest.MGResponse

//以block closure 處理 MGResponseParser的download
public typealias HandleDownload = (_ response: MGNetworkResponse) -> MGUrlRequest.MGResponse

/*
 此類針對 Request Builder 進行封裝
 主要處理線程併發
 */
public class MGRequestConnect {
    
    //設置此參數預設反序列化/下載檔案/多request的處理
    public weak var defaultResponseParserHandler: MGResponseParser?
    
    //自訂 block 處理多筆request
    public var mutliRequestHandler: HandleMutliRequest?
    
    //自訂 block 處理request回傳解析
    public var requestParserHandler: HandleParser?
    
    //自訂 block 處理download request
    public var downloadRequestHandler: HandleDownload?
    
    public static let shared: MGRequestConnect = MGRequestConnect.init()
    
    //可帶入是否自訂處理response
    public func getData(_ request: MGUrlRequest, requestCode: Int, callback: MGRequestCallback) {
        MGThreadUtils.inSubAsync {
            self.loopRequestStep(request, requestCode: requestCode, callback: callback)
        }
    }
    
    //以 block 的方式處理回傳資料
    public func getData(_ request: MGUrlRequest, handler: @escaping MGRequestConnectHandler) {
        MGThreadUtils.inSubAsync {
            self.loopRequestStep(request, requestCode: -1, handler: handler)
        }
    }
    
    /*
     設置預設的request回傳handler
     此預設handler是個 protocol, 包含以下三項
     1. 多筆 request 的回調
     2. 每筆 request 當設置需要返序列化時的回調
     3. 下載 reqeust 的回調
     */
    public func setDefaultResponseHandler(handler: MGResponseParser?) -> MGRequestConnect {
        self.defaultResponseParserHandler = handler
        return self
    }
    
    /*
     設置 多筆 request 的回調
     當 mutliRequestHandler 與 defaultResponseParserHandler 皆有設置時
     defaultResponseParserHandler 的 multipleRequest 將不會呼叫
     */
    public func setMultiHandler(handler: HandleMutliRequest?) -> MGRequestConnect {
        self.mutliRequestHandler = handler
        return self
    }
    
    /*
     設置 每筆 request 當設置需要返序列化時的回調 的回調
     當 requestParserHandler 與 defaultResponseParserHandler 皆有設置時
     defaultResponseParserHandler 的 parser 將不會呼叫
     */
    public func setParserHandler(handler: HandleParser?) -> MGRequestConnect {
        self.requestParserHandler = handler
        return self
    }
    
    /*
     設置 下載 reqeust 的回調
     當 mutliRequestHandler 與 defaultResponseParserHandler 皆有設置時
     defaultResponseParserHandler 的 download 將不會呼叫
     */
    public func setDownloadHandler(handler: HandleDownload?) -> MGRequestConnect {
        self.downloadRequestHandler = handler
        return self
    }
    
    //開始循環獲取資料
    private func loopRequestStep(_ request: MGUrlRequest, requestCode: Int,
                                 callback: MGRequestCallback? = nil,
                                 handler: MGRequestConnectHandler? = nil) {
        
        for i in 0..<request.runSort.count {
            
            //開始執行並聯需求
            let runSort = request.runSort[i]
            
            //多個request併發執行
            MGThreadUtils.inSubMulti(total: runSort.count) { number in
                //得到執行的urlIndex
                let urlIndex = runSort[number]
                print("執行ApiRequest: urlIndex = \(urlIndex)")
                self.distributionConnect(request, urlIndex: urlIndex)
            }
            
            //執行完一個階段, 需要根據設置的連線類型檢查錯誤
            let nextStep = checkExecuteStatus(request, executeIndex: runSort)
            if (!nextStep) {
                
                /*
                 下列兩種類型不繼續執行下個步驟
                 1. DEFAULT      - 則成功參數返回FALSE 沒有問題
                 2. SUCCESS_BACK - 找到了成功的案例, 則返回true
                 */
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
                /*
                 可以繼續往下執行, 同時檢測是否有下個step,
                 有的話呼叫handler的 multipleRequest, 方便特殊處理
                 */
                if (i < request.runSort.count - 1 && request.requestTag != nil) {
                    sendMutliRequestBack(request, tag: request.requestTag!, step: i)
                }
            }
            
        }
        
        //檢查request是否成功執行
        let isRequestSuccess = isRequestExecuteSuccess(request: request)
        MGThreadUtils.inMainAsync {
            callback?.response(request, requestCode: requestCode, success: false)
            handler?(request, isRequestSuccess)
        }
        
    }
    
    /*
     requst執行到最後, 檢查是否是一個成功的執行
     DEFAULT, SUCCESS_BACK, ALL
     1. ALL             - 成功參數返回TRUE
     2. DEFAULT         - 成功參數返回TRUE
     2. SUCCESS_BACK    - 沒有成功, 回傳 FALSE
     */
    private func isRequestExecuteSuccess(request: MGUrlRequest) -> Bool {
        switch request.executeType {
        case .successBack:
            return false
        case .errorBack:
            return true
        case .all:
            return true
        }
    }
    
    /*
     檢查某階段的request執行狀態, 根據不同的設置有不同的處理方式
     @param executeIndex: 代表此階段執行了這些index的url, 所以檢查是針對這些request做檢查
     回傳: 代表是否需要繼續執行下個階段, 而非是否發生錯誤
     */
    private func checkExecuteStatus(_ request: MGUrlRequest, executeIndex: [Int]) -> Bool {
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
    private func distributionConnect(_ request: MGUrlRequest, urlIndex: Int) {
        
        //接著判斷是否需要從本地撈取資料, 以及本地有無資料存在
        //資料庫快取部分尚未完成, 因此這部分直接略過
        if (request.content[urlIndex].locale.load) {
            return
        }
        
        startConnect(request, urlIndex: urlIndex)
    }
    
    //確定要從網路撈取資料了
    private func startConnect(_ request: MGUrlRequest, urlIndex: Int) {
        print("連線開始: \(request.content[urlIndex])")
        let requestContent = request.content[urlIndex]
        
        let response = MGNetworkUtils.share.connect(with: requestContent)
        responseDataHandle(request, response: response, urlIndex: urlIndex)
        
    }
    
    //檔案處理回傳
    private func responseDataHandle(_ request: MGUrlRequest, response: MGNetworkResponse, urlIndex: Int) {
        
        //判斷下載檔案還是反序列化
        //若兩個同時設置, 則反序列化失效
        let contentHandler = request.content[urlIndex].contentHandler
        if let path = contentHandler.downloadInPath {
            let response = sendDownloadBack(response)
            request.response[urlIndex] = response
            print("連線返回: 下載檔案: (\(String(describing: response.httpStatus))) 下載到 = \(path) path = \(String(describing: request.content[urlIndex].getURL()?.path)) \(response.isSuccess ? "成功" : "失敗")")
        } else if let deserizalize = contentHandler.deserialize {
            let response = sendParserBack(response, deserialize: deserizalize)
            request.response[urlIndex] = response
            print("連線返回: 反序列化: (\(String(describing: response.httpStatus))) path = \(String(describing: request.content[urlIndex].getURL()?.path)) \(response.isSuccess ? "成功" : "失敗")")
        } else {
            //不是下載, 也不是反序列化, 那就將返回字串傳入
            let response = MGUrlRequest.MGResponse.init(response.dataString, success: response.success, status: response.statusCode ?? -1)
            request.response[urlIndex] = response
        }
    }
    
    //發送多筆request回調
    private func sendMutliRequestBack(_ request: MGUrlRequest, tag: String, step: Int) {
        if let handler = mutliRequestHandler {
            handler(request, request.requestTag!, step)
        } else {
            defaultResponseParserHandler?.multipleRequest(request: request, tag: tag, step: step)
        }
    }
    
    //發送解析回調
    private func sendParserBack(_ response: MGNetworkResponse, deserialize: MGSwiftyJsonDelegate.Type) -> MGUrlRequest.MGResponse {
        if let handler = requestParserHandler {
            return handler(response, deserialize)
        } else {
            return defaultResponseParserHandler?.parser(response, deserialize: deserialize) ?? MGUrlRequest.MGResponse()
        }
    }
    
    //發送下載回調
    private func sendDownloadBack(_ response: MGNetworkResponse) -> MGUrlRequest.MGResponse {
        if let handler = downloadRequestHandler {
            return handler(response)
        } else {
            return defaultResponseParserHandler?.download(response) ?? MGUrlRequest.MGResponse()
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
    func parser(_ response: MGNetworkResponse, deserialize: MGSwiftyJsonDelegate.Type) -> MGUrlRequest.MGResponse
    
    //下載檔案
    func download(_ response: MGNetworkResponse) -> MGUrlRequest.MGResponse
}

//以下三個方法都不一定會用到, 為了方便給自訂parser使用, 因此這邊直接繼承變可選
public extension MGResponseParser {
    func multipleRequest(request: MGUrlRequest, tag: String, step: Int) {}
    func parser(_ response: MGNetworkResponse, deserialize: MGSwiftyJsonDelegate.Type) -> MGUrlRequest.MGResponse { return MGUrlRequest.MGResponse() }
    func download(_ response: MGNetworkResponse) -> MGUrlRequest.MGResponse { return MGUrlRequest.MGResponse() }
}
