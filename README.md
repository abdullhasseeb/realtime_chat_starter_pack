# Chatrix — Flutter Realtime Chat Starter Kit

A clean, production-ready starter kit for building realtime chat apps in Flutter with Supabase. This repo is the **foundation layer** — Supabase configuration, app constants, theming, and core utilities — so you're not starting from a blank project every time you want to build a chat app.

> 🎥 This starter kit is the base used in the **full Chatrix build series** on YouTube, where a complete, production-grade chat app (auth, realtime messaging, presence, read receipts, push notifications, and more) is built from scratch, step by step.
>
> ▶️ **Watch the full playlist:** 

---

## What's in this repo

This is **not** the full chat app — it's the reusable foundation other Flutter chat apps can be built on top of:

- Supabase client setup & configuration
- App-wide constants (routes, keys, durations, limits, etc.)
- Theming — light/dark mode, colors, typography
- Core utilities — extensions, helpers, formatters
- Clean architecture folder structure, ready to extend with features

## Tech Stack

- **Flutter** — UI
- **Supabase** — Auth, Postgres, Realtime, Storage
- **BLoC** — State management
- **GetIt** — Dependency injection
- **GoRouter** — Navigation
- **Drift (SQLite)** — Local/offline storage
- **Clean Architecture** — Layered, testable structure

## Why this exists

Theming, constants, dependency injection, and Supabase config take real time to set up correctly before you write a single chat feature. This starter handles that groundwork so you can go straight into building features instead of boilerplate.

## What the full app (built on this starter) includes

Covered end-to-end in the YouTube series:

- Realtime one-to-one messaging
- Typing indicators & online presence
- Message delivery & read receipts
- Offline message queue
- Push notifications (Firebase Cloud Messaging)
- Profile & privacy settings
- Production-grade clean architecture throughout

## Getting Started

1. Clone the repo
   ```bash
   git clone <your-repo-url>
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Create a Supabase project and run the included setup SQL
4. Add your Supabase URL & anon key to the config
5. Run the app
   ```bash
   flutter run
   ```

## Project Structure

```
realtime_chat/
├── lib/
│   ├── common/                 # Shared widgets & cross-feature code
│   ├── data/                   # Data layer (models, repositories, sources)
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   ├── chat/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   ├── personalization/    # Theme & app preferences
│   │   ├── shell/               # App shell / navigation scaffold
│   │   └── users/
│   ├── routes/                  # App routing (GoRouter)
│   ├── utils/                    # Extensions & helpers
│   ├── main.dart
│   └── my_app.dart
├── supabase_utils/              # Supabase setup SQL & configuration
├── android/
├── ios/
├── macos/
├── web/
└── test/
```

## Follow the build

Built and explained step-by-step on the **UnknownPro** YouTube channel — Flutter tutorials, Supabase, and production app architecture.

🔗 https://www.youtube.com/@unknownprogramme
