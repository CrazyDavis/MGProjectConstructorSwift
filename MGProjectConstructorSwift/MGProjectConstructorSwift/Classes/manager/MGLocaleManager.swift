//
//  MGLocaleManager.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/20.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift
import MGExtensionSwift

//多國語系管理器
public class MGLocaleManager {

    //code是通用的, 目前只有 基本/英文/簡繁中
    public enum LocaleCode: String {
        case base = "Base"
        case en = "en"
        case zh_tw = "zh-Hant"
        case zh_cn = "zh-Hans"
    }
    
    //選擇的語言是第幾筆
    public private(set) var showIndex: Int = 0
    
    //當前選擇的語系
    public private(set) var showLangCode: LocaleCode = LocaleCode.base
    
    //當前app選擇的語系code
    private var mShowLang: String = ""
    
    //可選擇的語系列表
    public var selectableLanguageName: [String] {
        get {
            return mLangObject.language.map { $0.name }
        }
    }
    
    //可選擇的語系, 用來讓外部設定選擇的語系index時比對
    private var mSelectableLang: [String] {
        get {
            return mLangObject.language.map { $0.lang }
        }
    }
    
    //反序列化設置語系字串的class
    private var mLangObject: RawLocaleSetting!
    
    public static let shared: MGLocaleManager = MGLocaleManager()
    
    //使用內建預設範本語系選擇設定
    public func initSetting() {
        loadLangByDefault()
        getSelectedLanguage()
    }
    
    //使用自訂語系選擇設定, 具體json字串請參考範本文字 mglang.txt
    public func initSetting(_ langText: String) {
        loadLang(langText)
        getSelectedLanguage()
    }
    
    //轉化失敗, 跳出訊息, 並且返回base語系
    private func covertToLocaleCode(_ lang: String) -> LocaleCode {
        if let l = LocaleCode.init(rawValue: lang) {
            return l
        } else {
            print("沒找到對應的語系, 為了正常執行自動選擇 Base")
            return LocaleCode.base
        }
    }
    
    //載入預設語系設定範本
    private func loadLangByDefault() {
        let langText = MGResourceUtils.loadString(fileName: "mglang", ex: "txt")!
        loadLang(langText)
    }
    
    //將語系設定反序列化為model
    private func loadLang(_ langText: String) {
        mLangObject = MGJsonUtils.deserialize(langText, deserialize: RawLocaleSetting.self)
    }
    
    private func getSelectedLanguage() {
        loadSetting()
        
        //所選擇的語系, 默認為0
        showIndex = 0
        
        if !mShowLang.isEmpty {
            mLangObject.language.forEachIndexed {
                if mShowLang == $1.lang {
                    showIndex = $0
                }
            }
        }
        
        mShowLang = mLangObject.language[showIndex].lang
        showLangCode = covertToLocaleCode(mShowLang)
        
        saveSetting()
    }
    
    //將選擇的語系名稱存入本地
    private func saveSetting() {
        MGSettingUtils.put(MGSettingTag.NAME_LOCALE_LANE, value: mShowLang)
    }
    
    //從本地讀取預設值
    private func loadSetting() {
        mShowLang = MGSettingUtils.get(MGSettingTag.NAME_LOCALE_LANE, def: "")
    }
}

//設置語系, 設置完最好重新開啟app
public extension MGLocaleManager {
    
    //設定選擇哪種語言, 設定完成後建議重新開啟app以完整載入
    public func selectLanguage(_ index: Int) {
        showIndex = index
        mShowLang = mSelectableLang[showIndex]
        showLangCode = covertToLocaleCode(mShowLang)
        saveSetting()
    }
    
    //設定選擇哪種語言, 設定完成後建議重新開啟app以完整載入
    public func selectLanguage(_ code: LocaleCode) {
        var isFind = false
        mSelectableLang.forEachIndexed {
            if code.rawValue == $1 {
                showIndex = $0
                isFind = true
            }
        }
        
        if isFind {
            selectLanguage(showIndex)
        } else {
            print("設置語系失敗: \(code.rawValue), 沒有找到對應語系")
        }
    }
    
}
