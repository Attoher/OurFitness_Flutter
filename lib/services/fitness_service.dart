import 'dart:async' show StreamSubscription, Timer, unawaited;
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _defaultStepsGoal = 5500;
const _defaultCaloriesGoal = 500;
const _defaultMoveGoal = 50;
const _xpThresholdMultiplier = 1.35;

class DailyStatRecord {
  final DateTime date;
  final int steps;
  final int calories;
  final int moveMinutes;
  final int workoutsCompleted;
  final double distanceKm;
  final int xpEarned;
  final double goalCompletionRate;
  final double consistencyScore;
  final String sleepDuration;

  const DailyStatRecord({
    required this.date,
    required this.steps,
    required this.calories,
    required this.moveMinutes,
    required this.workoutsCompleted,
    required this.distanceKm,
    required this.xpEarned,
    required this.goalCompletionRate,
    required this.consistencyScore,
    required this.sleepDuration,
  });

  factory DailyStatRecord.empty(DateTime date) => DailyStatRecord(
        date: DateTime(date.year, date.month, date.day),
        steps: 0,
        calories: 0,
        moveMinutes: 0,
        workoutsCompleted: 0,
        distanceKm: 0.0,
        xpEarned: 0,
        goalCompletionRate: 0.0,
        consistencyScore: 0.0,
        sleepDuration: '0h 0m',
      );

  factory DailyStatRecord.fromFirestore(String id, Map<String, dynamic> data) {
    final parts = id.split('-');
    final parsedDate = parts.length == 3
        ? DateTime.tryParse('$id 00:00:00') ?? DateTime.now()
        : DateTime.now();
    return DailyStatRecord(
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      steps: (data['steps'] ?? 0) as int,
      calories: (data['calories'] ?? 0) as int,
      moveMinutes: (data['moveMinutes'] ?? 0) as int,
      workoutsCompleted: (data['workoutsCompleted'] ?? 0) as int,
      distanceKm: ((data['distanceKm'] ?? 0) as num).toDouble(),
      xpEarned: (data['xpEarned'] ?? 0) as int,
      goalCompletionRate: ((data['goalCompletionRate'] ?? 0) as num).toDouble(),
      consistencyScore: ((data['consistencyScore'] ?? 0) as num).toDouble(),
      sleepDuration: (data['sleepDuration'] ?? '0h 0m') as String,
    );
  }

  bool get hasActivity =>
      steps > 0 || calories > 0 || moveMinutes > 0 || workoutsCompleted > 0;
}

class WorkoutRecord {
  final String id;
  final String sport;
  final DateTime performedAt;
  final int calories;
  final int steps;
  final int durationMinutes;
  final double distanceKm;
  final int averageHeartRate;
  final int xpEarned;

  const WorkoutRecord({
    required this.id,
    required this.sport,
    required this.performedAt,
    required this.calories,
    required this.steps,
    required this.durationMinutes,
    required this.distanceKm,
    required this.averageHeartRate,
    required this.xpEarned,
  });

  factory WorkoutRecord.fromFirestore(String id, Map<String, dynamic> data) {
    final timestamp = data['date'];
    final performedAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse((data['localDateKey'] ?? '') as String) ?? DateTime.now();
    return WorkoutRecord(
      id: id,
      sport: (data['sport'] ?? 'Workout') as String,
      performedAt: performedAt,
      calories: (data['calories'] ?? 0) as int,
      steps: (data['steps'] ?? 0) as int,
      durationMinutes: (data['durationMinutes'] ?? 0) as int,
      distanceKm: ((data['distanceKm'] ?? 0) as num).toDouble(),
      averageHeartRate: (data['averageHeartRate'] ?? 0) as int,
      xpEarned: (data['xpEarned'] ?? 0) as int,
    );
  }
}

class ChallengeProgress {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final int current;
  final int target;
  final String unit;

  const ChallengeProgress({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.unit,
  });

  double get progress => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
  bool get isCompleted => current >= target;
}

class ProgressSnapshot {
  final int totalSteps;
  final int totalCalories;
  final int totalMoveMinutes;
  final double totalDistanceKm;
  final int totalWorkouts;
  final int activeDays;
  final double goalCompletionRate;
  final double consistencyScore;

  const ProgressSnapshot({
    required this.totalSteps,
    required this.totalCalories,
    required this.totalMoveMinutes,
    required this.totalDistanceKm,
    required this.totalWorkouts,
    required this.activeDays,
    required this.goalCompletionRate,
    required this.consistencyScore,
  });

  String get trackingStatus {
    if (goalCompletionRate >= 0.8 && consistencyScore >= 0.7) {
      return 'On track';
    }
    if (goalCompletionRate >= 0.5 || consistencyScore >= 0.5) {
      return 'Needs focus';
    }
    return 'Off track';
  }
}

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  final Set<int> days;
  final String type;
  final String lastTriggeredOn;
  final bool notifyAchievements;
  final bool notifyReminders;
  final bool notifyWorkouts;

  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.days,
    required this.type,
    required this.lastTriggeredOn,
    required this.notifyAchievements,
    required this.notifyReminders,
    required this.notifyWorkouts,
  });

  factory ReminderSettings.defaults() => const ReminderSettings(
        enabled: false,
        hour: 18,
        minute: 0,
        days: {1, 2, 3, 4, 5, 6, 7},
        type: 'workout',
        lastTriggeredOn: '',
        notifyAchievements: true,
        notifyReminders: true,
        notifyWorkouts: true,
      );

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Set<int>? days,
    String? type,
    String? lastTriggeredOn,
    bool? notifyAchievements,
    bool? notifyReminders,
    bool? notifyWorkouts,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      type: type ?? this.type,
      lastTriggeredOn: lastTriggeredOn ?? this.lastTriggeredOn,
      notifyAchievements: notifyAchievements ?? this.notifyAchievements,
      notifyReminders: notifyReminders ?? this.notifyReminders,
      notifyWorkouts: notifyWorkouts ?? this.notifyWorkouts,
    );
  }

  factory ReminderSettings.fromMap(
    Map<String, dynamic> reminderData,
    Map<String, dynamic> notificationPrefs,
  ) {
    return ReminderSettings(
      enabled: (reminderData['enabled'] ?? false) as bool,
      hour: (reminderData['hour'] ?? 18) as int,
      minute: (reminderData['minute'] ?? 0) as int,
      days: ((reminderData['days'] as List<dynamic>?) ?? const [1, 2, 3, 4, 5, 6, 7])
          .map((day) => day as int)
          .toSet(),
      type: (reminderData['type'] ?? 'workout') as String,
      lastTriggeredOn: (reminderData['lastTriggeredOn'] ?? '') as String,
      notifyAchievements: (notificationPrefs['achievements'] ?? true) as bool,
      notifyReminders: (notificationPrefs['reminders'] ?? true) as bool,
      notifyWorkouts: (notificationPrefs['workouts'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toReminderMap() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'days': days.toList()..sort(),
        'type': type,
        'lastTriggeredOn': lastTriggeredOn,
      };

  Map<String, dynamic> toNotificationPreferences() => {
        'achievements': notifyAchievements,
        'reminders': notifyReminders,
        'workouts': notifyWorkouts,
      };

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

enum FitnessEventType {
  workoutCompleted,
  goalHit,
  streakMilestone,
  weeklyTargetReached,
  dailyReminder,
}

class FitnessService extends ChangeNotifier with WidgetsBindingObserver {
  FitnessService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    bool useFirebase = true,
  })  : _useFirebase = useFirebase,
        _firestore = useFirebase ? (firestore ?? FirebaseFirestore.instance) : null,
        _auth = useFirebase ? (auth ?? FirebaseAuth.instance) : null {
    WidgetsBinding.instance.addObserver(this);
    if (_useFirebase && _auth != null) {
      _authSubscription = _auth!.authStateChanges().listen((user) {
        if (user != null) {
          _listenToUserData(user.uid);
        } else {
          _disposeDataSubscriptions();
          _resetData();
        }
      });
    } else {
      _isLoading = false;
    }
  }

  final bool _useFirebase;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _dailyStatsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _badgesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificationsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _workoutsSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _weeklyChallengeSubscription;
  Timer? _reminderTimer;

  bool _isLoading = true;
  String? _errorMessage;
  bool _hasLoadedProfile = false;
  bool _hasLoadedDailyStats = false;
  String? _currentUid;
  String? _pendingRegistrationName;

  String _displayName = 'User';
  int _age = 21;
  double _height = 160;
  double _weight = 58;
  String _deviceName = 'Samsung Watch';
  int _batteryLevel = 85;
  bool _isDeviceConnected = true;
  String _timezone = DateTime.now().timeZoneName;

  int _steps = 0;
  int _stepsGoal = _defaultStepsGoal;
  int _calories = 0;
  int _caloriesGoal = _defaultCaloriesGoal;
  int _moveMinutes = 0;
  int _moveMinutesGoal = _defaultMoveGoal;
  int _heartRate = 68;
  String _sleepDuration = '7h 24m';

  int _streak = 0;
  int _longestStreak = 0;
  String _lastWorkoutDate = '';
  int _level = 1;
  int _xp = 0;
  int _xpNextLevel = 1000;

  List<Map<String, dynamic>> _badges = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _notifications = <Map<String, dynamic>>[];
  Map<String, dynamic>? _pendingBadgeToast;
  List<DailyStatRecord> _dailyStats = <DailyStatRecord>[];
  List<WorkoutRecord> _recentWorkouts = <WorkoutRecord>[];
  List<ChallengeProgress> _weeklyChallenges = <ChallengeProgress>[];

  ReminderSettings _reminderSettings = ReminderSettings.defaults();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAnyHistory => _dailyStats.any((record) => record.hasActivity);
  bool get isFirebaseEnabled => _useFirebase;

  String get displayName => _displayName;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;
  String get deviceName => _deviceName;
  int get batteryLevel => _batteryLevel;
  bool get isDeviceConnected => _isDeviceConnected;
  String get timezone => _timezone;

  int get steps => _steps;
  int get stepsGoal => _stepsGoal;
  double get stepsProgress => _goalProgress(_steps, _stepsGoal);
  int get calories => _calories;
  int get caloriesGoal => _caloriesGoal;
  double get caloriesProgress => _goalProgress(_calories, _caloriesGoal);
  int get moveMinutes => _moveMinutes;
  int get moveMinutesGoal => _moveMinutesGoal;
  double get moveMinutesProgress => _goalProgress(_moveMinutes, _moveMinutesGoal);
  int get heartRate => _heartRate;
  String get sleepDuration => _sleepDuration;

  int get streak => _streak;
  int get longestStreak => _longestStreak;
  int get level => _level;
  int get xp => _xp;
  int get xpNextLevel => _xpNextLevel;
  double get levelProgress => _goalProgress(_xp, _xpNextLevel);

  List<Map<String, dynamic>> get badges => List.unmodifiable(_badges);
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  List<WorkoutRecord> get recentWorkouts => List.unmodifiable(_recentWorkouts);
  List<ChallengeProgress> get weeklyChallenges => List.unmodifiable(_weeklyChallenges);
  List<DailyStatRecord> get dailyStats => List.unmodifiable(_dailyStats);
  ReminderSettings get reminderSettings => _reminderSettings;
  Map<String, dynamic>? get pendingBadgeToast => _pendingBadgeToast;

  List<double> get weeklySteps =>
      recordsBetween(DateTime.now().subtract(const Duration(days: 6)), DateTime.now())
          .map((record) => record.steps.toDouble())
          .toList();

  List<double> get weeklyCalories =>
      recordsBetween(DateTime.now().subtract(const Duration(days: 6)), DateTime.now())
          .map((record) => record.calories.toDouble())
          .toList();

  void setPendingRegistrationName(String name) {
    _pendingRegistrationName = name;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkReminderDue(forceCheck: true));
    }
  }

  void consumeBadgeToast() {
    _pendingBadgeToast = null;
  }

  List<DailyStatRecord> recordsBetween(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    final recordByKey = <String, DailyStatRecord>{
      for (final record in _dailyStats) _localDateKey(record.date): record,
    };
    final records = <DailyStatRecord>[];
    for (
      DateTime cursor = normalizedStart;
      !cursor.isAfter(normalizedEnd);
      cursor = cursor.add(const Duration(days: 1))
    ) {
      final key = _localDateKey(cursor);
      records.add(recordByKey[key] ?? DailyStatRecord.empty(cursor));
    }
    return records;
  }

  ProgressSnapshot snapshotBetween(DateTime start, DateTime end) {
    final records = recordsBetween(start, end);
    if (records.isEmpty) {
      return const ProgressSnapshot(
        totalSteps: 0,
        totalCalories: 0,
        totalMoveMinutes: 0,
        totalDistanceKm: 0.0,
        totalWorkouts: 0,
        activeDays: 0,
        goalCompletionRate: 0,
        consistencyScore: 0,
      );
    }

    var totalSteps = 0;
    var totalCalories = 0;
    var totalMoveMinutes = 0;
    var totalWorkouts = 0;
    var activeDays = 0;
    var totalDistance = 0.0;
    var completionAccumulator = 0.0;

    for (final record in records) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalMoveMinutes += record.moveMinutes;
      totalWorkouts += record.workoutsCompleted;
      totalDistance += record.distanceKm;
      completionAccumulator += record.goalCompletionRate;
      if (record.hasActivity) {
        activeDays++;
      }
    }

    final recordCount = records.length;
    final consistencyScore = recordCount == 0 ? 0.0 : activeDays / recordCount;

    return ProgressSnapshot(
      totalSteps: totalSteps,
      totalCalories: totalCalories,
      totalMoveMinutes: totalMoveMinutes,
      totalDistanceKm: totalDistance,
      totalWorkouts: totalWorkouts,
      activeDays: activeDays,
      goalCompletionRate: recordCount == 0 ? 0.0 : completionAccumulator / recordCount,
      consistencyScore: consistencyScore,
    );
  }

  Future<String?> updateGoals({
    int? stepsGoal,
    int? caloriesGoal,
    int? moveMinutesGoal,
  }) async {
    if (!_canWriteToFirebase) {
      return 'Firebase is not configured.';
    }
    if (stepsGoal != null && stepsGoal <= 0) {
      return 'Steps goal must be greater than 0.';
    }
    if (caloriesGoal != null && caloriesGoal <= 0) {
      return 'Calories goal must be greater than 0.';
    }
    if (moveMinutesGoal != null && moveMinutesGoal <= 0) {
      return 'Move minutes goal must be greater than 0.';
    }

    final uid = _auth!.currentUser?.uid;
    if (uid == null) {
      return 'User is not signed in.';
    }

    final updates = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (stepsGoal != null) {
      updates['goals.steps'] = stepsGoal;
      updates['stepsGoal'] = stepsGoal;
    }
    if (caloriesGoal != null) {
      updates['goals.calories'] = caloriesGoal;
      updates['caloriesGoal'] = caloriesGoal;
    }
    if (moveMinutesGoal != null) {
      updates['goals.moveMinutes'] = moveMinutesGoal;
      updates['moveMinutesGoal'] = moveMinutesGoal;
    }

    await _firestore!.collection('users').doc(uid).set(updates, SetOptions(merge: true));
    await _ensureWeeklyChallengeDoc(uid);
    final weekKey = _localDateKey(_startOfWeek(DateTime.now()));
    await _firestore!
        .collection('users')
        .doc(uid)
        .collection('weekly_challenges')
        .doc(weekKey)
        .set({
      'targets.activeMinutes': math.max((moveMinutesGoal ?? _moveMinutesGoal) * 5, 150),
      'targets.calories': math.max((caloriesGoal ?? _caloriesGoal) * 4, 1800),
      'targets.steps': math.max((stepsGoal ?? _stepsGoal) * 5, 30000),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return null;
  }

  Future<String?> updateProfile({
    String? name,
    int? age,
    double? height,
    double? weight,
  }) async {
    if (!_canWriteToFirebase) {
      return 'Firebase is not configured.';
    }
    final uid = _auth!.currentUser?.uid;
    if (uid == null) {
      return 'User is not signed in.';
    }

    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isEmpty) {
      return 'Display name cannot be empty.';
    }
    if (age != null && (age < 10 || age > 100)) {
      return 'Age must be between 10 and 100.';
    }
    if (height != null && (height < 80 || height > 250)) {
      return 'Height must be between 80 and 250 cm.';
    }
    if (weight != null && (weight < 20 || weight > 300)) {
      return 'Weight must be between 20 and 300 kg.';
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'timezone': DateTime.now().timeZoneName,
    };
    if (trimmedName != null) {
      updates['profile.displayName'] = trimmedName;
      updates['displayName'] = trimmedName;
      await _auth!.currentUser?.updateDisplayName(trimmedName);
    }
    if (age != null) {
      updates['profile.age'] = age;
      updates['age'] = age;
    }
    if (height != null) {
      updates['profile.height'] = height;
      updates['height'] = height;
    }
    if (weight != null) {
      updates['profile.weight'] = weight;
      updates['weight'] = weight;
    }

    await _firestore!.collection('users').doc(uid).set(updates, SetOptions(merge: true));
    await _ensureWeeklyChallengeDoc(uid);
    final weekKey = _localDateKey(_startOfWeek(DateTime.now()));
    await _firestore!
        .collection('users')
        .doc(uid)
        .collection('weekly_challenges')
        .doc(weekKey)
        .set({
      'targets.activeMinutes': math.max((moveMinutesGoal ?? _moveMinutesGoal) * 5, 150),
      'targets.calories': math.max((caloriesGoal ?? _caloriesGoal) * 4, 1800),
      'targets.steps': math.max((stepsGoal ?? _stepsGoal) * 5, 30000),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return null;
  }

  Future<String?> updateReminderSettings(ReminderSettings settings) async {
    if (!_canWriteToFirebase) {
      return 'Firebase is not configured.';
    }
    final uid = _auth!.currentUser?.uid;
    if (uid == null) {
      return 'User is not signed in.';
    }
    if (settings.days.isEmpty && settings.enabled) {
      return 'Select at least one reminder day.';
    }

    _reminderSettings = settings;
    notifyListeners();

    await _firestore!.collection('users').doc(uid).set({
      'reminderSettings': settings.toReminderMap(),
      'notificationPreferences': settings.toNotificationPreferences(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    unawaited(_checkReminderDue(forceCheck: true));
    return null;
  }

  Future<void> markNotificationRead(String notificationId) async {
    if (!_canWriteToFirebase) {
      return;
    }
    final uid = _auth!.currentUser?.uid;
    if (uid == null) {
      return;
    }
    await _firestore!
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .set({'read': true}, SetOptions(merge: true));
  }

  Future<void> addSteps(int count) async {
    if (!_canWriteToFirebase || count <= 0) {
      return;
    }
    final uid = _auth!.currentUser?.uid;
    if (uid == null) {
      return;
    }
    final now = DateTime.now();
    final dailyRef = _firestore!
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(_localDateKey(now));
    final userRef = _firestore!.collection('users').doc(uid);

    await _firestore!.runTransaction((transaction) async {
      final dailySnap = await transaction.get(dailyRef);
      final userSnap = await transaction.get(userRef);
      final data = dailySnap.data() ?? <String, dynamic>{};
      final userData = userSnap.data() ?? <String, dynamic>{};
      final currentSteps = (data['steps'] ?? 0) as int;
      final newSteps = currentSteps + count;
      final newCalories = (newSteps * 0.04).round();
      final moveMinutes = (newSteps * 0.01).round();
      final xpEarned = math.max(5, (count * 0.08).round());
      final gamification = _readGamification(userData);
      final leveled = _applyXp(
        currentXp: gamification.currentXp,
        currentLevel: gamification.level,
        nextLevelXp: gamification.nextLevelXp,
        xpEarned: xpEarned,
      );
      transaction.set(dailyRef, {
        'date': _localDateKey(now),
        'steps': newSteps,
        'calories': newCalories,
        'moveMinutes': moveMinutes,
        'goalCompletionRate': _calculateGoalCompletionRate(
          steps: newSteps,
          calories: newCalories,
          moveMinutes: moveMinutes,
          stepsGoal: _readGoals(userData).stepsGoal,
          caloriesGoal: _readGoals(userData).caloriesGoal,
          moveGoal: _readGoals(userData).moveMinutesGoal,
        ),
        'consistencyScore': moveMinutes > 0 ? 0.5 : 0.0,
        'xpEarned': (data['xpEarned'] ?? 0) as int + xpEarned,
        'updatedAt': FieldValue.serverTimestamp(),
        'timezone': DateTime.now().timeZoneName,
      }, SetOptions(merge: true));
      transaction.set(userRef, {
        'gamification.level': leveled.level,
        'gamification.xp': leveled.currentXp,
        'gamification.xpNextLevel': leveled.nextLevelXp,
        'level': leveled.level,
        'xp': leveled.currentXp,
        'xpNextLevel': leveled.nextLevelXp,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> addWorkoutResult({
    required String sport,
    required int calories,
    required int steps,
    required int durationMinutes,
    double distanceKm = 0,
    int averageHeartRate = 0,
    List<Map<String, double>>? route,
  }) async {
    if (!_canWriteToFirebase) {
      return;
    }
    final uid = _auth!.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final now = DateTime.now();
    final dayKey = _localDateKey(now);
    final weekStart = _startOfWeek(now);
    final weekKey = _localDateKey(weekStart);

    final userRef = _firestore!.collection('users').doc(uid);
    final dailyRef = userRef.collection('daily_stats').doc(dayKey);
    final workoutRef = userRef.collection('workouts').doc();
    final weeklyRef = userRef.collection('weekly_challenges').doc(weekKey);

    final outcome = await _firestore!.runTransaction<_WorkoutOutcome>((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) {
        transaction.set(userRef, _buildInitialProfileData(uid));
      }
      final userData = userSnap.data() ?? <String, dynamic>{};
      final dailySnap = await transaction.get(dailyRef);
      final dailyData = dailySnap.data() ?? <String, dynamic>{};
      final weeklySnap = await transaction.get(weeklyRef);
      final weeklyData = weeklySnap.data() ?? _defaultWeeklyChallengeDoc(weekStart, userData);

      final goals = _readGoals(userData);
      final streakData = _readStreak(userData);
      final gamification = _readGamification(userData);

      final currentSteps = (dailyData['steps'] ?? 0) as int;
      final currentCalories = (dailyData['calories'] ?? 0) as int;
      final currentMoveMinutes = (dailyData['moveMinutes'] ?? 0) as int;
      final currentWorkouts = (dailyData['workoutsCompleted'] ?? 0) as int;
      final currentDistance = ((dailyData['distanceKm'] ?? 0) as num).toDouble();
      final currentDailyXp = (dailyData['xpEarned'] ?? 0) as int;

      final newSteps = currentSteps + steps;
      final newCalories = currentCalories + calories;
      final newMoveMinutes = currentMoveMinutes + durationMinutes;
      final newWorkouts = currentWorkouts + 1;
      final newDistance = currentDistance + distanceKm;
      final xpEarned = _calculateWorkoutXp(
        calories: calories,
        steps: steps,
        durationMinutes: durationMinutes,
        distanceKm: distanceKm,
      );
      final leveled = _applyXp(
        currentXp: gamification.currentXp,
        currentLevel: gamification.level,
        nextLevelXp: gamification.nextLevelXp,
        xpEarned: xpEarned,
      );

      final newGoalCompletion = _calculateGoalCompletionRate(
        steps: newSteps,
        calories: newCalories,
        moveMinutes: newMoveMinutes,
        stepsGoal: goals.stepsGoal,
        caloriesGoal: goals.caloriesGoal,
        moveGoal: goals.moveMinutesGoal,
      );
      final goalHits = <String>[];
      if (currentSteps < goals.stepsGoal && newSteps >= goals.stepsGoal) {
        goalHits.add('steps');
      }
      if (currentCalories < goals.caloriesGoal && newCalories >= goals.caloriesGoal) {
        goalHits.add('calories');
      }
      if (currentMoveMinutes < goals.moveMinutesGoal && newMoveMinutes >= goals.moveMinutesGoal) {
        goalHits.add('move');
      }

      final previousStreak = streakData.currentStreak;
      var nextStreak = streakData.currentStreak;
      if (streakData.lastWorkoutDate == dayKey) {
        nextStreak = streakData.currentStreak == 0 ? 1 : streakData.currentStreak;
      } else if (streakData.lastWorkoutDate == _localDateKey(now.subtract(const Duration(days: 1)))) {
        nextStreak = streakData.currentStreak + 1;
      } else {
        nextStreak = 1;
      }
      final longestStreak = math.max(streakData.longestStreak, nextStreak);

      final currentProgress = Map<String, dynamic>.from(
        (weeklyData['current'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      );
      final targets = Map<String, dynamic>.from(
        (weeklyData['targets'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      );
      final previousChallengeProgress = Map<String, int>.fromEntries(
        currentProgress.entries.map((entry) => MapEntry(entry.key, (entry.value ?? 0) as int)),
      );
      currentProgress['workouts'] = (currentProgress['workouts'] ?? 0) as int + 1;
      currentProgress['activeMinutes'] =
          (currentProgress['activeMinutes'] ?? 0) as int + durationMinutes;
      currentProgress['calories'] = (currentProgress['calories'] ?? 0) as int + calories;
      currentProgress['steps'] = (currentProgress['steps'] ?? 0) as int + steps;
      final completedChallenges = <String>[];
      for (final entry in targets.entries) {
        final targetValue = (entry.value ?? 0) as int;
        final before = previousChallengeProgress[entry.key] ?? 0;
        final after = (currentProgress[entry.key] ?? 0) as int;
        if (targetValue > 0 && before < targetValue && after >= targetValue) {
          completedChallenges.add(entry.key);
        }
      }

      final dailyConsistency = ((newGoalCompletion + (newWorkouts > 0 ? 1 : 0)) / 2).clamp(0.0, 1.0);

      transaction.set(dailyRef, {
        'date': dayKey,
        'steps': newSteps,
        'calories': newCalories,
        'moveMinutes': newMoveMinutes,
        'workoutsCompleted': newWorkouts,
        'distanceKm': newDistance,
        'xpEarned': currentDailyXp + xpEarned,
        'goalCompletionRate': newGoalCompletion,
        'consistencyScore': dailyConsistency,
        'sleepDuration': (dailyData['sleepDuration'] ?? _sleepDuration) as String,
        'updatedAt': FieldValue.serverTimestamp(),
        'timezone': DateTime.now().timeZoneName,
      }, SetOptions(merge: true));

      transaction.set(workoutRef, {
        'sport': sport,
        'date': FieldValue.serverTimestamp(),
        'localDateKey': dayKey,
        'weekKey': weekKey,
        'calories': calories,
        'steps': steps,
        'durationMinutes': durationMinutes,
        'distanceKm': distanceKm,
        'averageHeartRate': averageHeartRate,
        'route': route ?? <Map<String, double>>[],
        'xpEarned': xpEarned,
        'timezone': DateTime.now().timeZoneName,
      });

      transaction.set(weeklyRef, {
        'weekKey': weekKey,
        'startsAt': weekStart.toIso8601String(),
        'current': currentProgress,
        'targets': targets,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(userRef, {
        'streak.current': nextStreak,
        'streak.longest': longestStreak,
        'streak.lastWorkoutDate': dayKey,
        'streak': nextStreak,
        'longestStreak': longestStreak,
        'lastWorkoutDate': dayKey,
        'gamification.level': leveled.level,
        'gamification.xp': leveled.currentXp,
        'gamification.xpNextLevel': leveled.nextLevelXp,
        'level': leveled.level,
        'xp': leveled.currentXp,
        'xpNextLevel': leveled.nextLevelXp,
        'timezone': DateTime.now().timeZoneName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return _WorkoutOutcome(
        uid: uid,
        workoutId: workoutRef.id,
        sport: sport,
        calories: calories,
        steps: steps,
        durationMinutes: durationMinutes,
        xpEarned: xpEarned,
        previousStreak: previousStreak,
        currentStreak: nextStreak,
        longestStreak: longestStreak,
        goalHits: goalHits,
        completedChallenges: completedChallenges,
        newGoalCompletion: newGoalCompletion,
      );
    });

    await _handleWorkoutOutcome(outcome);
  }

  void _listenToUserData(String uid) {
    _currentUid = uid;
    _disposeDataSubscriptions();
    _isLoading = true;
    _errorMessage = null;
    _hasLoadedProfile = false;
    _hasLoadedDailyStats = false;
    _weeklyChallenges = _buildWeeklyChallenges(null);
    notifyListeners();

    _ensureWeeklyChallengeDoc(uid);

    _profileSubscription = _firestore!
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(_onProfileSnapshot, onError: _handleStreamError);

    _dailyStatsSubscription = _firestore!
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .orderBy(FieldPath.documentId, descending: false)
        .snapshots()
        .listen(_onDailyStatsSnapshot, onError: _handleStreamError);

    _badgesSubscription = _firestore!
        .collection('users')
        .doc(uid)
        .collection('badges')
        .snapshots()
        .listen((snapshot) {
      _badges = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
                'icon': _getIconData(doc.data()['icon'] as String?),
              })
          .toList()
        ..sort((a, b) {
          final aDone = (a['done'] ?? false) as bool;
          final bDone = (b['done'] ?? false) as bool;
          if (aDone == bDone) {
            return (a['title'] as String).compareTo(b['title'] as String);
          }
          return aDone ? -1 : 1;
        });
      notifyListeners();
    }, onError: _handleStreamError);

    _notificationsSubscription = _firestore!
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'icon': _getIconData(data['icon'] as String?),
          'time': _formatNotificationTime(data['time']),
          'isNew': !((data['read'] ?? false) as bool),
        };
      }).toList();
      notifyListeners();
    }, onError: _handleStreamError);

    _workoutsSubscription = _firestore!
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('date', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      _recentWorkouts = snapshot.docs
          .map((doc) => WorkoutRecord.fromFirestore(doc.id, doc.data()))
          .toList();
      notifyListeners();
    }, onError: _handleStreamError);

    _weeklyChallengeSubscription = _firestore!
        .collection('users')
        .doc(uid)
        .collection('weekly_challenges')
        .doc(_localDateKey(_startOfWeek(DateTime.now())))
        .snapshots()
        .listen((snapshot) {
      _weeklyChallenges = _buildWeeklyChallenges(snapshot.data());
      notifyListeners();
    }, onError: _handleStreamError);

    _startReminderTimer();
    unawaited(_checkReminderDue(forceCheck: true));
  }

  void _onProfileSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists) {
      if (_currentUid != null) {
        unawaited(_createInitialProfile(_currentUid!));
      }
      return;
    }

    final data = snapshot.data()!;
    final profile = (data['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final device = (data['device'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final goals = _readGoals(data);
    final streakData = _readStreak(data);
    final gamification = _readGamification(data);
    final reminderData = (data['reminderSettings'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final notificationPrefs = (data['notificationPreferences'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    _displayName = (profile['displayName'] ?? data['displayName'] ?? _displayName) as String;
    _age = (profile['age'] ?? data['age'] ?? _age) as int;
    _height = ((profile['height'] ?? data['height'] ?? _height) as num).toDouble();
    _weight = ((profile['weight'] ?? data['weight'] ?? _weight) as num).toDouble();
    _deviceName = (device['name'] ?? data['deviceName'] ?? _deviceName) as String;
    _batteryLevel = (device['batteryLevel'] ?? data['batteryLevel'] ?? _batteryLevel) as int;
    _isDeviceConnected =
        (device['isConnected'] ?? data['isDeviceConnected'] ?? _isDeviceConnected) as bool;
    _stepsGoal = goals.stepsGoal;
    _caloriesGoal = goals.caloriesGoal;
    _moveMinutesGoal = goals.moveMinutesGoal;
    _streak = streakData.currentStreak;
    _longestStreak = streakData.longestStreak;
    _lastWorkoutDate = streakData.lastWorkoutDate;
    _level = gamification.level;
    _xp = gamification.currentXp;
    _xpNextLevel = gamification.nextLevelXp;
    _timezone = (data['timezone'] ?? DateTime.now().timeZoneName) as String;
    _reminderSettings = ReminderSettings.fromMap(reminderData, notificationPrefs);

    _hasLoadedProfile = true;
    _refreshLoadingState();
    notifyListeners();
  }

  void _onDailyStatsSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    _dailyStats = snapshot.docs
        .map((doc) => DailyStatRecord.fromFirestore(doc.id, doc.data()))
        .toList();

    final todayRecord = _dailyStats.isEmpty
        ? DailyStatRecord.empty(DateTime.now())
        : _dailyStats.firstWhere(
            (record) => _localDateKey(record.date) == _localDateKey(DateTime.now()),
            orElse: () => DailyStatRecord.empty(DateTime.now()),
          );

    _steps = todayRecord.steps;
    _calories = todayRecord.calories;
    _moveMinutes = todayRecord.moveMinutes;
    _sleepDuration = todayRecord.sleepDuration == '0h 0m' ? _sleepDuration : todayRecord.sleepDuration;
    _heartRate = _recentWorkouts.isNotEmpty
        ? math.max(62, _recentWorkouts.first.averageHeartRate)
        : 68;

    _hasLoadedDailyStats = true;
    _refreshLoadingState();
    notifyListeners();
  }

  void _refreshLoadingState() {
    _isLoading = !(_hasLoadedProfile && _hasLoadedDailyStats);
  }

  void _handleStreamError(Object error) {
    _errorMessage = error.toString();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _createInitialProfile(String uid) async {
    if (!_canWriteToFirebase) {
      return;
    }
    final data = _buildInitialProfileData(uid);
    await _firestore!.collection('users').doc(uid).set(data, SetOptions(merge: true));
    await _ensureWeeklyChallengeDoc(uid);
    await _awardBadge(
      uid: uid,
      badgeId: 'first_step',
      icon: 'rocket_launch',
      title: 'First Step',
      desc: 'Joined OurFitness',
      detail:
          'You took the first step toward a healthier life. Every legend starts somewhere — this is your origin story.',
      earnedOn: 'Today',
    );
    await _pushNotification(
      uid: uid,
      icon: 'rocket_launch',
      title: 'Badge unlocked: First Step',
      body: 'Welcome to OurFitness! Your profile and initial goals are ready.',
      type: 'achievement',
    );
  }

  Map<String, dynamic> _buildInitialProfileData(String uid) {
    final name = _pendingRegistrationName ?? _auth?.currentUser?.displayName ?? 'User';
    _pendingRegistrationName = null;
    final now = DateTime.now();
    return {
      'profile': {
        'displayName': name,
        'age': 21,
        'height': 160.0,
        'weight': 58.0,
      },
      'displayName': name,
      'age': 21,
      'height': 160.0,
      'weight': 58.0,
      'device': {
        'name': 'Samsung Watch',
        'batteryLevel': 85,
        'isConnected': true,
      },
      'deviceName': 'Samsung Watch',
      'batteryLevel': 85,
      'isDeviceConnected': true,
      'goals': {
        'steps': _defaultStepsGoal,
        'calories': _defaultCaloriesGoal,
        'moveMinutes': _defaultMoveGoal,
      },
      'stepsGoal': _defaultStepsGoal,
      'caloriesGoal': _defaultCaloriesGoal,
      'moveMinutesGoal': _defaultMoveGoal,
      'streak': {
        'current': 0,
        'longest': 0,
        'lastWorkoutDate': '',
      },
      'longestStreak': 0,
      'lastWorkoutDate': '',
      'gamification': {
        'level': 1,
        'xp': 0,
        'xpNextLevel': 1000,
      },
      'level': 1,
      'xp': 0,
      'xpNextLevel': 1000,
      'reminderSettings': ReminderSettings.defaults().toReminderMap(),
      'notificationPreferences': ReminderSettings.defaults().toNotificationPreferences(),
      'timezone': now.timeZoneName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> _ensureWeeklyChallengeDoc(String uid) async {
    if (!_canWriteToFirebase) {
      return;
    }
    final weekStart = _startOfWeek(DateTime.now());
    final weekKey = _localDateKey(weekStart);
    final ref = _firestore!
        .collection('users')
        .doc(uid)
        .collection('weekly_challenges')
        .doc(weekKey);
    final doc = await ref.get();
    if (!doc.exists) {
      final userDoc = await _firestore!.collection('users').doc(uid).get();
      await ref.set(_defaultWeeklyChallengeDoc(weekStart, userDoc.data() ?? const <String, dynamic>{}));
    }
  }

  Map<String, dynamic> _defaultWeeklyChallengeDoc(
    DateTime weekStart,
    Map<String, dynamic> userData,
  ) {
    final goals = _readGoals(userData);
    return {
      'weekKey': _localDateKey(weekStart),
      'startsAt': weekStart.toIso8601String(),
      'current': {
        'workouts': 0,
        'activeMinutes': 0,
        'calories': 0,
        'steps': 0,
      },
      'targets': {
        'workouts': 4,
        'activeMinutes': math.max(goals.moveMinutesGoal * 5, 150),
        'calories': math.max(goals.caloriesGoal * 4, 1800),
        'steps': math.max(goals.stepsGoal * 5, 30000),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  List<ChallengeProgress> _buildWeeklyChallenges(Map<String, dynamic>? doc) {
    final current = Map<String, dynamic>.from((doc?['current'] as Map<String, dynamic>?) ?? const <String, dynamic>{});
    final targets = Map<String, dynamic>.from((doc?['targets'] as Map<String, dynamic>?) ?? {
      'workouts': 4,
      'activeMinutes': math.max(_moveMinutesGoal * 5, 150),
      'calories': math.max(_caloriesGoal * 4, 1800),
      'steps': math.max(_stepsGoal * 5, 30000),
    });

    return <ChallengeProgress>[
      ChallengeProgress(
        id: 'workouts',
        icon: Icons.fitness_center_rounded,
        title: 'Weekly workouts',
        description: 'Selesaikan sesi latihan minggu ini.',
        current: (current['workouts'] ?? 0) as int,
        target: (targets['workouts'] ?? 4) as int,
        unit: 'sessions',
      ),
      ChallengeProgress(
        id: 'activeMinutes',
        icon: Icons.timer_rounded,
        title: 'Active minutes',
        description: 'Akumulasi menit aktif selama minggu berjalan.',
        current: (current['activeMinutes'] ?? 0) as int,
        target: (targets['activeMinutes'] ?? math.max(_moveMinutesGoal * 5, 150)) as int,
        unit: 'min',
      ),
      ChallengeProgress(
        id: 'calories',
        icon: Icons.local_fire_department_rounded,
        title: 'Calories burned',
        description: 'Bakar kalori sesuai target mingguan.',
        current: (current['calories'] ?? 0) as int,
        target: (targets['calories'] ?? math.max(_caloriesGoal * 4, 1800)) as int,
        unit: 'kcal',
      ),
      ChallengeProgress(
        id: 'steps',
        icon: Icons.directions_walk_rounded,
        title: 'Weekly steps',
        description: 'Capai target langkah mingguan.',
        current: (current['steps'] ?? 0) as int,
        target: (targets['steps'] ?? math.max(_stepsGoal * 5, 30000)) as int,
        unit: 'steps',
      ),
    ];
  }

  Future<void> _handleWorkoutOutcome(_WorkoutOutcome outcome) async {
    final events = <FitnessEventType>[FitnessEventType.workoutCompleted];
    if (outcome.goalHits.isNotEmpty) {
      events.add(FitnessEventType.goalHit);
    }
    if (outcome.currentStreak > outcome.previousStreak && outcome.currentStreak >= 3) {
      events.add(FitnessEventType.streakMilestone);
    }
    if (outcome.completedChallenges.isNotEmpty) {
      events.add(FitnessEventType.weeklyTargetReached);
    }

    for (final event in events) {
      switch (event) {
        case FitnessEventType.workoutCompleted:
          if (_reminderSettings.notifyWorkouts) {
            await _pushNotification(
              uid: outcome.uid,
              icon: 'directions_run',
              title: 'Workout tersimpan',
              body:
                  '${outcome.sport} selesai. +${outcome.xpEarned} XP, ${outcome.durationMinutes} menit aktif.',
              type: 'workout',
            );
          }
          await _maybeAwardWorkoutBadges(outcome);
          break;
        case FitnessEventType.goalHit:
          if (_reminderSettings.notifyAchievements) {
            await _pushNotification(
              uid: outcome.uid,
              icon: 'bolt',
              title: 'Goal harian tercapai',
              body:
                  'Kamu menyelesaikan ${outcome.goalHits.length} target harian hari ini.',
              type: 'achievement',
            );
          }
          if (outcome.goalHits.length == 3) {
            await _awardBadge(
              uid: outcome.uid,
              badgeId: 'daily_crusher',
              icon: 'bolt',
              title: 'Daily Crusher',
              desc: 'All daily goals completed',
              detail: 'Semua target harianmu tercapai dalam satu hari. Momentum seperti ini penting untuk progres jangka panjang.',
              earnedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
            );
          }
          break;
        case FitnessEventType.streakMilestone:
          await _pushNotification(
            uid: outcome.uid,
            icon: 'local_fire_department',
            title: 'Streak ${outcome.currentStreak} hari',
            body: 'Pertahankan konsistensi latihanmu untuk menjaga streak tetap hidup.',
            type: 'achievement',
          );
          if (outcome.currentStreak >= 7) {
            await _awardBadge(
              uid: outcome.uid,
              badgeId: 'streak_7',
              icon: 'local_fire_department',
              title: '7-Day Streak',
              desc: '7 hari aktif berturut-turut',
              detail: 'Kamu menjaga ritme latihan selama tujuh hari beruntun. Ini adalah fondasi konsistensi yang nyata.',
              earnedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
            );
          } else if (outcome.currentStreak >= 3) {
            await _awardBadge(
              uid: outcome.uid,
              badgeId: 'streak_3',
              icon: 'local_fire_department',
              title: '3-Day Streak',
              desc: '3 hari aktif berturut-turut',
              detail: 'Tiga hari konsisten adalah bukti bahwa rutinitasmu mulai terbentuk.',
              earnedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
            );
          }
          break;
        case FitnessEventType.weeklyTargetReached:
          await _pushNotification(
            uid: outcome.uid,
            icon: 'workspace_premium',
            title: 'Weekly challenge selesai',
            body: 'Target mingguan ${outcome.completedChallenges.join(', ')} berhasil kamu lampaui.',
            type: 'achievement',
          );
          if (outcome.completedChallenges.length >= 2) {
            await _awardBadge(
              uid: outcome.uid,
              badgeId: 'weekly_warrior',
              icon: 'workspace_premium',
              title: 'Weekly Warrior',
              desc: 'Multiple weekly challenges complete',
              detail: 'Kamu menuntaskan beberapa target mingguan dalam satu pekan. Laju progresmu berada di jalur yang sehat.',
              earnedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
            );
          }
          break;
        case FitnessEventType.dailyReminder:
          break;
      }
    }
  }

  Future<void> _maybeAwardWorkoutBadges(_WorkoutOutcome outcome) async {
    final workoutCount = _recentWorkouts.length + 1;
    if (workoutCount == 1) {
      await _awardBadge(
        uid: outcome.uid,
        badgeId: 'first_workout',
        icon: 'directions_run',
        title: 'First Workout',
        desc: 'Completed your first workout',
        detail: 'Satu sesi latihan selesai. Dari sini progresmu mulai tercatat secara nyata.',
        earnedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
      );
    }
    if (workoutCount >= 5) {
      await _awardBadge(
        uid: outcome.uid,
        badgeId: 'routine_builder',
        icon: 'fitness_center',
        title: 'Routine Builder',
        desc: 'Completed 5 workouts',
        detail: 'Lima sesi latihan berhasil tersimpan. Rutinitasmu mulai terbentuk dengan stabil.',
        earnedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
      );
    }
  }

  Future<void> _awardBadge({
    required String uid,
    required String badgeId,
    required String icon,
    required String title,
    required String desc,
    required String detail,
    required String earnedOn,
  }) async {
    if (!_canWriteToFirebase) {
      return;
    }
    final ref = _firestore!.collection('users').doc(uid).collection('badges').doc(badgeId);
    final existing = await ref.get();
    if (existing.exists) {
      return;
    }
    final badgeData = {
      'icon': icon,
      'title': title,
      'desc': desc,
      'detail': detail,
      'earnedOn': earnedOn,
      'done': true,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await ref.set(badgeData, SetOptions(merge: true));
    _pendingBadgeToast = {
      ...badgeData,
      'icon': _getIconData(icon),
    };
    notifyListeners();
  }

  Future<void> _pushNotification({
    required String uid,
    required String icon,
    required String title,
    required String body,
    required String type,
  }) async {
    if (!_canWriteToFirebase) {
      return;
    }
    await _firestore!.collection('users').doc(uid).collection('notifications').add({
      'icon': icon,
      'title': title,
      'body': body,
      'type': type,
      'time': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(_checkReminderDue());
    });
  }

  Future<void> _checkReminderDue({bool forceCheck = false}) async {
    if (!_canWriteToFirebase) {
      return;
    }
    final uid = _auth!.currentUser?.uid;
    if (uid == null || !_reminderSettings.enabled || !_reminderSettings.notifyReminders) {
      return;
    }
    final now = DateTime.now();
    if (!_reminderSettings.days.contains(now.weekday)) {
      return;
    }
    final todayKey = _localDateKey(now);
    final reminderTimeReached = now.hour > _reminderSettings.hour ||
        (now.hour == _reminderSettings.hour && now.minute >= _reminderSettings.minute);
    if (!forceCheck && !reminderTimeReached) {
      return;
    }
    if (_reminderSettings.lastTriggeredOn == todayKey) {
      return;
    }

    await _pushNotification(
      uid: uid,
      icon: _reminderSettings.type == 'recovery' ? 'bedtime' : 'directions_run',
      title: 'Daily reminder',
      body: _reminderSettings.type == 'recovery'
          ? 'Jangan lupa recovery hari ini: tidur cukup, stretching, dan cek progresmu.'
          : 'Saatnya bergerak. Selesaikan latihan hari ini untuk menjaga streak tetap aman.',
      type: 'reminder',
    );
    _reminderSettings = _reminderSettings.copyWith(lastTriggeredOn: todayKey);
    notifyListeners();
    await _firestore!.collection('users').doc(uid).set({
      'reminderSettings.lastTriggeredOn': todayKey,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  _GoalData _readGoals(Map<String, dynamic> data) {
    final goals = (data['goals'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return _GoalData(
      stepsGoal: (goals['steps'] ?? data['stepsGoal'] ?? _defaultStepsGoal) as int,
      caloriesGoal: (goals['calories'] ?? data['caloriesGoal'] ?? _defaultCaloriesGoal) as int,
      moveMinutesGoal: (goals['moveMinutes'] ?? data['moveMinutesGoal'] ?? _defaultMoveGoal) as int,
    );
  }

  _StreakData _readStreak(Map<String, dynamic> data) {
    final streak = (data['streak'] as Map<String, dynamic>?);
    if (streak != null) {
      return _StreakData(
        currentStreak: (streak['current'] ?? 0) as int,
        longestStreak: (streak['longest'] ?? data['longestStreak'] ?? 0) as int,
        lastWorkoutDate: (streak['lastWorkoutDate'] ?? data['lastWorkoutDate'] ?? '') as String,
      );
    }
    return _StreakData(
      currentStreak: (data['streak'] ?? 0) as int,
      longestStreak: (data['longestStreak'] ?? 0) as int,
      lastWorkoutDate: (data['lastWorkoutDate'] ?? '') as String,
    );
  }

  _GamificationData _readGamification(Map<String, dynamic> data) {
    final gamification = (data['gamification'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return _GamificationData(
      level: (gamification['level'] ?? data['level'] ?? 1) as int,
      currentXp: (gamification['xp'] ?? data['xp'] ?? 0) as int,
      nextLevelXp: (gamification['xpNextLevel'] ?? data['xpNextLevel'] ?? 1000) as int,
    );
  }

  _LevelProgress _applyXp({
    required int currentXp,
    required int currentLevel,
    required int nextLevelXp,
    required int xpEarned,
  }) {
    var level = currentLevel;
    var xp = currentXp + xpEarned;
    var levelThreshold = nextLevelXp;
    while (xp >= levelThreshold) {
      xp -= levelThreshold;
      level += 1;
      levelThreshold = (levelThreshold * _xpThresholdMultiplier).round();
    }
    return _LevelProgress(level: level, currentXp: xp, nextLevelXp: levelThreshold);
  }

  double _calculateGoalCompletionRate({
    required int steps,
    required int calories,
    required int moveMinutes,
    required int stepsGoal,
    required int caloriesGoal,
    required int moveGoal,
  }) {
    final stepScore = _goalProgress(steps, stepsGoal);
    final calorieScore = _goalProgress(calories, caloriesGoal);
    final moveScore = _goalProgress(moveMinutes, moveGoal);
    return ((stepScore + calorieScore + moveScore) / 3).clamp(0.0, 1.0);
  }

  int _calculateWorkoutXp({
    required int calories,
    required int steps,
    required int durationMinutes,
    required double distanceKm,
  }) {
    final value = 30 +
        (durationMinutes * 2.5).round() +
        (steps / 25).round() +
        (calories / 3).round() +
        (distanceKm * 18).round();
    return math.max(40, value);
  }

  double _goalProgress(int current, int goal) {
    if (goal <= 0) {
      return 0;
    }
    return (current / goal).clamp(0.0, 1.0);
  }

  String _localDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date.toLocal());

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  String _formatNotificationTime(Object? value) {
    if (value is Timestamp) {
      final date = value.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inMinutes < 1) {
        return 'Just now';
      }
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      }
      if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      }
      return DateFormat('dd MMM').format(date);
    }
    return 'Recently';
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'rocket_launch':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  bool get _canWriteToFirebase => _useFirebase && _firestore != null && _auth != null;

  void _disposeDataSubscriptions() {
    _profileSubscription?.cancel();
    _dailyStatsSubscription?.cancel();
    _badgesSubscription?.cancel();
    _notificationsSubscription?.cancel();
    _workoutsSubscription?.cancel();
    _weeklyChallengeSubscription?.cancel();
    _reminderTimer?.cancel();
  }

  void _resetData() {
    _currentUid = null;
    _displayName = 'User';
    _age = 21;
    _height = 160;
    _weight = 58;
    _deviceName = 'Samsung Watch';
    _batteryLevel = 85;
    _isDeviceConnected = true;
    _timezone = DateTime.now().timeZoneName;
    _steps = 0;
    _calories = 0;
    _moveMinutes = 0;
    _heartRate = 68;
    _sleepDuration = '7h 24m';
    _streak = 0;
    _longestStreak = 0;
    _lastWorkoutDate = '';
    _level = 1;
    _xp = 0;
    _xpNextLevel = 1000;
    _badges = <Map<String, dynamic>>[];
    _notifications = <Map<String, dynamic>>[];
    _pendingBadgeToast = null;
    _dailyStats = <DailyStatRecord>[];
    _recentWorkouts = <WorkoutRecord>[];
    _weeklyChallenges = _buildWeeklyChallenges(null);
    _reminderSettings = ReminderSettings.defaults();
    _errorMessage = null;
    _isLoading = false;
    _hasLoadedProfile = false;
    _hasLoadedDailyStats = false;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _disposeDataSubscriptions();
    super.dispose();
  }
}

class _GoalData {
  final int stepsGoal;
  final int caloriesGoal;
  final int moveMinutesGoal;

  const _GoalData({
    required this.stepsGoal,
    required this.caloriesGoal,
    required this.moveMinutesGoal,
  });
}

class _StreakData {
  final int currentStreak;
  final int longestStreak;
  final String lastWorkoutDate;

  const _StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastWorkoutDate,
  });
}

class _GamificationData {
  final int level;
  final int currentXp;
  final int nextLevelXp;

  const _GamificationData({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
  });
}

class _LevelProgress {
  final int level;
  final int currentXp;
  final int nextLevelXp;

  const _LevelProgress({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
  });
}

class _WorkoutOutcome {
  final String uid;
  final String workoutId;
  final String sport;
  final int calories;
  final int steps;
  final int durationMinutes;
  final int xpEarned;
  final int previousStreak;
  final int currentStreak;
  final int longestStreak;
  final List<String> goalHits;
  final List<String> completedChallenges;
  final double newGoalCompletion;

  const _WorkoutOutcome({
    required this.uid,
    required this.workoutId,
    required this.sport,
    required this.calories,
    required this.steps,
    required this.durationMinutes,
    required this.xpEarned,
    required this.previousStreak,
    required this.currentStreak,
    required this.longestStreak,
    required this.goalHits,
    required this.completedChallenges,
    required this.newGoalCompletion,
  });
}
