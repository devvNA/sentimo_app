# Technical Overview - Sentimo: AI Sentiment Journal

## Project Status
**Current Phase:** Initial Setup  
**Last Updated:** 2025-11-03

---

## Core Components

### 1. **Application Layer** (`lib/`)
Currently contains only the default Flutter counter app in `main.dart`. Will be restructured into:

- **Presentation Layer**: UI components, pages, and BloC state management
  - `features/auth/` - Login/Register screens and auth BloC
  - `features/home/` - Journal list display and home BloC
  - `features/journal/` - New entry creation and journal BloC
  - `features/profile/` - User profile management
  
- **Domain Layer**: Business logic and entities
  - `core/entities/` - User, JournalEntry models
  - `core/usecases/` - Business logic operations
  
- **Data Layer**: Repository implementations and API clients
  - `data/repositories/` - Supabase data access
  - `data/services/` - Google Gemini API integration
  
- **Core Infrastructure**
  - `core/config/` - Environment configuration
  - `core/theme/` - App theme (calming color palette)
  - `core/routing/` - Navigation setup
  - `core/widgets/` - Reusable UI components

### 2. **Backend Infrastructure** (Supabase)

**Database Schema:**
- `users` table: Managed by Supabase Auth (id, email, metadata)
- `journal_entries` table:
  - `id` (UUID, primary key)
  - `user_id` (UUID, foreign key)
  - `content` (TEXT)
  - `sentiment_label` (VARCHAR) - positive/neutral/negative/mixed
  - `created_at` (TIMESTAMP)
  - `updated_at` (TIMESTAMP)

**Security:**
- Row-Level Security (RLS) policies ensure users only access their own entries
- JWT-based authentication via Supabase Auth

### 3. **External Services**

- **Supabase Auth**: User authentication and session management
- **Supabase PostgreSQL**: Persistent data storage
- **Google Gemini API**: AI-powered sentiment analysis

---

## Component Interactions

### Authentication Flow
```
User Input → Auth BloC → Supabase Auth API → JWT Token → Secure Storage → App State Update
```

### Journal Entry Creation Flow
```
User Writes Entry → Journal BloC (validates) → Supabase Insert → 
→ Gemini API (sentiment analysis) → Supabase Update (sentiment_label) → 
→ BloC State Update → UI Refresh
```

### Data Flow Pattern (BLoC)
```
UI Event → BLoC (business logic) → Repository → API/Database → 
→ Repository → BLoC (state emission) → UI Update
```

### State Management
- **flutter_bloc** for reactive state management
- Events trigger state changes through BloCs
- UI listens to state streams and rebuilds reactively
- Clear separation: UI → BLoC → Repository → Data Source

---

## Deployment Architecture

### Development Environment
- **SDK:** Flutter 3.8.1+
- **Language:** Dart
- **IDE:** VS Code / Android Studio
- **Package Manager:** pub

### Build Process
```bash
flutter pub get              # Install dependencies
flutter analyze              # Static analysis
flutter test                 # Run unit tests
flutter build apk            # Android build
flutter build ios            # iOS build (requires macOS)
```

### Environment Configuration
- `.env` file for API keys (gitignored)
- Separate configurations for dev/staging/prod
- Required environment variables:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `GEMINI_API_KEY`

### External Dependencies (To Be Added)
- `supabase_flutter` - Supabase client
- `flutter_bloc` - State management
- `google_generative_ai` - Gemini API integration
- `flutter_dotenv` - Environment variable management
- `shared_preferences` - Local data persistence
- `equatable` - Value equality for state objects

### Platform Targets
- **Primary:** Android, iOS
- **Removed:** Linux, macOS, Windows, Web (focus on mobile)

---

## Runtime Behavior

### Application Initialization
1. Load environment variables from `.env`
2. Initialize Supabase client with credentials
3. Check for existing user session
4. Navigate to Auth screen (if no session) or Home screen (if authenticated)
5. Set up BloC providers for dependency injection

### Request/Response Flow
- **Synchronous:** UI interactions, state updates
- **Asynchronous:** All API calls (Supabase, Gemini)
- **Error Handling:** Try-catch blocks with user-friendly error messages
- **Loading States:** BloCs emit loading states during async operations

### Business Workflows

**User Registration:**
1. Validate email/password format
2. Call Supabase Auth signup
3. Handle errors (email exists, weak password, etc.)
4. Auto-login on success
5. Navigate to Home screen

**Create Journal Entry:**
1. Validate non-empty content
2. Save entry to Supabase (without sentiment initially)
3. Trigger Gemini API call with entry content
4. Parse sentiment response (positive/negative/neutral/mixed)
5. Update entry with sentiment_label
6. Show success feedback with sentiment indicator
7. Navigate back to Home with updated list

**Fetch Journal Entries:**
1. Query Supabase filtered by user_id (enforced by RLS)
2. Order by created_at DESC
3. Display in scrollable list with pull-to-refresh
4. Cache locally for offline viewing (future enhancement)

### Error Management
- Network errors: Show retry option
- API failures: Log error, show user-friendly message
- Authentication errors: Redirect to login
- Validation errors: Inline form feedback
- Gemini API failures: Save entry without sentiment, allow manual retry

### Background Tasks
- Auto-save drafts (future enhancement)
- Periodic session refresh
- Sentiment analysis queue for failed attempts

---

## Design Patterns

- **BLoC Pattern:** Clear separation of business logic and UI
- **Repository Pattern:** Abstract data sources behind interfaces
- **Dependency Injection:** BlocProvider and RepositoryProvider
- **Clean Architecture:** Feature-based folder structure
- **Single Responsibility:** Each BLoC handles one feature domain

---

## Performance Considerations

- Paginated journal entry loading (load 20 at a time)
- Image optimization for profile pictures (future)
- Debouncing search/filter inputs
- Lazy loading for long entry content
- Efficient state updates to minimize rebuilds

---

## Security Measures

- API keys stored in `.env`, never committed to Git
- JWT tokens stored securely
- HTTPS for all API communications
- Input sanitization to prevent injection attacks
- Row-Level Security on database tables
- Sentiment data privacy (not shared externally)

---

## Future Enhancements Roadmap

1. Mood trend visualization (charts/graphs)
2. Entry search and filtering
3. Offline mode with sync
4. Entry editing and deletion
4. Export journal as PDF
5. Reminders/notifications to journal daily
6. Dark mode theme
7. Multi-language support
