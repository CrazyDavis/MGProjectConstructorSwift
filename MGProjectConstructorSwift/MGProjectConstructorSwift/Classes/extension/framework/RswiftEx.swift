//
//  RSwiftEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/20.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Rswift


//對於RSwift使用多國語言字串的擴展, 傳入語系專屬code, 獲取到當前專案下的多國語言對應字串
//若有專案資源的問題, 請帶入對應專案的bundle
public extension StringResource {
    
    public func locale(_ bundle: Bundle = Bundle.main) -> String {
        return locale(bundle, code: MGLocaleManager.shared.showLangCode)
    }

    public func locale(_ bundle: Bundle = Bundle.main, code: MGLocaleManager.LocaleCode) -> String {
        let path = bundle.path(forResource: code.rawValue, ofType: "lproj")
        if let p = path {
            let bundle = Bundle(path: p)
            return NSLocalizedString(key, tableName: tableName, bundle: bundle!, value: "", comment: "")
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    //直接轉為NSString
    public func localeNS(_ bundle: Bundle = Bundle.main) -> NSString {
        return localeNS(bundle, code: MGLocaleManager.shared.showLangCode)
    }

    //直接轉為NSString
    public func localeNS(_ bundle: Bundle = Bundle.main, code: MGLocaleManager.LocaleCode) -> NSString {
        return locale(bundle, code: code) as NSString
    }

}

