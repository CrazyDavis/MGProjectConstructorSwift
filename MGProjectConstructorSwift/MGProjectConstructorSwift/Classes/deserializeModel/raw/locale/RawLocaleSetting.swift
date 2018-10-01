//
//	RawLocaleSetting.swift
//
//	Create by MagicalWater on 5/9/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

//多國語言json
class RawLocaleSetting: Codable {

	var language : [RawLanguage]
	var version : Int
    
}

class RawLanguage: Codable {
    var country : String
    var lang : String
    var name : String
}

