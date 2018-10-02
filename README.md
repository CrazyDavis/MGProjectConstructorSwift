# MGProjectConstructorSwift
![](https://img.shields.io/cocoapods/v/MGProjectConstructorSwift.svg?style=flat) 
![](https://img.shields.io/badge/platform-ios-lightgrey.svg) 
![](https://img.shields.io/badge/language-swift-orange.svg)  

一個IOS APP專案的基底  

包含以下功能的封裝  
1. 將 ViewController 依照 Android 的概念分成 Activity 與 Fragment
2. 頁面之間的跳轉(包含 api request)
3. 頁面之間的跳轉可動畫位移呈現(尚未接入)
4. api request 單獨拉出, 供自訂widget, 不屬於 aty 與 fgt 的地方使用
5. scroll view 的下拉刷新封裝
6. 小鍵盤彈出時, 若會遮擋到元件, 則整個向上位移
7. qrcode 掃描

## 版本
1.0.4 - 修正 MGContentHandler 需要帶入的反序列化 class 類型錯誤  
1.0.3 - 修改 MGRequestConnect 的使用方式  
1.0.2 - 因 codable 無法滿足需求, 解析 Json 工具重新引入 swiftyJson, MGRequestContent 需要反序列化的 class 改回需要繼承 MGSwiftyJsonDelegate  
1.0.1 - 修改 MGRequestContent 需要反序列化的 class, 必需繼承 MGCodable  
1.0.0 -   
1. 更新 swift version 至 4.2.  
2. 修正 MGBaseFgt 沒有呼叫到 settingFgtManager.  
3. 更換 網路 request 請求lib, 取消alamofire 改採自行封裝的 MGNetworkUtils.  

0.1.7 - 增加 MGRequestConnect 接口, 可用 block closure 的方式處理相關回調  
0.1.6 - 刪除無用class  
0.1.5 - MGRequestContent 將動作更改為 contentHandler 封裝, 可選擇反序列化/下載檔案, 下載可監測進度  
0.1.4 - MGRequestConnect 增加異步handler回調方法  
0.1.3 - 更改 網路連接相關類別的資料結構
0.1.2 - 開放多國語系設置, 相關類別 MGLocaleManager, RswiftEx(RSwift擴展)  
0.1.1 - 將 MGFgtManager 再封裝一層進入 MGFgtHelper, MGBaseApiHelper 更名為 MGApiHelper  
0.1.0 - 新增MGRequest可帶入contentData的資料

## 添加依賴

### Cocoapods
pod 'MGProjectConstructorSwift', '~> {version}'  
( 其中 {version} 請自行替入此版號 ![](https://img.shields.io/cocoapods/v/MGProjectConstructorSwift.svg?style=flat) )
