# Project: Private Events（學習筆記版）

> 改寫自 The Odin Project 的 Private Events 課程，作為個人實作參考用。
> 原文連結：https://www.theodinproject.com/lessons/ruby-on-rails-private-events

---

## 簡介

這個專案的重點是練習 ActiveRecord 的「關聯（associations）」，特別是當預設命名規則不夠用時，如何手動指定 `class_name`、`foreign_key`、`source` 等選項來建立複雜關係。

---

## 暖身：先想資料模型

在動手寫 code 前，先在紙上或筆記本畫一下下列三種情境的 model 與關聯：

- [ ] **寵物保姆網站**：人可以照顧多隻寵物，寵物也可以由多人照顧（多對多）。
- [ ] **晚餐派對邀請網站**：使用者可建立派對、邀請其他人、以及接受別人派對的邀請。
- [ ] **進階題（追蹤功能）**：怎麼設計才能讓「使用者追蹤其他使用者」？要思考自我參照的關聯。

---

## 專案需求總覽

要做一個類似私人版 Eventbrite 的網站，需求如下：

- 使用者可以建立活動。
- 使用者可以參加多個活動。
- 一個活動可以有多位參加者。
- 活動有日期；地點用字串儲存即可（例如 `"Andy's House"`）。

技術重點：**多對多關聯** + **自訂外鍵與類別名稱**。

---

## Step 1：環境設定（Setup）

- [ ] 在紙上規劃好整個 app 的資料模型（哪些 table、哪些欄位、哪些關聯）。
- [ ] 建立新的 Rails 專案 `private-events`。
- [ ] 建立對應的 GitHub repo。
- [ ] 寫一份清楚的 README，並在裡面附上這個 lesson 的連結。

---

## Step 2：Events 與 Users

### Event Model
- [ ] 建立 `Event` model 並 migrate（先不要加外鍵和驗證）。
- [ ] Model 要有「日期」欄位，不過先不必處理日期相關邏輯。

### EventsController
- [ ] 建立 `EventsController`。
- [ ] 加入 `#index` action，列出所有活動。
- [ ] 建立對應的 view，加上一個你喜歡的標題。

### 認證與 User
- [ ] 安裝設定 Devise 處理註冊／登入。
- [ ] 建立 `User` model（透過 Devise）。
- [ ] 把 `root_path` 設為 Event 的 index 頁。

### Creator 關聯（誰建立了活動）
- [ ] 建立 User 與 Event 之間的關聯，把建立活動的使用者命名為「creator」。
- [ ] 在 Event model 加上對應的外鍵欄位。
- [ ] 在關聯設定中明確指定 `class_name`、`foreign_key` 等選項（不能依賴預設命名）。
- [ ] User 的 show 頁要列出這位使用者建立過的所有活動。

### 建立活動的功能
- [ ] 在 EventsController 與 routes 中加入建立新活動所需的 action（`new` / `create`）。
- [ ] `#create` 用「關聯的 build 方法」來建立活動，讓使用者 ID 自動填入；不要用 `Event.new` 然後手動塞 ID。
- [ ] 寫好 `new` 的表單。
- [ ] Event 的 show 頁要顯示活動的詳細資料。

---

## Step 3：活動參加（Event Attendance）

### Attendee 關聯
- [ ] 建立另一組 User 與 Event 的關聯：把參加者命名為「attendee」，把參加的活動命名為「attended_event」。
- [ ] 同樣需要小心處理自訂的 `class_name`、`foreign_key`、`source`。

### Through Table（中介表）
- [ ] 因為是多對多，需要建立一個 through table（例如 `Registration` / `Attendance` / `EventAttendee`，自己命名）。
- [ ] 建立並 migrate 必要的表格與外鍵。

### 報名功能
- [ ] 為 through table 建立 controller 與 routes，讓使用者能成為某活動的 attendee。
- [ ] 在 view 上提供按鈕或連結讓使用者「報名參加」某活動。

### 顯示參加資訊
- [ ] Event 的 show 頁要列出所有參加者。
- [ ] User 的 show 頁要列出他參加的活動（attended_events）。
- [ ] 把 attended_events 拆成「過去的活動」與「未來的活動」兩塊顯示。
- [ ] 練習查詢與日期比較；**這個過去／未來的判斷邏輯放在 view，不要在 controller 另外開 method**。

---

## Step 4：收尾（Finishing Touches）

- [ ] 在 Event 的 index 頁，也把過去與未來的活動分開呈現。
- [ ] 先用兩個 class method 實作（例如 `Event.past`、`Event.upcoming`）。
- [ ] 之後再把這兩個 class method 重構成 scope。
- [ ] 加上頂部的導覽列（navbar），方便在頁面之間切換。
- [ ] 把活動改成「私人」性質：活動建立者可以邀請特定使用者參加。

---

## Extra Credit（加分題）

- [ ] 讓建立者可以編輯與刪除自己建立的活動。
- [ ] 讓使用者可以從 attended_events 中移除自己（取消報名）。
- [ ] 讓建立者可以切換活動的「公開／私人」狀態。

---

## 自我檢查重點

- [ ] 是否在每個自訂關聯中清楚指定 `class_name` / `foreign_key` / `source`？
- [ ] 是否使用「關聯的 build 方法」而不是手動填外鍵？
- [ ] 過去／未來活動的查詢是否善用 ActiveRecord 的 where 與日期比較？
- [ ] class methods 是否成功重構為 scopes？
- [ ] README 是否描述清楚並附上 lesson 連結？