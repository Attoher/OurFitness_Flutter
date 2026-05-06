# OurFitness

A comprehensive fitness tracking app to monitor your daily activities, set goals, and stay motivated through gamification.

## Features

- 🏠 **Home Dashboard** — Activity rings, heart rate monitoring, and sleep tracking at a glance
- 🏆 **Gamification** — Earn badges, maintain streaks, and complete challenges to stay motivated
- ➕ **Quick Sport Selection** — Floating action button for rapid workout logging
- 📊 **Weekly & Monthly Statistics** — Custom-built charts with detailed insights on your performance
- 👤 **User Profile** — Connected device info and weekly goal configuration
- 🏃 **Running Tracker** — Real-time map visualization with live stats and route tracking
- 🔔 **Smart Notifications** — Alerts for streaks and achievement milestones

## Getting Started

### Prerequisites
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0

### Installation

1. Get dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Architecture Highlights

- **CustomPainter-based UI** — All charts (activity rings, heart rate line, bar charts, line charts), maps, and custom visualizations are built using Flutter's `CustomPainter` for optimal performance
- **Material Design** — Clean, modern interface following Material Design 3 principles
- **State Management** — Efficient state handling with Flutter's built-in mechanisms
- **No Third-Party Chart/Map Libraries** — All visualizations are custom-built for a lightweight app

## Project Structure

```
lib/
├── main.dart                       — App entry point
├── app_theme.dart                  — Theming and color configuration
├── user_model.dart                 — User data model
├── activity_rings.dart             — Custom activity rings widget
├── home_screen.dart                — Home dashboard
├── gamification_screen.dart        — Awards and challenges
├── statistics_screen.dart          — Weekly and monthly stats
├── profile_screen.dart             — User profile and settings
├── running_tracker_screen.dart     — Run tracking with map
├── sport_selection_screen.dart     — Sport/activity selection
├── warmup_screen.dart              — Pre-workout warmup
├── notifications_screen.dart       — Notification center
└── main_scaffold.dart              — Main navigation layout
```

## Navigation

The app uses a bottom navigation bar with 5 primary sections:
- **Home** — Dashboard view
- **Awards** — Gamification and achievements
- **[FAB]** — Quick sport selection (triggers bottom sheet)
- **Statistics** — Performance insights
- **Profile** — User settings and goals

## Color Palette

| Element | Color |
|---------|-------|
| Background | `#0F0F0F` |
| Surface | `#1E1E1E` |
| Surface Light | `#2A2A2A` |
| Accent (Lime) | `#CBEF43` |
| Accent Dark | `#9BBF1A` |
| Heart Rate Red | `#FF5C5C` |
| Cyan / Steps | `#4CD8D8` |
| Purple / Move | `#7B5FDB` |

## License

Proprietary — All rights reserved.
