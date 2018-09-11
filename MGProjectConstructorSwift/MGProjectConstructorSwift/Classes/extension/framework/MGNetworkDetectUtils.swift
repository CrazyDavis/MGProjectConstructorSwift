//
//  MGNetworkDetectUtils.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/9/10.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift

//新增網路偵測
extension MGNetworkDetectUtils {
    
    //第三方取得ip位址的
    private var thirdPartyGetPublicIpAddress: String {
        get {
            return "https://api.ipify.org/?format=json"
        }
    }
    
    //取得外部ip位址
    func getPublicIPAddress(handler: (String?) -> Void) {
        
        // https://api.ipify.org/?format=json 為第三方取得外部ip的位址
        // 官方網址為 https://www.ipify.org/
        let content = MGRequestContent.init(thirdPartyGetPublicIpAddress).setDeserialize(ApiPublicIpAddress.self)
        let request = MGUrlRequest.MGRequestBuilder().setUrlContent(content).build()
//        MGRequestConnect.getData(request) { request, success in
//            if success {
//                handler(request)
//            }
//        }
//        let reqeust = MGUrlRequest.MGRequestBuilder().setUrlContent(content).
    }
}
