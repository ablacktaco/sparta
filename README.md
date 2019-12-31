# sparta

## 好想工作室挑戰賽

### 四大陣營
* sparta - 傭兵系統，可發案接案
* Athens - 驛站系統，可將貨物從驛站A發送至驛站B
* Arkadia - 貿易系統，可新增貨物及買賣貨物
* Phokis - 金流系統，管理4大陣營金流

### Sparta夥伴
* Sarah - 後端
* 汪汪 - Android, UI設計
* 姿穎 - iOS, 流程設計

## Demo

### 前導頁面

* 可選擇註冊或登入
* extension UIImageView以使用GIF圖檔作為圖片

### 註冊

* 輸入暱稱、帳號、密碼及綁定的金流帳號，並且選定身份後註冊
* 密碼做屏蔽處理(後續頁面皆有做此處理)
* 資料缺乏時無法註冊(後續頁面皆有做此處理)
* 文字編輯時捲動頁面，完成編輯或點擊空白處收起鍵盤並恢復畫面(後續頁面皆有做此處理)
* 文字格式防呆處理(後續頁面皆有做此處理)
* 可選擇註冊為平民(只能發案)或傭兵(可發案及接案)
* 若選擇註冊為傭兵，則跳轉小遊戲(資格認證)

![](https://github.com/ablacktaco/sparta/blob/master/resign.gif)

### 記憶小遊戲

* 分3階段，20秒內記憶劍盾出現順序後按照相同順序輸入
* 出題時擋答案輸入
* 成功後自動註冊為傭兵，失敗後強制註冊為平民

![](https://github.com/ablacktaco/sparta/blob/master/qualification.gif)

### 登入 / 登出

* 輸入帳號密碼後接收response(token)並儲存，後續使用token做請求
* 登出時清空token

![](https://github.com/ablacktaco/sparta/blob/master/login.gif)

### 主頁面

* 顯示簡易個人資料
* 可跳轉懸賞系統/驛站/貿易中心/個人頁面/射擊小遊戲等頁面
* 提供使用者登出

### 懸賞榜 / 發案

* 顯示案件title、細節、案主預算及申請人(競爭者)
* 可搜尋標題或使用預算下限對案件作filter

* 輸入案件title、細節、預算及案件類型發案

![](https://github.com/ablacktaco/sparta/blob/master/post.gif)

### 接案管裡 / 回報任務(無demo)

* 顯示已完成(成功/失敗)、未完成(已回報/未回報)及申請中任務
* 點選未回報任務跳轉回報頁面

* 採用拍照或選取照片，並增加敘述後上傳的方式回報

### 發案管理

* 顯示已完成(成功/失敗)、未完成(已指派/未指派)及已回報任務
* 點選未指派任務跳轉指派頁面
* 顯示申請承接此案的傭兵的姓名、出價、接案數及達成率，並可指派由誰完成任務。指派後任務移至已指派任務區

![](https://github.com/ablacktaco/sparta/blob/master/postManager.gif)

* 點選已回報任務跳轉結案頁面
* 顯示傭兵上傳的圖片及敘述
* 可選擇任務成功/失敗
* (串接金流中心陣營API)若選擇任務成功則由金流中心轉帳給該傭兵，需輸入金流中心金鑰
* 金流中心抽成30%，很黑(10000-30*(1.3)=9961)

![](https://github.com/ablacktaco/sparta/blob/master/decide1.gif) ![](https://github.com/ablacktaco/sparta/blob/master/decide2.gif)

### 貿易中心

* (串接貿易中心陣營API)點選購買商品，需輸入金流中心金鑰，由金流中心轉帳給貿易中心陣營

![](https://github.com/ablacktaco/sparta/blob/master/buy.gif)

### 個人頁面

* 顯示個人身份資料
* 於貿易中心購買的商品及懸賞任務蒐集到的物品皆會顯示於個人頁面的所有物中
* 若忘記金流中心金鑰，可於此頁面查詢
* 點選照片可更換大頭貼(拍照或相片選取，主頁同步更新)

![](https://github.com/ablacktaco/sparta/blob/master/profile.gif)

### 驛站 / 寄送物品

* (串接驛站陣營API)檢視從斯巴達寄出的貨物的狀態及所在位置

![](https://github.com/ablacktaco/sparta/blob/master/station.gif)

* 可從個人所有物中選取物品寄送
* 設定寄送物品、地點、物品重量及運費後寄送，刊登後物品轉為準備中狀態等待寄送

![](https://github.com/ablacktaco/sparta/blob/master/send.gif)

### 射擊小遊戲

* 斯巴達人的收入來源！
* 攻擊敵對雅典陣營的成員來獲得國家補助
* 長按上下左右移動，點擊射擊鍵攻擊
* 每個成員有不同的運動模式及分數
* 若時間到/用光子彈/射擊到貓貓豆芽皆會結束遊戲

![](https://github.com/ablacktaco/sparta/blob/master/shot1.gif) ![](https://github.com/ablacktaco/sparta/blob/master/shot2.gif)
