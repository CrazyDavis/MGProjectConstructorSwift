//
//	RawLocaleSetting.swift
//
//	Create by MagicalWater on 5/9/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import MGUtilsSwift

//多國語言json
class RawLocaleSetting: MGJsonDeserializeDelegate {

	var language : [RawLanguage]!
	var version : Int!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    required init(_ json: JSON){
		if json.isEmpty{
			return
		}
		language = [RawLanguage]()
		let languageArray = json["language"].arrayValue
		for languageJson in languageArray{
			let value = RawLanguage(fromJson: languageJson)
			language.append(value)
		}
		version = json["version"].intValue
	}

}
