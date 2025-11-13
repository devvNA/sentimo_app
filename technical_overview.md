# Sentimo Technical Overview

## Project Summary
Sentimo is an AI-powered sentiment journal Flutter mobile application that helps users track their emotional health through daily journaling with automatic sentiment analysis.

## Architecture Overview

### Technology Stack
- **Frontend:** Flutter (Dart) - Cross-platform mobile framework
- **State Management:** BloC (Business Logic Component) - Clean architecture pattern
- **Backend:** Supabase - Firebase alternative with PostgreSQL + Auth
- **AI Integration:** Google Gemini API - Sentiment analysis
- **Authentication:** Supabase Auth - OAuth + Email/Password
- **Database:** PostgreSQL (Supabase) - Relational database
- **Environment:** .env configuration for secrets management

### Clean Architecture Layers

```
Presentation Layer (UI)
  ↓
BloC Layer (State Management)
  ↓
Data Layer (Repositories)
  ↓
Services Layer (Supabase, Gemini APIs)
```

### Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration, environment setup
│   ├── constants/       # App constants and colors
│   ├── theme/           # Global theme and styling
│   ├── routing/         # Navigation setup
│   ├── entities/        # Domain models (JournalEntry, User)
│   └── widgets/         # Reusable UI components
├── data/
│   ├── repositories/    # Data access layer abstraction
│   │   ├── auth_repository.dart
│   │   └── journal_repository.dart
│   ├── services/        # External API clients
│   │   ├── supabase_service.dart
│   │   └── gemini_service.dart
│   └── models/          # Database models and DTOs
├── features/
│   ├── auth/
│   │   ├── bloc/        # AuthBloc, AuthEvent, AuthState
│   │   └── presentation/# Login/Register pages
│   ├── home/
│   │   ├── bloc/        # JournalListBloc
│   │   └── presentation/# Home page and journal cards
│   ├── journal/
│   │   ├── bloc/        # JournalEntryBloc
│   │   └── presentation/# New entry page
│   └── profile/
│       ├── bloc/        # ProfileBloc
│       └── presentation/# Profile page
└── main.dart            # App entry point
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email VARCHAR NOT NULL UNIQUE,
  username VARCHAR,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Journal Entries Table
```sql
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  sentiment_label VARCHAR, -- positive, negative, neutral
  sentiment_score FLOAT, -- 0.0 to 1.0
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT user_entries_fk FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Row-Level Security Policies
- Users can only read/write their own journal entries
- Authentication required for all operations

## State Management (BloC Pattern)

### Auth Flow
```
User Input → AuthEvent → AuthBloc → AuthState → UI Update
```

Events:
- LoginRequested(email, password)
- RegisterRequested(email, password, username)
- LogoutRequested()
- CheckAuthStatus()

States:
- AuthInitial
- AuthLoading
- AuthAuthenticated(user)
- AuthUnauthenticated
- AuthError(message)

### Journal Management Flow
```
User Creates Entry → JournalEntryEvent → JournalEntryBloc → Sentiment Analysis → Database → UI Update
```

## API Integration

### Supabase Integration
- Authentication: Supabase Auth (Email/Password)
- Database Operations: CRUD operations on journal_entries table
- Real-time Updates: Supabase RealtimeClient (if needed)

### Google Gemini API
- Endpoint: Google AI Studio / Google Generative AI SDK
- Purpose: Sentiment analysis of journal entry content
- Input: Full text of journal entry
- Output: Sentiment label (positive/negative/neutral) + confidence score
- Error Handling: Retry mechanism with exponential backoff

## UI/UX Design System

### Color Palette
- **Primary Blue:** #6BA5CF (Soft Blue)
- **Accent Green:** #98D8C8 (Mint Green)
- **Background:** #F7F7F7 (Off-White)
- **Text:** #2C3E50 (Dark Gray)

### Typography
- Font Family: Roboto / Inter (modern sans-serif)
- Headline: 24sp, weight 600
- Body: 16sp, weight 400
- Caption: 14sp, weight 400

### Navigation
- Bottom Navigation Bar with 3 tabs:
  1. Home (Journal list)
  2. New Entry (Create entry)
  3. Profile (User profile)

## Environment Configuration

### Required Environment Variables (.env)
```
SUPABASE_URL=https://[project-ref].supabase.co
SUPABASE_ANON_KEY=[anon-key]
GEMINI_API_KEY=[api-key]
```

### Current Status
- ✅ .env file configured with valid credentials
- ✅ Supabase project created
- ✅ Gemini API key configured
- ⏳ Database schema needs verification/setup

## Dependencies

### Core Dependencies
```yaml
# State Management
flutter_bloc: ^8.x.x
equatable: ^2.x.x

# Backend
supabase_flutter: ^2.x.x

# AI Integration
google_generative_ai: ^0.x.x

# Utilities
flutter_dotenv: ^5.x.x
shared_preferences: ^2.x.x
cupertino_icons: ^1.0.8
```

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Static analysis
flutter analyze

# Run tests
flutter test

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Clean build cache
flutter clean
```

## Key Design Decisions

1. **BloC Pattern:** Chosen for clear separation of concerns and testability
2. **Supabase:** Chosen for simplicity, built-in auth, and PostgreSQL flexibility
3. **Flutter:** Chosen for cross-platform mobile development
4. **Gemini API:** Chosen for accessible AI sentiment analysis
5. **Clean Architecture:** Ensures scalability and maintainability

## Future Enhancements

- Real-time data sync using Supabase subscriptions
- Sentiment history visualization with charts
- Export journal entries to PDF
- Offline mode support
- Multi-language support
- Custom sentiment categories
- Integration with external calendars

## Security Considerations

- API keys stored in .env (never committed to git)
- Row-Level Security enabled on all database tables
- JWT tokens managed by Supabase Auth
- Input validation on all user submissions
- Error handling prevents sensitive data leakage

---

*Last Updated: 2025-11-13*
*Status: Initial Setup Phase*
