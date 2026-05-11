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
  final int _stepsGoal = 5500;
  int _calories = 0;
  final int _caloriesGoal = 500;
  int _moveMinutes = 0;
  final int _moveMinutesGoal = 50;
  int _heartRate = 0;
  String _sleepDuration = '0h 0m';

  int _streak = 0;
  int _level = 1;
  int _xp = 0;
  int _xpNextLevel = 1000;

  List<Map<String, dynamic>> _badges = [];
  List<Map<String, dynamic>> _notifications = [];
  List<double> _weeklySteps = List.filled(7, 0.0);
  List<double> _weeklyCalories = List.filled(7, 0.0);

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
        notifyListeners();
      } else {
        _createInitialProfile(uid);
      }
    });

    // Listen to Daily Progress
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _firestore.collection('users').doc(uid).collection('daily_stats').doc(today).snapshots().listen((doc) {
      if (doc.exists) {
        debugPrint('Daily stats found for $today: ${doc.data()}');
        final data = doc.data()!;
        _steps = data['steps'] ?? 0;
        _calories = data['calories'] ?? 0;
        _moveMinutes = data['moveMinutes'] ?? 0;
        _heartRate = data['heartRate'] ?? 0;
        _sleepDuration = data['sleepDuration'] ?? '0h 0m';
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

    final initialBadges = [
      {'icon': 'directions_run', 'title': 'First Run', 'desc': 'Completed', 'done': true},
      {'icon': 'local_fire_department', 'title': '7-Day Streak', 'desc': 'In progress', 'done': false},
    ];
    for (var b in initialBadges) {
      await _firestore.collection('users').doc(uid).collection('badges').add(b);
    }
  }

  void _resetData() {
    _steps = 0;
    _calories = 0;
    _moveMinutes = 0;
    _badges = [];
    _notifications = [];
    notifyListeners();
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

  // Methods to update data
  Future<void> updateProfile({String? name, int? age, double? height, double? weight}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['displayName'] = name;
    if (age != null) updates['age'] = age;
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;

    await _firestore.collection('users').doc(uid).update(updates);
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
    final now = DateTime.now();
    List<double> steps = [];
    List<double> cals = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final doc = await _firestore.collection('users').doc(uid).collection('daily_stats').doc(date).get();
      if (doc.exists) {
        steps.add((doc.data()!['steps'] ?? 0).toDouble());
        cals.add((doc.data()!['calories'] ?? 0).toDouble());
      } else {
        steps.add(0.0);
        cals.add(0.0);
      }
    }
    
    _weeklySteps = steps;
    _weeklyCalories = cals;
    notifyListeners();
  }
}
