//
//	RawLanguage.swift
//
//	Create by MagicalWater on 5/9/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class RawLanguage{

	var country : String!
	var lang : String!
	var name : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		country = json["country"].stringValue
		lang = json["lang"].stringValue
		name = json["name"].stringValue
	}

}