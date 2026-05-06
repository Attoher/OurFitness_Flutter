class UserModel {
  final String name;
  final int age;
  final double height;
  final double weight;
  final String connectedDevice;
  final int streakWeeks;
  final int calories;
  final int steps;
  final int moveMinutes;
  final int heartRate;
  final String sleepDuration;
  final int steps7k;
  final int caloriesGoal;
  final double distanceGoal;
  final String workoutGoal;

  const UserModel({
    this.name = 'Asha Irawan',
    this.age = 21,
    this.height = 160,
    this.weight = 58,
    this.connectedDevice = 'Samsung Watch',
    this.streakWeeks = 3,
    this.calories = 150,
    this.steps = 1500,
    this.moveMinutes = 25,
    this.heartRate = 135,
    this.sleepDuration = '7h 12m',
    this.steps7k = 7240,
    this.caloriesGoal = 450,
    this.distanceGoal = 6,
    this.workoutGoal = '4h 46m',
  });
}

class WorkoutSession {
  final String sport;
  final String duration;
  final double distance;
  final String pace;
  final int heartRate;
  final int calories;

  const WorkoutSession({
    required this.sport,
    required this.duration,
    required this.distance,
    required this.pace,
    required this.heartRate,
    required this.calories,
  });
}

class Sport {
  final String name;
  final String category;
  final String icon;

  const Sport({
    required this.name,
    required this.category,
    required this.icon,
  });
}

const List<Sport> cardioSports = [
  Sport(name: 'Running', category: 'CARDIO', icon: 'directions_run'),
  Sport(name: 'Cycling', category: 'CARDIO', icon: 'two_wheeler'),
  Sport(name: 'Swimming', category: 'CARDIO', icon: 'pool'),
  Sport(name: 'Walking', category: 'CARDIO', icon: 'directions_walk'),
  Sport(name: 'Treadmill', category: 'CARDIO', icon: 'directions_run'),
  Sport(name: 'HIIT', category: 'CARDIO', icon: 'bolt'),
];

const List<Sport> strengthSports = [
  Sport(name: 'Weight Training', category: 'STRENGTH', icon: 'fitness_center'),
  Sport(name: 'Bodyweight (Calisthenics)', category: 'STRENGTH', icon: 'sports_gymnastics'),
  Sport(name: 'Pilates', category: 'STRENGTH', icon: 'self_improvement'),
  Sport(name: 'Yoga', category: 'STRENGTH', icon: 'self_improvement'),
  Sport(name: 'CrossFit', category: 'STRENGTH', icon: 'local_fire_department'),
];
