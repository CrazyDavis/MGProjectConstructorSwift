//
//  MGRequestContent.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift

/*
 構件網路要求的內容,
 使用的連接類型 (GET, POST)
 連接的網址 (URL)
 CustomStringConvertible - 繼承此類別, 自定義 toString
 */

public typealias MGProgressHandler = (Progress) -> Void

public class MGRequestContent: CustomStringConvertible {

    //自定義的 toString
    public var description: String {
        var result = "連線(\(method)) - 位址: \(scheme)://\(host)\(path), 參數: \(paramSource)"
        if let path = contentHandler.downloadInPath {
            result += "\n下載到路徑: \(path)"
        }
        if let deserialize = contentHandler.deserialize {
            result += "\n反序列化(\(String(describing: deserialize)))"
        }
        return result
    }

    public var scheme: String // http 或者 https
    public var host: String //主機域名
    public var path: String //uri路徑
    public var method: Method //用什麼方式連接, GET 或 POST

    //要求頭
    public var headers: [String:String] = [:]

    //要求的參數
    public var params: [String:String] {
        get {
            if paramSource.isEmpty { return [:] }
            var l: [String:String] = [:]
            for (k,v) in paramSource {
                switch (v) {
                case is String:
                    l[k] = v as? String
                default:
                    let map = v as! [String:String]
                    for (num, innerV) in map {
                        l["\(k)[\(num)]"] = innerV
                    }
                }
            }
            return l
        }
    }
    

    //需要上傳的檔案
    public var uploads: [MGNetworkUploadData]? {
        get {
            if uploadSource.isEmpty { return nil }
            var uploads: [MGNetworkUploadData] = []
            for (k,v) in uploadSource {
                switch (v) {
                case is Dictionary<String, Any>:
                    let map = v as! [String:Any]
                    for (num, innerV) in map {
                        uploads.append(
                            MGNetworkUploadData.init(name: "\(k)[\(num)]", fileName: "file", data: innerV)
                        )
                    }
                default:
                    uploads.append(
                        MGNetworkUploadData.init(name: k, fileName: "file", data: v)
                    )
                }
            }
            return uploads
        }
    }

    //資料帶入content, 有別於 param 跟 uploads 帶入的資料
//    public var contentData: Data?

    //參數是否為 Json 格式
    public var paramEncoding: MGParamEncoding = MGURLEncoding.default

    //通常搭配資料庫lib, 是否從本地資料庫拉出相對應的 class 所儲存的資料
    public var locale: MGLocalCache = MGLocalCache() //本地的快取設定, 默認關閉

    //發起 request 時是否要快取
    public var network: Bool = true //網路的快取設定, 默認開啟

    public var contentHandler: MGContentHandler = MGContentHandler() //得到回傳後需要做的動作, 需要反序列化的 class 或者 下載到目的路徑

    //這邊處存內部已有的 param key, 對應到已經加入多少個, 方便取出時加入陣列字串
    private var paramSource: [String:Any] = [:]

    //同 paramSource, 差別在於此參數專給 uploads
    private var uploadSource: [String:Any] = [:]
    
    //同 paramSource, 差別在於此參數專給 headers
    private var headerSource: [String:Any] = [:]

    public init(_ scheme: MGRequestContent.Scheme,
         host: String,
         path: String,
         method: MGRequestContent.Method = MGRequestContent.Method.get) {
        self.scheme = scheme.rawValue
        self.host = host
        self.path = path
        self.method = method
    }
    
    //傳入無法被解析的url是不允許的, 這邊直接全都為空值不拋出錯誤
    public init(_ url: String, method: MGRequestContent.Method = MGRequestContent.Method.get) {
        let url = URL.init(string: url)
        self.scheme = url?.scheme ?? ""
        self.host = url?.host ?? ""
        self.path = url?.path ?? ""
        self.method = method
        self.paramSource = url?.queryDictionary ?? [:]
    }
    
}

//相關資料結構
public extension MGRequestContent {

    //本地的快取設定
    public struct MGLocalCache {
        var load: Bool = false
        var save: Bool = false
    }

    //是 http 還是 https
    public enum Scheme: String {
        case http = "http"
        case https = "https"
    }

    //Requst Method
    public enum Method {
        case get
        case post
    }

    //得到文件後是 下載/反序列化
    public class MGContentHandler {
        public var downloadInPath: String? = nil //包含檔名
        
        //進度回調
        public var progressHandler: MGProgressHandler? = nil
        
        public var deserialize: MGCodable.Type? = nil
        
        init() {}
        
        init(downloadInPath: String, progressHandler: MGProgressHandler?) {
            self.downloadInPath = downloadInPath
        }
        
        init(deserialize: MGCodable.Type) {
            self.deserialize = deserialize
        }
    }

}

//設定資料
public extension MGRequestContent {

    public func setDeserialize(_ deserialize: MGCodable.Type) -> MGRequestContent {
        self.contentHandler.deserialize = deserialize
        return self
    }
    
    //代表要下載檔案, 可傳入回調方法
    public func setDownload(_ path: String, progressHandler: MGProgressHandler? = nil) -> MGRequestContent {
        self.contentHandler.downloadInPath = path
        self.contentHandler.progressHandler = progressHandler
        return self
    }

    public func setParamEncoding(_ econding: MGParamEncoding) -> MGRequestContent {
        self.paramEncoding = econding
        return self
    }

    //取出 url
    public func getURL() -> URL? {
        let urlString = "\(scheme)://\(host)\(path)"
        return URL(string: urlString)
    }

    //加入參數
    public func addParam(_ key: String, value: String, array: Bool) -> MGRequestContent {
        addingValue(with: &paramSource, key: key, adding: value, isArray: array)
        return self
    }

    //加入多個參數
    public func addParams(_ key: String, value: [String]) -> MGRequestContent {
        value.forEach { (v) in
            _ = addParam(key, value: v, array: true)
        }
        return self
    }


    //加入上傳的檔案
    public func addUpload(_ key: String, value: Any, array: Bool) -> MGRequestContent {
        addingValue(with: &uploadSource, key: key, adding: value, isArray: array)
        return self
    }

    //加入多個上傳的檔案
    public func addUploads(_ key: String, value: [Any]) -> MGRequestContent {
        value.forEach { (v) in
            _ = addUpload(key, value: v, array: true)
        }
        return self
    }
    
    //加入頭
    public func addHeader(_ key: String, value: String, array: Bool) -> MGRequestContent {
        addingValue(with: &headerSource, key: key, adding: value, isArray: array)
        return self
    }
    
    //加入多個頭
    public func addHeaders(_ key: String, value: [String]) -> MGRequestContent {
        value.forEach { (v) in
            _ = addHeader(key, value: v, array: true)
        }
        return self
    }

    /*
     得到加入 header/param/upload 參數之類東西的正確賦值
     @param datas - 要加入的陣列
     @param key - 即將加入的key
     @param adding - 即將加入的值
     @param isArray - 是否為陣列形式
     */
    private func addingValue( with datas: inout [String:Any], key: String, adding: Any, isArray: Bool) {
        if isArray {
            var innerArray: [String: Any] = datas[key] == nil ? [:] : datas[key]! as! [String: Any]
            innerArray["\(innerArray.count)"] = adding
            datas[key] = innerArray
        } else {
            datas[key] = adding
        }
    }

}
