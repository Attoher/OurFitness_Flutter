import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FitnessService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Real-time Data
  String _displayName = 'User';
  int _age = 21;
  double _height = 160;
  double _weight = 58;
  String _deviceName = 'Samsung Watch';
  int _batteryLevel = 85;
  bool _isDeviceConnected = true;

  int _steps = 0;
  int _stepsGoal = 5500;
  int _calories = 0;
  int _caloriesGoal = 500;
  int _moveMinutes = 0;
  int _moveMinutesGoal = 50;
  int _heartRate = 68;
  String _sleepDuration = '7h 24m';

  int _streak = 0;
  int _level = 1;
  int _xp = 0;
  int _xpNextLevel = 1000;

  List<Map<String, dynamic>> _badges = [];
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic>? _pendingBadgeToast;
  List<double> _weeklySteps = List.filled(7, 0.0);
  List<double> _weeklyCalories = List.filled(7, 0.0);

  // Simulation
  bool _hasRealDailyData = false;
  Timer? _simTimer;

  FitnessService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToUserData(user.uid);
      } else {
        _resetData();
      }
    });
  }

  void _listenToUserData(String uid) {
    debugPrint('Listening to Firestore data for UID: $uid');
    
    // Listen to User Profile
    _firestore.collection('users').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        debugPrint('Profile data found: ${doc.data()}');
        final data = doc.data()!;
        _displayName = data['displayName'] ?? _displayName;
        _age = data['age'] ?? _age;
        _height = (data['height'] as num?)?.toDouble() ?? _height;
        _weight = (data['weight'] as num?)?.toDouble() ?? _weight;
        _streak = data['streak'] ?? _streak;
        _level = data['level'] ?? _level;
        _xp = data['xp'] ?? _xp;
        _xpNextLevel = data['xpNextLevel'] ?? _xpNextLevel;
        _deviceName = data['deviceName'] ?? _deviceName;
        _batteryLevel = data['batteryLevel'] ?? _batteryLevel;
        _isDeviceConnected = data['isDeviceConnected'] ?? _isDeviceConnected;
        _stepsGoal = data['stepsGoal'] ?? _stepsGoal;
        _caloriesGoal = data['caloriesGoal'] ?? _caloriesGoal;
        _moveMinutesGoal = data['moveMinutesGoal'] ?? _moveMinutesGoal;
        notifyListeners();
      } else {
        _createInitialProfile(uid);
      }
    });

    // Start simulation immediately, real data will override when available
    _startSimulation();

    // Listen to Daily Progress
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _firestore.collection('users').doc(uid).collection('daily_stats').doc(today).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        final realSteps = (data['steps'] ?? 0) as int;
        if (realSteps > 0) {
          _hasRealDailyData = true;
          _steps = realSteps;
          _calories = data['calories'] ?? 0;
          _moveMinutes = data['moveMinutes'] ?? 0;
        }
        final realHr = (data['heartRate'] ?? 0) as int;
        if (realHr > 0) _heartRate = realHr;
        final sleep = data['sleepDuration'] as String?;
        if (sleep != null && sleep != '0h 0m') _sleepDuration = sleep;
        notifyListeners();
      }
    });

    // Listen to Badges
    _firestore.collection('users').doc(uid).collection('badges').snapshots().listen((snapshot) {
      _badges = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'icon': _getIconData(data['icon'] as String?),
        };
      }).toList();
      notifyListeners();
    });

    // Listen to Notifications
    _firestore.collection('users').doc(uid).collection('notifications').orderBy('time', descending: true).snapshots().listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'icon': _getIconData(data['icon'] as String?),
        };
      }).toList();
      notifyListeners();
    });

    _fetchWeeklyStats(uid);
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'directions_run': return Icons.directions_run_rounded;
      case 'local_fire_department': return Icons.local_fire_department_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'directions_walk': return Icons.directions_walk_rounded;
      case 'bedtime': return Icons.bedtime_rounded;
      case 'bolt': return Icons.bolt_rounded;
      case 'workspace_premium': return Icons.workspace_premium_rounded;
      case 'rocket_launch': return Icons.rocket_launch_rounded;
      default: return Icons.star_rounded;
    }
  }

  Future<void> _createInitialProfile(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'displayName': _auth.currentUser?.displayName ?? 'New User',
      'age': 21,
      'height': 160.0,
      'weight': 58.0,
      'streak': 0,
      'level': 1,
      'xp': 0,
      'xpNextLevel': 1000,
      'deviceName': 'Samsung Watch',
      'batteryLevel': 85,
      'isDeviceConnected': true,
    });

    const firstStepBadge = {
      'icon': 'rocket_launch',
      'title': 'First Step',
      'desc': 'Joined OurFitness',
      'detail': 'You took the first step toward a healthier life. Every legend starts somewhere — this is your origin story.',
      'earnedOn': 'Today',
      'done': true,
    };

    final initialBadges = [
      firstStepBadge,
      {'icon': 'local_fire_department', 'title': '7-Day Streak', 'desc': 'In progress', 'done': false},
    ];
    for (var b in initialBadges) {
      await _firestore.collection('users').doc(uid).collection('badges').add(b);
    }

    await _firestore.collection('users').doc(uid).collection('notifications').add({
      'icon': 'rocket_launch',
      'title': 'Badge Unlocked: First Step',
      'body': 'Welcome to OurFitness! You earned your first badge.',
      'time': FieldValue.serverTimestamp(),
      'read': false,
    });

    _pendingBadgeToast = {
      ...firstStepBadge,
      'icon': Icons.rocket_launch_rounded,
    };
    notifyListeners();
  }

  void _startSimulation() {
    _simTimer?.cancel();
    _applySimulation();
    _simTimer = Timer.periodic(const Duration(seconds: 4), (_) => _applySimulation());
  }

  void _applySimulation() {
    final now = DateTime.now();

    // HR: smooth resting variation 63–76 bpm using sine wave on seconds
    final phase = (now.second + now.millisecond / 1000.0) / 13.0;
    _heartRate = 68 + (sin(phase * pi) * 7).round(); // 61–75 range

    if (!_hasRealDailyData) {
      // Simulate activity proportional to time of day (6am–10pm = active window)
      const startMin = 6 * 60;
      const endMin = 22 * 60;
      final currMin = now.hour * 60 + now.minute;
      final progress = ((currMin - startMin) / (endMin - startMin)).clamp(0.0, 1.0);
      _steps = (progress * 3800).toInt();
      _calories = (_steps * 0.042).round();
      _moveMinutes = (progress * 38).toInt();
    }

    notifyListeners();
  }

  void _resetData() {
    _simTimer?.cancel();
    _hasRealDailyData = false;
    _steps = 0;
    _calories = 0;
    _moveMinutes = 0;
    _heartRate = 68;
    _sleepDuration = '7h 24m';
    _badges = [];
    _notifications = [];
    _pendingBadgeToast = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  // Getters
  String get displayName => _displayName;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;
  String get deviceName => _deviceName;
  int get batteryLevel => _batteryLevel;
  bool get isDeviceConnected => _isDeviceConnected;

  int get steps => _steps;
  int get stepsGoal => _stepsGoal;
  double get stepsProgress => (_steps / _stepsGoal).clamp(0.0, 1.0);
  int get calories => _calories;
  int get caloriesGoal => _caloriesGoal;
  double get caloriesProgress => (_calories / _caloriesGoal).clamp(0.0, 1.0);
  int get moveMinutes => _moveMinutes;
  int get moveMinutesGoal => _moveMinutesGoal;
  double get moveMinutesProgress => (_moveMinutes / _moveMinutesGoal).clamp(0.0, 1.0);

  int get heartRate => _heartRate;
  String get sleepDuration => _sleepDuration;
  int get streak => _streak;
  int get level => _level;
  int get xp => _xp;
  int get xpNextLevel => _xpNextLevel;
  double get levelProgress => (_xp / _xpNextLevel).clamp(0.0, 1.0);

  List<Map<String, dynamic>> get badges => _badges;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<double> get weeklySteps => _weeklySteps;
  List<double> get weeklyCalories => _weeklyCalories;
  Map<String, dynamic>? get pendingBadgeToast => _pendingBadgeToast;

  void consumeBadgeToast() {
    _pendingBadgeToast = null;
    // no notifyListeners — caller already reacted
  }

  // Methods to update data
  Future<void> updateGoals({int? stepsGoal, int? caloriesGoal, int? moveMinutesGoal}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (stepsGoal != null) updates['stepsGoal'] = stepsGoal;
    if (caloriesGoal != null) updates['caloriesGoal'] = caloriesGoal;
    if (moveMinutesGoal != null) updates['moveMinutesGoal'] = moveMinutesGoal;

    await _firestore.collection('users').doc(uid).set(updates, SetOptions(merge: true));
  }

  Future<void> updateProfile({String? name, int? age, double? height, double? weight}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['displayName'] = name;
    if (age != null) updates['age'] = age;
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;

    await _firestore.collection('users').doc(uid).set(updates, SetOptions(merge: true));
  }

  Future<void> addSteps(int count) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore.collection('users').doc(uid).collection('daily_stats').doc(today);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'steps': count,
          'calories': (count * 0.04).round(),
          'moveMinutes': (count * 0.01).round(),
        });
      } else {
        final newSteps = (snapshot.data()!['steps'] ?? 0) + count;
        transaction.update(docRef, {
          'steps': newSteps,
          'calories': (newSteps * 0.04).round(),
        });
      }
      
      final userRef = _firestore.collection('users').doc(uid);
      final userSnap = await transaction.get(userRef);
      int currentXp = userSnap.data()!['xp'] ?? 0;
      int currentLevel = userSnap.data()!['level'] ?? 1;
      int nextLevelXp = userSnap.data()!['xpNextLevel'] ?? 1000;
      
      currentXp += (count * 0.1).round();
      if (currentXp >= nextLevelXp) {
        currentLevel++;
        currentXp -= nextLevelXp;
        nextLevelXp = (nextLevelXp * 1.5).round();
      }
      
      transaction.update(userRef, {
        'xp': currentXp,
        'level': currentLevel,
        'xpNextLevel': nextLevelXp,
      });
    });
  }

  Future<void> addWorkoutResult({
    required int calories,
    required int steps,
    required int durationMinutes,
    List<Map<String, double>>? route,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore.collection('users').doc(uid).collection('daily_stats').doc(today);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'steps': steps, 'calories': calories, 'moveMinutes': durationMinutes});
      } else {
        transaction.update(docRef, {
          'steps': (snapshot.data()!['steps'] ?? 0) + steps,
          'calories': (snapshot.data()!['calories'] ?? 0) + calories,
          'moveMinutes': (snapshot.data()!['moveMinutes'] ?? 0) + durationMinutes,
        });
      }
    });

    await _firestore.collection('users').doc(uid).collection('workouts').add({
      'date': FieldValue.serverTimestamp(),
      'calories': calories,
      'steps': steps,
      'durationMinutes': durationMinutes,
      'route': route,
    });
  }

  Future<void> _fetchWeeklyStats(String uid) async {
    // Realistic simulation values for days with no real data
    const simSteps = [5200.0, 8100.0, 3400.0, 6800.0, 4200.0, 9200.0, 0.0];
    const simCals  = [218.0,  340.0,  142.0,  285.0,  176.0,  386.0,  0.0];

    final now = DateTime.now();
    List<double> steps = [];
    List<double> cals  = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final doc = await _firestore
          .collection('users').doc(uid).collection('daily_stats').doc(date).get();
      final dayIndex = 6 - i;

      if (doc.exists && (doc.data()!['steps'] ?? 0) > 0) {
        steps.add((doc.data()!['steps'] ?? 0).toDouble());
        cals.add((doc.data()!['calories'] ?? 0).toDouble());
      } else if (i == 0) {
        // Today: use current simulated/real value
        steps.add(_steps.toDouble());
        cals.add(_calories.toDouble());
      } else {
        // Past day with no recorded data — use realistic simulation
        steps.add(simSteps[dayIndex]);
        cals.add(simCals[dayIndex]);
      }
    }

    _weeklySteps = steps;
    _weeklyCalories = cals;
    notifyListeners();
  }
}
