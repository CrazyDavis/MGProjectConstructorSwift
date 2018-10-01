//
//  MGSwiftyJsonUtils.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/10/1.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import SwiftyJSON

//原生的 codable 有些限制, 因此在這裡 引入 swifyJson 還是有必要的
public class MGSwiftyJsonUtils {
    
    private init() {}
    
    //反序列化, 將json變成物件
    public static func deserialize<T: MGSwiftyJsonDelegate>(_ jsonString: String) -> T? {
        return deserialize(jsonString, deserialize: T.self)
    }
    
    //反序列化, 將json變成物件
    public static func deserialize<T: MGSwiftyJsonDelegate>(_ jsonString: String, deserialize: T.Type) -> T? {
        guard let json = converToJSON(jsonString) else {
            return nil
        }
        //        print("印出jsonString = \(jsonString), 印出json = \(json.dictionary)")
        let ins = deserialize.init(json)
        return ins
    }
    
    /*
     序列化, 將物件變成json data
     JSONSerialization能將JSON轉換成Foundation，也能將Foundation轉換成JSON，但轉換成JSON有以下限制
     1，最外層必須是Array或Dictionary
     2，所有的Object必須是 String、Number、Array、Dictionary、Nil 的 instance
     3，所有Dictionary的key必須是String
     4，數字不能是無窮或非數值
     */
    public static func serializeData(_ data: Any) -> Data? {
        //首先檢查是否能序列化
        if !JSONSerialization.isValidJSONObject(data) { return nil }
        //利用自帶的json工具轉json字串
        //如果設置options为JSONSerialization.WritingOptions.prettyPrinted，則印出來的格式更好閱讀
        if let data = try? JSONSerialization.data(withJSONObject: data, options: []) {
            return data
        }
        return nil
    }
    
    /*
     序列化, 將物件變成json字串
     */
    public static func serializeString(_ data: Any) -> String? {
        if let data = serializeData(data) {
            //Data轉String
            let str = String(data: data, encoding: String.Encoding.utf8)
            return str
        }
        return nil
    }
    
    //將字串轉為 Data
    private static func converToData(_ string: String) -> Data? {
        return string.data(using: .utf8, allowLossyConversion: true)
    }
    
    //將字串轉為JSON
    public static func converToJSON(_ string: String) -> JSON? {
        if let dataFromString = MGSwiftyJsonUtils.converToData(string) {
            let j = JSON(dataFromString)
            if !j.isEmpty {
                return j
            }
        }
        return nil
    }
}

//需要返序列化的class需要繼承此協議
public protocol MGSwiftyJsonDelegate {
    init(_ json: JSON)
}

