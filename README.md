# 💸 DudeOwes
### *Track it before you forget it!*

A clean, modern, **100% offline** personal finance tracker built for hostel students. Track expenses, split bills, manage lend/borrow records, and plan your monthly budget — all from your phone.

---

## 📱 Screenshots

> *Coming soon *

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🏠 **Dashboard** | Live monthly spending, recent transactions, quick actions |
| 💸 **My Expenses** | Add, categorize, and track daily expenses with pie chart |
| 📋 **Budget Planner** | Set monthly budget and track planned vs actual spending |
| 🤝 **Lend / Borrow** | Track money lent or borrowed with repayment records |
| 🧮 **Calculator** | Built-in calculator with history |
| ⚙️ **Settings** | Theme, font size, currency, notifications, and more |
| 👤 **Onboarding** | Personalized setup with name, username, currency & budget |

---

## 🎨 Design

- **Color Palette:** Financy-inspired — Teal `#469B88`, Red `#E0533D`, Lavender `#9DA7D0`, Blue `#377CC8`, Yellow `#EED868`
- **Typography:** Clean sans-serif with bold headings
- **UI Style:** Card-based layout with soft shadows, rounded corners, and lots of white space
- **Bottom Navigation:** 5-tab navigation bar

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| **Flutter 3.19.6** | Cross-platform UI framework |
| **Dart** | Programming language |
| **shared_preferences** | Local offline storage |
| **fl_chart** | Beautiful charts and graphs |
| **Material Design 3** | UI components |

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry, Dashboard, Design tokens
├── database/
│   └── db_helper.dart          # SharedPreferences storage helper
├── models/
│   ├── expense.dart            # Expense data model
│   └── lend_borrow.dart        # Lend/Borrow data model
└── screens/
    ├── expenses_screen.dart    # My Expenses with pie chart
    ├── budget_screen.dart      # Budget Planner
    ├── lend_borrow_screen.dart # Lend/Borrow tracker
    ├── calculator_screen.dart  # Built-in calculator
    ├── settings_screen.dart    # Settings + About
    └── onboarding_screen.dart  # First launch setup
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.19.6 or higher
- Android Studio / VS Code
- Android device or emulator

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.3
  fl_chart: ^0.55.0
```

---

## 📦 Download APK

[Download DudeOwes v1.0.0](https://github.com/AnubhavPadiyar/dude_owes/releases/tag/v1.0.0)

---

## 🗺️ Roadmap

- [x] Dashboard with live data
- [x] My Expenses with categories
- [x] Budget Planner
- [x] Lend / Borrow tracker
- [x] Built-in Calculator
- [x] Settings & Onboarding
- [ ] Room Split feature
- [ ] PDF Export
- [ ] Dark Mode
- [ ] Charts in Budget screen

---

## 👨‍💻 Developer

**Anubhav Padiyar**
B.Tech Computer Science Engineering Student

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anubhav-padiyar-b9235237b)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/AnubhavPadiyar)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:anubhavpadiyar@gmail.com)


