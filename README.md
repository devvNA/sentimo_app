# Sentimo - AI Sentiment Journal 📝

[![Flutter CI](https://img.shields.io/badge/Flutter%20CI-Passing-success)](https://github.com)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-88%2F100-brightgreen)](CODE_QUALITY_REVIEW.md)
[![Security](https://img.shields.io/badge/Security-90%2F100-brightgreen)](SECURITY_AUDIT_REPORT.md)
[![Test Coverage](https://img.shields.io/badge/Coverage-40%25-yellow)](coverage/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A minimalist AI-powered journal app that helps you track your emotional health through automatic sentiment analysis of your daily entries.

---

## ✨ Features

- 🔐 **Secure Authentication** - Email/Password + Google Sign-In via Supabase Auth
- 📝 **Daily Journaling** - Clean, distraction-free writing interface
- 🤖 **AI Sentiment Analysis** - Powered by Google Gemini API
- 📊 **Mood Tracking** - Visual sentiment indicators and trends
- 🔒 **Privacy First** - End-to-end data isolation with Row-Level Security
- ⚡ **Performance Optimized** - Intelligent caching and rate limiting
- 🎨 **Calming Design** - Minimalist UI with soothing color palette
- 📱 **Cross-Platform** - Android & iOS support

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK `3.24+`
- Dart SDK `3.8+`
- Android Studio / Xcode
- Supabase account
- Google Gemini API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/sentimo.git
   cd sentimo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your keys:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
   GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

Sentimo follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/              # Shared utilities and configurations
│   ├── config/        # Environment & app config
│   ├── entities/      # Domain models
│   ├── theme/         # App theming
│   └── widgets/       # Reusable UI components
├── data/              # Data layer
│   ├── repositories/  # Data access abstraction
│   └── services/      # External API clients
└── features/          # Feature modules
    ├── auth/          # Authentication
    ├── home/          # Journal list
    ├── journal/       # Entry creation
    └── profile/       # User profile
```

**State Management:** BloC Pattern  
**Backend:** Supabase (PostgreSQL + Auth)  
**AI:** Google Gemini API  

📚 **See:** [Technical Overview](technical_overview.md)

---

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test file
flutter test test/features/auth/bloc/auth_bloc_simple_test.dart
```

### Test Coverage
- **Current:** 40% (25 tests, all passing)
- **Target:** 70%+
- **BloC Layer:** 100% covered

**Test Reports:** See [coverage/](coverage/)

---

## 📊 Code Quality

| Metric | Score | Status |
|--------|-------|--------|
| **Overall Quality** | 88/100 | 🟢 Excellent |
| **Security** | 90/100 | 🟢 Excellent |
| **Architecture** | 95/100 | 🟢 Excellent |
| **Performance** | 88/100 | 🟢 Excellent |
| **Maintainability** | 87/100 | 🟢 Excellent |

**Reports:**
- [Security Audit Report](SECURITY_AUDIT_REPORT.md)
- [Performance Optimization Report](PERFORMANCE_OPTIMIZATION_REPORT.md)
- [Code Quality Review](CODE_QUALITY_REVIEW.md)

---

## 🔧 Development

### Commands

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check for updates
flutter pub outdated

# Clean build
flutter clean && flutter pub get

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### Git Workflow

```bash
# Feature branch
git checkout -b feature/your-feature

# Commit
git add .
git commit -m "feat: add your feature"

# Push and create PR
git push origin feature/your-feature
```

**See:** [AGENTS.md](AGENTS.md) for coding guidelines

---

## 🤖 CI/CD

Automated pipelines via GitHub Actions:

- ✅ **Code Quality Checks** - Lint, format, analyze
- ✅ **Automated Testing** - Unit, widget, integration
- ✅ **Security Scanning** - Trivy, TruffleHog
- ✅ **Build Automation** - Android & iOS builds
- ✅ **Dependency Updates** - Dependabot
- ✅ **PR Automation** - Auto-labeling, size checks

**See:** [CI/CD Documentation](CI_CD_DOCUMENTATION.md)

---

## 📱 Screenshots

> Coming soon

---

## 🛣️ Roadmap

### Current Version (v1.0.0-beta)
- ✅ Core journaling functionality
- ✅ AI sentiment analysis
- ✅ Authentication (Email + Google)
- ✅ Data security & privacy
- ✅ Performance optimization

### Planned Features
- [ ] Sentiment history visualization with charts
- [ ] Export journal entries to PDF
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Custom sentiment categories
- [ ] Calendar integration
- [ ] Dark mode enhancement

---

## 🔒 Security

Sentimo takes security seriously:

- ✅ **Row-Level Security** - Supabase RLS policies
- ✅ **Input Sanitization** - XSS prevention
- ✅ **Rate Limiting** - API quota protection
- ✅ **Timeout Protection** - No hanging requests
- ✅ **Secret Management** - Environment variables
- ✅ **No Hardcoded Secrets** - All keys externalized

**Security Score:** 90/100 (EXCELLENT)

Report issues: [SECURITY.md](SECURITY.md)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Supabase](https://supabase.com/) - Backend platform
- [Google Gemini](https://deepmind.google/technologies/gemini/) - AI sentiment analysis
- [BloC Pattern](https://bloclibrary.dev/) - State management

---

## 📞 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/sentimo/issues)
- **Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/sentimo/discussions)
- **Email:** support@sentimo.app

---

## 📚 Documentation

- [Technical Overview](technical_overview.md)
- [Developer Guidelines](AGENTS.md)
- [Progress Tracking](PROGRESS.md)
- [Security Audit](SECURITY_AUDIT_REPORT.md)
- [Performance Report](PERFORMANCE_OPTIMIZATION_REPORT.md)
- [Code Quality Review](CODE_QUALITY_REVIEW.md)
- [CI/CD Documentation](CI_CD_DOCUMENTATION.md)

---

**Made with ❤️ by the Sentimo Team**
