//
//  MGFgtFeature.swift
//  MGProjectConstructorSwift
//
//  Created by Magical Water on 2018/9/3.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

class MGFgtHelper {
    
    private var fgtManager: MGFgtManager? = nil
    
    weak var fgtDelegate: MGVCManagerDelegate? {
        didSet {
            fgtManager?.delegate = fgtDelegate
        }
    }
    
    //抓取是否啟用 fgt 輔助物件的工具
    func settingFgtManager(_ vcContainer: UIViewController) {
        fgtManager = MGFgtManager()
        fgtManager?.setBaseCotainer(vcContainer)
        fgtManager?.delegate = fgtDelegate
    }
    
    //設定 vc manager 的 root page
    public func setRootPage(_ page: MGPageData) {
        fgtManager?.setRootPage(page)
    }
    
    //跳轉到某個 VC, 可供複寫, 為的在跳轉前的執行動作
    public func fgtShow(_ request: MGUrlRequest) {
        fgtManager?.pageJump(request)
    }
    
    //顯示某個頁面, 不用經過網路
    public func fgtShow(_ pageInfo: MGPageInfo) {
        fgtManager?.pageJump(pageInfo)
    }
    
    //隱藏某個頁面
    public func fgtHide(_ vcTag: String) {
        fgtManager?.hideFgt(vcTag)
    }
    
    //回到首頁
    public func toRootPage() {
        fgtManager?.toRootPage()
    }
    
    //得到目前最頂端顯示的page
    public func getTopPage() -> MGPageData? {
        if let page = fgtManager?.totalHistory.last {
            return page
        } else {
            return nil
        }
    }
    
    //回退上一頁fragment, 回傳代表是否處理 back
    open func backPage(_ back: Int = 1) -> Bool {
        //先檢查最上層的fgt是否處理back的動作, 當back數量等於1時
        guard let fgtManager = fgtManager else {
            return false
        }
        if back == 1 && fgtManager.backAction() {
            return true
        } else {
            return fgtManager.backPage(back)
        }
        
    }
}
