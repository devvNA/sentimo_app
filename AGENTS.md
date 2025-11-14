# AGENTS.md - Sentimo AI Sentiment Journal

> A dedicated guide for AI coding agents working on Sentimo project.

---

## Quick Context

**Project:** Sentimo - AI-powered sentiment journal Flutter app  
**Tech Stack:** Flutter, Supabase (Auth + PostgreSQL), BloC, Google Gemini API  
**Target:** Mobile (Android/iOS)

**Key Files:**
- `specs/PRD.md` - Product requirements
- `technical_overview.md` - Architecture details
- `PROGRESS.md` - Project timeline and history

---

## Critical Rules

✅ **ALWAYS consult all 3 files before work:**
   - `specs/PRD.md` - Understand requirements
   - `technical_overview.md` - Follow architecture

✅ **MUST update PROGRESS.md before commits:**
   - Document what was completed
   - Note any blockers or decisions made
   - Update timestamp

✅ **Maintain consistency with patterns:**
   - Follow existing code structure
   - Use established naming conventions
   - Match existing BloC patterns

✅ **Document significant changes:**
   - Update technical_overview.md for architecture changes
   - Add inline comments for complex logic only
   - Keep documentation concise

---

## Project Structure

```
lib/
├── core/
│   ├── config/       # Environment & app configuration
│   ├── theme/        # App theme (calming colors)
│   ├── routing/      # Navigation setup
│   ├── entities/     # Domain models
│   └── widgets/      # Reusable UI components
├── data/
│   ├── repositories/ # Data access layer
│   └── services/     # API clients (Supabase, Gemini)
└── features/
    ├── auth/         # Login/Register + BloC
    ├── home/         # Journal list + BloC
    ├── journal/      # Entry creation + BloC
    └── profile/      # User profile + BloC
```

---

## Development Commands

**Install dependencies:**
```
flutter pub get
```

**Run app:**
```
flutter run
```

**Run tests:**
```
flutter test
```

**Static analysis:**
```
flutter analyze
```

**Build for Android:**
```
flutter build apk --release
```

**Build for iOS:**
```
flutter build ios --release
```

---

## Environment Setup

1. **Copy `.env.example` to `.env`** (if exists, or create new)
2. **Add required keys:**
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   GEMINI_API_KEY=your_gemini_key
   ```
3. **Never commit `.env` file** (already in .gitignore)

---

## Coding Standards

**State Management:**
- Use BloC pattern for all features
- Events → BloC → States → UI
- Keep BloCs focused on single responsibility

**Naming Conventions:**
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `kConstantName` or `CONSTANT_NAME`

**BloC Pattern:**
```dart
// Event
class LoadJournalEntries extends JournalEvent {}

// State
class JournalLoading extends JournalState {}
class JournalLoaded extends JournalState {
  final List<JournalEntry> entries;
}

// BloC
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  // Implementation
}
```

**Color Palette (from PRD):**
- Soft Blue: `#6BA5CF` (primary)
- Mint Green: `#98D8C8` (accent)
- Off-White: `#F7F7F7` (background)
- Dark Gray: `#2C3E50` (text)

---

## Required Dependencies

**Already Added:**
- `cupertino_icons: ^1.0.8`

**To Add (when needed):**
```yaml
dependencies:
  supabase_flutter: ^latest
  flutter_bloc: ^latest
  equatable: ^latest
  google_generative_ai: ^latest
  flutter_dotenv: ^latest
  shared_preferences: ^latest
```

---

## Testing Guidelines

**Unit Tests:**
- Test all BloC logic
- Test repository methods
- Mock external dependencies

**Widget Tests:**
- Test UI components in isolation
- Verify user interactions
- Check state-based rendering

**Integration Tests:**
- Test complete user flows
- Verify Supabase integration
- Check Gemini API integration

---

## Git Workflow

**Before committing:**
1. Run `flutter analyze` - must pass
2. Run `flutter test` - all tests must pass
3. Update `PROGRESS.md` with changes
4. Review changes with `git diff`
5. Check for sensitive data (API keys, tokens)

**Commit message format:**
```
feat: Add authentication page with BloC
fix: Resolve sentiment analysis API error
docs: Update technical overview with new components
```

---

## Common Tasks

**Add new feature:**
1. Create folder in `lib/features/feature_name/`
2. Add `presentation/`, `bloc/` subfolders
3. Implement BloC (events, states, bloc)
4. Create UI pages/widgets
5. Wire up in routing
6. Write tests

**Add new dependency:**
1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Update `technical_overview.md` if significant

**Integrate API:**
1. Create service in `lib/data/services/`
2. Create repository in `lib/data/repositories/`
3. Inject into BloC
4. Handle errors gracefully

---

## Troubleshooting

**Build errors after dependency changes:**
```
flutter clean
flutter pub get
flutter run
```

**Supabase connection issues:**
- Verify `.env` values are correct
- Check Supabase project is active
- Ensure RLS policies are configured

**Gemini API failures:**
- Check API key validity
- Verify API quota/limits
- Implement fallback behavior

---

## Resources

- [Flutter Docs](https://flutter.dev/docs)
- [BloC Library](https://bloclibrary.dev/)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart)
- [Google AI Dart SDK](https://pub.dev/packages/google_generative_ai)

---

## Notes for AI Agents

- **Focus:** Complete one task from `specs/TASKS.md` at a time
- **Architecture:** Follow clean architecture principles
- **Verification:** Always test changes before marking complete
- **Documentation:** Keep technical_overview.md synchronized
- **Security:** Never expose API keys or sensitive data
- **Commits:** Must update PROGRESS.md before every commit

---

*Last Updated: 2025-11-03*
