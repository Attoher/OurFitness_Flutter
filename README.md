# OurFitness

Dark-themed fitness tracking app for daily activity monitoring, goal streaks, and live run tracking — built with Flutter and Firebase.

- Platform: Android & iOS
- State management: Provider
- Backend: Firebase Auth + Cloud Firestore
- Maps: Google Maps Flutter
- Charts: fl_chart

## Prerequisites

Make sure these are installed:

- Flutter 3.10+: `flutter --version`
- Dart 3.0+: `dart --version`
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled

## App flow and screenshots

The app opens with a splash screen, then checks authentication state. New users land on the onboarding screen.

`[ screenshot: onboarding screen ]`

From onboarding, the user is taken to the login screen to sign in or create an account.

`[ screenshot: login screen ]`

After signing in, the user lands on the **Home** dashboard, showing the three activity rings (steps, calories, move minutes), live heart rate, sleep duration, and connected device status.

`[ screenshot: home screen ]`

Tapping the center button in the bottom navigation opens the **Sport Selection** sheet to start a workout.

`[ screenshot: sport selection bottom sheet ]`

After selecting a sport, the app shows the **Warmup** screen with a pre-run timer before recording begins.

`[ screenshot: warmup screen ]`

Once warmup is done, the **Running Tracker** screen opens with a live Google Maps route trace, and real-time stats — distance, pace, and calories burned.

`[ screenshot: running tracker screen ]`

The **Achievements** tab shows the user's badge collection, streak card, XP level, and weekly goal challenges. When a user earns a badge for the first time, a toast notification slides up from the bottom of the screen with a 5-second countdown bar. The user can swipe it down to dismiss or tap **View** to open the full detail.

`[ screenshot: achievements screen ]` `[ screenshot: badge toast notification ]`

Tapping **View** on the toast — or tapping any earned badge in the grid — opens the **Badge Detail** screen: a full-screen shareable view with an animated sparkle background, glowing badge icon, achievement title, and description.

`[ screenshot: badge detail full screen ]`

The **Statistics** tab displays weekly steps and calories as a bar chart. Days before today show realistic sample data with a "Sample" pill label until real workout data is recorded.

`[ screenshot: statistics — steps ]` `[ screenshot: statistics — calories ]`

The **Profile** tab shows user info, connected device details, and goal settings. Tapping the bell icon opens the **Notification Center** with all achievement and milestone alerts.

`[ screenshot: profile screen ]` `[ screenshot: notification center ]`

## How to run

### 1) Clone and install Flutter deps

```bash
git clone https://github.com/Attoher/OurFitness_Flutter.git
cd OurFitness_Flutter
flutter pub get
```

### 2) Firebase setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and/or iOS app to the project
3. Download config files and place them:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Enable **Email/Password** under Authentication → Sign-in method
5. Create a Firestore database in production mode with these security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### 3) iOS pods (if iOS)

```bash
cd ios && pod install && cd ..
```

Open `ios/Runner.xcworkspace` (not `Runner.xcodeproj`).

### 4) Run the app

```bash
flutter run
```

To select a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

## Project structure

```
lib/
├── main.dart
├── firebase_options.dart
├── theme/
│   └── app_theme.dart
├── models/
│   └── user_model.dart
├── services/
│   ├── auth_service.dart
│   └── fitness_service.dart
├── widgets/
│   ├── activity_rings.dart
│   └── week_day_strip.dart
└── screens/
    ├── main_scaffold.dart
    ├── home_screen.dart
    ├── gamification_screen.dart
    ├── statistics_screen.dart
    ├── profile_screen.dart
    ├── running_tracker_screen.dart
    ├── sport_selection_screen.dart
    ├── notifications_screen.dart
    ├── login_screen.dart
    ├── onboarding_screen.dart
    ├── splash_screen.dart
    └── warmup_screen.dart
```
