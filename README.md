# Private Events

The Odin Project 的「Private Events」練習，個人學習用。
原文連結：<https://www.theodinproject.com/lessons/ruby-on-rails-private-events>

學習重點：練 ActiveRecord **自訂關聯** — 當預設命名規則不夠用時，怎麼用 `class_name` / `foreign_key` / `source` 把複雜關係接好。

---

## 技術 stack

- Rails 8.1.3 / Ruby 3.4.6
- SQLite（開發＋測試一個檔案；production 多 DB 給 Solid Queue/Cache/Cable）
- Devise 4.9 做認證
- Hotwire（Turbo + Stimulus）+ Importmap，沒有 Node.js
- Propshaft asset pipeline
- Tailwind CSS 4.x（透過 `tailwindcss-rails` 獨立 CLI，依然不需 Node.js）
- Minitest（parallel）

詳細的架構說明見 [`CLAUDE.md`](./CLAUDE.md)。

---

## 啟動

```bash
bin/setup        # 一鍵安裝 gem、跑 migration、啟動 dev server
# 或拆兩步：
bundle install
bin/rails db:prepare
bin/dev
```

開 <http://localhost:3000>。

---

## 文件

- [`docs/project.md`](./docs/project.md) — Odin 原文需求改寫的學習筆記版
- [`docs/scope.md`](./docs/scope.md) — 本專案實際要做到哪一層（Tier 1–3）

---

## 進度

- [x] **Tier 1** — 註冊／登入、建立活動、報名/取消、events index+show、profile
- [x] **Tier 2** — 過去/未來活動切片、navbar、私人活動 + 邀請、Tailwind UI
- [ ] **Tier 3** — 編輯/刪除活動、切換公開私人

---

## 測試 & 檢查

```bash
bin/rails db:test:prepare test    # Minitest（model + integration）
bin/rubocop                       # 風格檢查（omakase 規則）
bin/brakeman --no-pager           # 安全靜態掃描
```
