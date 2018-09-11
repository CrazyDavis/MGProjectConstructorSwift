//
//  ApiPublicIpAddress.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/9/10.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import SwiftyJSON
import MGUtilsSwift

//取得外部ip
class ApiPublicIpAddress: MGJsonDeserializeDelegate {
    
    var ip : String!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    required init(_ json: JSON){
        if json.isEmpty{
            return
        }
        ip = json["ip"].stringValue
    }
    
}
