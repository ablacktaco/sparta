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
