# BazaarIQ

> **All-in-one ecommerce intelligence for Indian marketplace sellers.**
> Track orders · Optimize ads · Manage inventory · Calculate profits · Analyze keywords · Handle returns

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-22c55e?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-gray?style=flat-square)]()
[![Status](https://img.shields.io/badge/Status-v1.0%20Personal%20Use-f59e0b?style=flat-square)]()

---

## The Problem

Indian sellers manage 4–6 platforms with no unified view. Every metric lives in a different dashboard. You log into Amazon for sales, Flipkart for orders, Meesho for dispatches, then open a spreadsheet to piece it all together — every single day.

**BazaarIQ fixes this.** One app. All platforms. Every metric that matters.

---

## Modules

### 📊 Command Center
Unified daily view across all platforms — revenue, ACOS, order count, stock alerts, and a 7-day trend chart. The one screen you open every morning.

### 📦 Order Tracker
Every order from every platform in one list. Filter by status, marketplace, or date. Never miss a dispatch deadline or SLA.

### 📢 Ad Campaign Tracker
Log daily metrics per campaign. ACOS, TACOS, ROAS, CVR, and Health Score auto-calculate. Built-in issue radar flags high ACOS, exhausted budgets, and low CVR before they cost you money.

### 🔑 Keyword & STR Analyzer
Paste your Search Term Report data and get instant action labels for every keyword:

| Label | Meaning |
|---|---|
| ✅ `HARVEST` | Converting well — move to Exact match |
| 👀 `WATCH` | Marginal — lower the bid |
| ⚠️ `REDUCE BID` | ACOS creeping above target |
| ❌ `NEGATIVE` | Spending with zero sales — block it now |

### 💰 Profit & Margin Calculator
Real profit after every fee. Includes platform fee presets for Amazon, Flipkart, and Meesho. Calculates break-even ACOS, target ACOS, GST impact, and a what-if simulator per SKU.

### 📦 Inventory Manager
SKU-level stock tracking across all platforms. Days of Cover calculator, reorder alerts, dead stock flags, and inbound inventory tracking.

### 🔄 Returns & Refunds Tracker
Return rate per SKU, reason analysis (damaged, wrong item, fake return), refund cost tracking, and monthly trend charts. The module most sellers ignore until it kills their margin.

---

## Marketplace Support

| Marketplace | v1.0 (Manual) | v2.0 (Real-Time API) |
|---|---|---|
| 🟠 Amazon India | ✅ | Ads API + Selling Partner API |
| 🟡 Flipkart | ✅ | Flipkart Seller API |
| 🟣 Meesho | ✅ | Meesho Supplier API |
| 🔵 JioMart | ✅ | JioMart Seller API |
| 🩷 Myntra | Planned | Planned |
| 🌸 Nykaa | Planned | Planned |

---

## Key Metrics — Auto-Calculated

| Metric | Formula |
|---|---|
| ACOS | Ad Spend ÷ Ad Revenue |
| TACOS | Ad Spend ÷ Total Revenue (incl. organic) |
| ROAS | Ad Revenue ÷ Ad Spend |
| CVR | Orders ÷ Clicks |
| Break-even ACOS | Net Margin % |
| Target ACOS | Break-even × 0.7 |
| Max CPC | Price × Target ACOS × CVR |
| Net Margin | Revenue − COGS − Fees − Ad Spend |
| Days of Cover | Stock ÷ Avg Daily Sales |
| Return Rate | Returns ÷ Orders |

---

## Getting Started

```bash
# Clone
git clone https://github.com/yourusername/bazaariq.git
cd bazaariq

# Install
flutter pub get

# Run
flutter run

# Build APK
flutter build apk --release
```

> Demo data loads automatically on first launch so you can explore every screen right away.

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── campaign.dart
│   ├── order.dart
│   ├── keyword.dart
│   ├── inventory.dart
│   ├── profit.dart
│   └── returns.dart
├── utils/
│   ├── store.dart          # Global state + local persistence
│   ├── theme.dart          # Dark theme + formatting helpers
│   └── constants.dart      # Platform fee presets
├── widgets/                # Reusable UI components
└── screens/
    ├── dashboard_screen.dart
    ├── orders_screen.dart
    ├── campaigns_screen.dart
    ├── daily_log_screen.dart
    ├── keywords_screen.dart
    ├── acos_optimizer_screen.dart
    ├── profit_screen.dart
    ├── inventory_screen.dart
    └── returns_screen.dart
```

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.0+ |
| State | Provider |
| Charts | fl_chart |
| Storage | shared_preferences |
| Fonts | Google Fonts — Inter |
| IDs | uuid |
| Formatting | intl |

---

## Roadmap

**v1.0 — Current**
- [x] All 6 modules with full CRUD
- [x] Auto-calculated KPIs across every module
- [x] Offline-first with local persistence
- [x] Dark theme, Inter font, clean design system
- [x] Demo data on first launch

**v1.5 — Next**
- [ ] CSV / Excel export for all modules
- [ ] Push notifications — ACOS breach, low stock, missed dispatch
- [ ] Multi-seller account support
- [ ] Light / dark theme toggle
- [ ] STR bulk paste and import
- [ ] Barcode scanner for inventory

**v2.0 — Real-Time APIs**
- [ ] Amazon Ads API + Selling Partner API
- [ ] Flipkart Seller API
- [ ] Meesho Supplier API
- [ ] JioMart API
- [ ] Auto-sync daily metrics — zero manual entry
- [ ] Live keyword harvest queue from STR

**v3.0 — Public SaaS**
- [ ] Multi-user accounts with role-based access
- [ ] Agency dashboard — manage multiple seller brands
- [ ] AI bid recommendations per keyword
- [ ] Profit forecasting — 30 / 60 / 90 day projections
- [ ] Razorpay subscription billing
- [ ] Web app alongside mobile

---

## Contributing

Currently in personal use / pre-launch phase. Contributions welcome in:

- Platform fee calculators (Flipkart, Meesho, JioMart)
- API integration modules (v2.0 roadmap)
- Unit tests for calculation logic
- Hindi language support

Open an issue or reach out directly.

---

## License

[MIT](LICENSE) — free to use, fork, and build on.

---

Built by **[Himanshu Gupta](https://xdigipath.com)** · XDigiPath · Building in public

> *BazaarIQ is not affiliated with Amazon, Flipkart, Meesho, or JioMart.*