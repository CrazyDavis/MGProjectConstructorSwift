//
//  MGBaseFgt.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/22.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit


/*
 最基本的上層 VC, 封裝一些普遍的需求(例如倒數計時, api request)
 這邊依照Android的結構進行分類
 -> 最外層/底層的 ViewController: Activity(Aty)
 -> 依附於Activity之下的 ViewController: Fragment(Fgt)
 */
open class MGBaseFgt: UIViewController, MGApiHelperDelegate, MGVCManagerDelegate, MGFgtDataHelper {

    private var apiHelper: MGApiHelper = MGApiHelper()
    private var fgtHelper: MGFgtHelper = MGFgtHelper()

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settingApiHelper()
        setupView()
    }

    //頁面資料進入點
    open func pageData(_ data: MGPageData, isFgtInit: Bool) {
        
    }

    //抓取是否啟用 api 輔助物件的工具
    private func settingApiHelper() {
        apiHelper.delegate = self
    }
    
    //抓取是否啟用 fgt 輔助物件的工具
    private func settingFgtManager() {
        fgtHelper.settingFgtManager(self)
        fgtHelper.fgtDelegate = self
    }

    open func setupView() {}

    //裝載所有vc的view
    open func vcContainer() -> UIViewController { return self }
    
    //如果啟VC管理則此項必須設置
    open func rootPage() -> MGPageData? { return nil }
    
    
    //子類別設定倒數計時狀態
    public func timerAction(_ action: MGApiHelper.TimerAction) {
        apiHelper.timerAction(action)
    }
    
    //設定倒數計時預設時間
    public func setTimerTime(_ time: TimeInterval) {
        apiHelper.timerTime = time
    }
    
    //設定 vc manager 的 root page
    public func setRootPage(_ page: MGPageData) {
        fgtHelper.setRootPage(page)
    }
    
    //跳轉到某個 VC, 可供複寫, 為的在跳轉前的執行動作
    open func fgtShow(_ request: MGUrlRequest) {
        fgtHelper.fgtShow(request)
    }
    
    //顯示某個頁面, 不用經過網路
    public func fgtShow(_ pageInfo: MGPageInfo) {
        fgtHelper.fgtShow(pageInfo)
    }
    
    //隱藏某個頁面
    public func fgtHide(_ vcTag: String) {
        fgtHelper.fgtHide(vcTag)
    }
    
    //回到首頁
    public func toRootPage() {
        fgtHelper.toRootPage()
    }
    
    //得到目前最頂端顯示的page
    public func getTopPage() -> MGPageData? {
        return fgtHelper.getTopPage()
    }
    
    //回退上一頁fragment, 回傳代表是否處理 back
    open func backPage(_ back: Int = 1) -> Bool {
        return fgtHelper.backPage()
    }
    
    //發送request
    public func sendRequest(_ rt: MGUrlRequest, code: Int = MGRequestSender.REQUEST_DEFAUT) {
        apiHelper.sendRequest(rt, requestCode: code)
    }

    //******************** MGVCManagerDelegate - API 委託相關回傳 以下 **************************
    
    //跳轉頁面回調
    open func fgtChange(pageData: MGPageData) {}
    
    //跳轉頁面包含撈取api, 得到response之後, 跳轉頁面之前回調
    //回傳代表是否攔截回調
    open func jumpResponse(request: MGUrlRequest, requestCode: Int, success: Bool) -> Bool { return false }
    
    //******************** MGVCManagerDelegate - API 委託相關回傳 以下 **************************


    //******************** API 委託相關回傳 以下 **************************
    open func response(_ request: MGUrlRequest, success: Bool, requestCode: Int) { }

    open func timesUp() { }
    //******************** API 委託相關回傳 結束 **************************


}
