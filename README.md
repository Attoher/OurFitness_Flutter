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

<p>
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/a00ffd29-cb36-4cc7-8b9b-3a7e2d20f91b" />
  &nbsp;
  <img width="738" height="1600" alt="image" src="https://github.com/user-attachments/assets/7582d450-a148-4cb2-82b6-3264ba265b51" />
</p>

From onboarding, the user is taken to the login screen to sign in or create an account.

<p>
  <img src="https://github.com/user-attachments/assets/cded1de3-1b5d-4fa3-abf0-6bdcbec6d241" width="201" alt="IMG_1974" />
  &nbsp;
  <img src="https://github.com/user-attachments/assets/93465267-671a-428b-9da2-c0b63e4a9bad" width="201" alt="IMG_1975" />
</p>


After signing in, the user lands on the **Home** dashboard, showing the three activity rings (steps, calories, move minutes), live heart rate, sleep duration, and connected device status.

<img width="201" alt="IMG_1976" src="https://github.com/user-attachments/assets/9e464cea-9070-4a86-86e5-e7d7e90ed93b" />


Tapping the center button in the bottom navigation opens the **Sport Selection** sheet to start a workout.

<img width="201" alt="IMG_1977" src="https://github.com/user-attachments/assets/4646b280-ec08-43aa-91b2-a6485af4382d" />


After selecting a sport, the app shows the **Quick Start** screen which user may choose between starting the sport or warming up.

<img width="201" alt="IMG_1978" src="https://github.com/user-attachments/assets/70baa8c6-34b2-4c82-809c-bd09203cd48c" />


If user chooses to warm up, **Warmup** screen with a pre-run timer before recording begins.

<img width="201" alt="IMG_1979" src="https://github.com/user-attachments/assets/abd71c31-3010-4b1d-954b-33d5b9dd6d2b" />


Once warmup is done, the **Running Tracker** screen opens with a live Google Maps route trace, and real-time stats: distance, pace, and calories burned.

<img width="201" alt="IMG_1980" src="https://github.com/user-attachments/assets/eedc8ae4-d0a6-44f5-ae54-be4a98c052ff" />


The **Achievements** tab shows the user's badge collection, streak card, XP level, and weekly goal challenges. 

<img width="201" alt="IMG_1981" src="https://github.com/user-attachments/assets/e439345f-0b08-44ac-a62f-3aea1218d81f" />


Tapping the badge may open the **Badge Detail** screen: a full-screen shareable view with an animated sparkle background, glowing badge icon, achievement title, and description.

<img width="201" alt="IMG_1982" src="https://github.com/user-attachments/assets/73a75479-0f7c-49d1-a5dd-32c14b49e81e" />


The **Statistics** tab displays today's steps and calories, also weekly steps and calories as a bar chart.

<img width="201" alt="Screenshot 2026-05-13 at 00 38 13" src="https://github.com/user-attachments/assets/49909b91-d3d6-424b-a953-f4db04f10d04" />


The **Profile** tab shows user info, connected device details, goals, and daily summary. User may customize their user info and password here. User may also sign out here.

<img width="201" alt="IMG_1984" src="https://github.com/user-attachments/assets/ff0bf10d-b372-4fe0-a967-da801f497859" />


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
