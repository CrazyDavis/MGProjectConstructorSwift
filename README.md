# MGProjectConstructorSwift
![](https://img.shields.io/cocoapods/v/MGProjectConstructorSwift.svg?style=flat)  

一個IOS APP專案的基底  

包含以下功能的封裝  
1. 將 ViewController 依照 Android 的概念分成 Activity 與 Fragment
2. 頁面之間的跳轉(包含 api request)
3. 頁面之間的跳轉可動畫位移呈現(尚未接入)
4. api request 單獨拉出, 供自訂widget, 不屬於 aty 與 fgt 的地方使用
5. scroll view 的下拉刷新封裝
6. 小鍵盤彈出時, 若會遮擋到元件, 則整個向上位移
7. qrcode 掃描

版本更迭:  
0.1.0 - 新增MGRequest可帶入contentData的資料

使用方式:  
pod 'MGProjectConstructorSwift', '~> {version}'
