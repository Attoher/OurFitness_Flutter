import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../services/fitness_service.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeService>().accent;
    final surface = context.watch<ThemeService>().surface;
    final fitness = context.watch<FitnessService>();

    final bmi = fitness.weight / ((fitness.height / 100) * (fitness.height / 100));
    final dailyCalories = _calcDailyCalories(fitness.weight, fitness.height, fitness.age);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Diet & Nutrisi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _buildBmiCard(context, accent, surface, bmi),
          const SizedBox(height: 16),
          _buildCalorieCard(context, accent, surface, dailyCalories),
          const SizedBox(height: 16),
          _buildMacroCard(context, accent, surface, dailyCalories),
          const SizedBox(height: 16),
          _buildPreWorkout(context, accent, surface),
          const SizedBox(height: 16),
          _buildPostWorkout(context, accent, surface),
          const SizedBox(height: 16),
          _buildHydration(context, accent, surface, fitness.weight),
          const SizedBox(height: 16),
          _buildFoodTips(context, accent, surface),
        ],
      ),
    );
  }

  int _calcDailyCalories(double weight, double height, int age) {
    // Mifflin-St Jeor (asumsi pria aktif sebagai default)
    final bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    return (bmr * 1.55).round(); // aktif sedang
  }

  Widget _buildBmiCard(BuildContext context, Color accent, Color surface, double bmi) {
    final category = bmi < 18.5
        ? 'Kurus'
        : bmi < 25
            ? 'Normal'
            : bmi < 30
                ? 'Gemuk'
                : 'Obesitas';
    final catColor = bmi < 18.5
        ? Colors.blue
        : bmi < 25
            ? Colors.green
            : bmi < 30
                ? Colors.orange
                : Colors.red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monitor_weight_outlined, color: accent, size: 16),
                    const SizedBox(width: 6),
                    Text('INDEKS MASSA TUBUH',
                        style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(color: catColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          _BmiGauge(bmi: bmi, accent: accent),
        ],
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context, Color accent, Color surface, int calories) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              const Text('KEBUTUHAN KALORI HARIAN',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$calories',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 6),
                child: Text('kcal/hari', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _CalGoal(label: 'Turun BB', value: '${calories - 400} kcal', color: Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _CalGoal(label: 'Tetap', value: '$calories kcal', color: Colors.green, isActive: true)),
              const SizedBox(width: 8),
              Expanded(child: _CalGoal(label: 'Naik BB', value: '${calories + 400} kcal', color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context, Color accent, Color surface, int calories) {
    final carbs = (calories * 0.50 / 4).round();
    final protein = (calories * 0.25 / 4).round();
    final fat = (calories * 0.25 / 9).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DISTRIBUSI MAKRONUTRIEN',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: [
              _MacroBar(label: 'Karbohidrat', value: carbs, unit: 'g', percent: 50, color: accent),
              const SizedBox(width: 10),
              _MacroBar(label: 'Protein', value: protein, unit: 'g', percent: 25, color: const Color(0xFF4CD8D8)),
              const SizedBox(width: 10),
              _MacroBar(label: 'Lemak', value: fat, unit: 'g', percent: 25, color: const Color(0xFFFF9800)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Untuk atlet/aktif berolahraga, kebutuhan protein bisa meningkat hingga 1,6–2,2 g per kg berat badan.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreWorkout(BuildContext context, Color accent, Color surface) {
    return _FoodSection(
      title: 'SEBELUM OLAHRAGA',
      subtitle: '1–2 jam sebelumnya',
      icon: Icons.fitness_center_rounded,
      accent: accent,
      surface: surface,
      color: const Color(0xFF4CD8D8),
      items: const [
        _FoodItem('Pisang', 'Sumber karbohidrat cepat, mudah dicerna', Icons.energy_savings_leaf_rounded),
        _FoodItem('Oatmeal', 'Serat tinggi, energi tahan lama', Icons.grain_rounded),
        _FoodItem('Roti Gandum + Telur', 'Karbohidrat + protein seimbang', Icons.egg_alt_rounded),
        _FoodItem('Smoothie Buah', 'Hidrasi + elektrolit alami', Icons.local_drink_rounded),
      ],
    );
  }

  Widget _buildPostWorkout(BuildContext context, Color accent, Color surface) {
    return _FoodSection(
      title: 'SETELAH OLAHRAGA',
      subtitle: '30–60 menit setelahnya',
      icon: Icons.self_improvement_rounded,
      accent: accent,
      surface: surface,
      color: accent,
      items: const [
        _FoodItem('Ayam Rebus + Nasi', 'Protein + karbohidrat pemulihan otot', Icons.rice_bowl_rounded),
        _FoodItem('Greek Yogurt', 'Protein tinggi, probiotik baik', Icons.breakfast_dining_rounded),
        _FoodItem('Ikan + Sayur', 'Omega-3 mengurangi inflamasi', Icons.set_meal_rounded),
        _FoodItem('Protein Shake', 'Sintesis protein cepat', Icons.blender_rounded),
      ],
    );
  }

  Widget _buildHydration(BuildContext context, Color accent, Color surface, double weight) {
    final minMl = (weight * 30).round();
    final maxMl = (weight * 40).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: Colors.lightBlue, size: 18),
              const SizedBox(width: 8),
              const Text('PANDUAN HIDRASI',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HydrationCard(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Hari Biasa',
                  value: '$minMl–$maxMl ml',
                  sub: '${(minMl / 250).round()}–${(maxMl / 250).round()} gelas',
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HydrationCard(
                  icon: Icons.directions_run_rounded,
                  label: 'Hari Olahraga',
                  value: '+500 ml',
                  sub: 'Tambah 2 gelas ekstra',
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Minum 400–600 ml 2 jam sebelum olahraga, 150–250 ml setiap 15–20 menit saat olahraga.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTips(BuildContext context, Color accent, Color surface) {
    final tips = [
      _Tip('Makan Teratur', 'Usahakan 3 makan utama + 2 snack sehat per hari untuk menjaga metabolisme tetap aktif.', Icons.schedule_rounded, Colors.green),
      _Tip('Hindari Makanan Olahan', 'Batasi makanan cepat saji, gorengan, dan minuman manis yang tinggi kalori kosong.', Icons.no_food_rounded, Colors.red),
      _Tip('Porsi Piring Sehat', 'Isi ½ piring sayur, ¼ protein, ¼ karbohidrat kompleks setiap makan.', Icons.dining_rounded, accent),
      _Tip('Tidur & Pemulihan', 'Tidur 7–9 jam untuk mendukung pemulihan otot dan regulasi hormon nafsu makan.', Icons.bedtime_rounded, Colors.purple),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TIPS POLA HIDUP SEHAT',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 14),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(t.icon, color: t.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(t.body,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Tip {
  final String title, body;
  final IconData icon;
  final Color color;

  const _Tip(this.title, this.body, this.icon, this.color);
}

class _FoodItem {
  final String name, desc;
  final IconData icon;

  const _FoodItem(this.name, this.desc, this.icon);
}

class _FoodSection extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color accent, surface, color;
  final List<_FoodItem> items;

  const _FoodSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.surface,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  Text(subtitle,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(item.desc,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BmiGauge extends StatelessWidget {
  final double bmi;
  final Color accent;

  const _BmiGauge({required this.bmi, required this.accent});

  @override
  Widget build(BuildContext context) {
    final zones = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    return Column(
      children: [
        ...List.generate(4, (i) {
          final names = ['Kurus', 'Normal', 'Gemuk', 'Obesitas'];
          final isActive = (i == 0 && bmi < 18.5) ||
              (i == 1 && bmi >= 18.5 && bmi < 25) ||
              (i == 2 && bmi >= 25 && bmi < 30) ||
              (i == 3 && bmi >= 30);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? zones[i] : zones[i].withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  names[i],
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CalGoal extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isActive;

  const _CalGoal({required this.label, required this.value, required this.color, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: isActive ? color : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label, unit;
  final int value, percent;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('${value}${unit}',
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 2),
          Text('$percent%',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final Color color;

  const _HydrationCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(value,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(sub, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
