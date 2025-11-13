# How to View Coverage Report

## Quick Summary
- **Total Tests:** 66 passing ✅
- **Coverage File:** `lcov.info`
- **Files Covered:** 28 files tracked

---

## 🌐 Method 1: VS Code Extension (EASIEST)

1. **Install Extension**
   - Open VS Code Extensions (Ctrl+Shift+X)
   - Search: "Coverage Gutters"
   - Install by: ryanluker.vscode-coverage-gutters

2. **View Coverage**
   - Open any file in VS Code
   - Press `Ctrl+Shift+7` (or `Ctrl+Shift+9`)
   - Coverage highlights appear:
     - 🟢 Green = Covered
     - 🔴 Red = Not covered
     - 🟡 Yellow = Partially covered

3. **Features**
   - Live coverage in editor
   - Summary in status bar
   - Watch mode support

---

## 🌐 Method 2: Online LCOV Viewer

1. **Open Online Tool**
   - Go to: https://lcov-viewer.netlify.app/
   - Or: https://github.com/eriwen/lcov-to-html-viewer

2. **Upload File**
   - Click "Upload LCOV file"
   - Select: `coverage/lcov.info`

3. **View Report**
   - Interactive HTML report
   - Click files to see line-by-line coverage
   - No installation needed

---

## 🌐 Method 3: Generate HTML Report (Advanced)

### Install LCOV Tools

**Windows (Chocolatey):**
```bash
choco install lcov
```

**Windows (Manual):**
1. Download from: http://ltp.sourceforge.net/coverage/lcov.php
2. Extract and add to PATH

### Generate HTML
```bash
# From project root
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

### Features
- Full interactive HTML report
- Drill-down by directory
- Line-by-line coverage
- Branch coverage details

---

## 📊 Current Coverage Summary

Based on `lcov.info`:

**Covered Files:**
- `auth_repository.dart` - 43.6% (17/39 lines)
- `sentiment_service.dart` - 63.3% (81/128 lines)
- `auth_bloc.dart` - 55.4% (36/65 lines)
- `journal_bloc.dart` - 47.8% (44/92 lines)

**Not Covered:**
- UI/Presentation layers (login_page, home_page, profile_page)
- Some repository methods (journal_repository)
- Theme and widgets

**Total:** ~40-45% coverage estimated

---

## 🎯 Quick Commands

```bash
# Run tests with coverage
flutter test --coverage

# View in VS Code
# (After installing Coverage Gutters extension)
# Press Ctrl+Shift+7

# Generate HTML (if lcov installed)
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

---

## 📁 File Structure

```
coverage/
├── lcov.info          # Raw coverage data (upload this to online viewer)
└── html/             # Generated HTML report (if using genhtml)
    └── index.html    # Open this in browser
```

---

## 💡 Tips

1. **Best Method:** VS Code Extension for daily use
2. **Share Reports:** Use online viewer to share with team
3. **CI/CD:** Generate HTML in pipeline for artifact storage
4. **Real-time:** Coverage Gutters updates on test run

---

**Last Updated:** 2025-11-13
**Total Tests:** 66 passing
**Project:** Sentimo - Production Ready ✅
