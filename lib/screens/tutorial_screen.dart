import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeService>().accent;
    final surface = context.watch<ThemeService>().surface;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Panduan Aplikasi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _buildHero(context, accent),
          const SizedBox(height: 20),
          _buildQuickStart(context, accent, surface),
          const SizedBox(height: 16),
          _buildFaq(context, accent, surface),
          const SizedBox(height: 16),
          _buildFeatures(context, accent, surface),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.waving_hand_rounded, color: accent, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang di OurFitness!',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Panduan lengkap untuk memaksimalkan penggunaan aplikasi.',
                  style: TextStyle(color: accent.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStart(BuildContext context, Color accent, Color surface) {
    final steps = [
      _Step(
        number: '1',
        title: 'Buat Akun',
        desc: 'Daftar dengan email dan lengkapi profil (nama, usia, tinggi, berat badan) agar kalori dan statistik lebih akurat.',
        icon: Icons.person_add_rounded,
        color: accent,
      ),
      _Step(
        number: '2',
        title: 'Izinkan GPS',
        desc: 'Berikan izin lokasi agar peta tracking berjalan real-time. Pergi ke Pengaturan → OurFitness → Lokasi → Izinkan.',
        icon: Icons.gps_fixed_rounded,
        color: Colors.greenAccent,
      ),
      _Step(
        number: '3',
        title: 'Mulai Olahraga',
        desc: 'Ketuk tombol lari di tengah nav-bar, pilih jenis olahraga, lalu tekan "Start Activity". Peta akan mendeteksi jalurmu secara otomatis.',
        icon: Icons.directions_run_rounded,
        color: Colors.orange,
      ),
      _Step(
        number: '4',
        title: 'Pantau Statistik',
        desc: 'Lihat ringkasan harian, mingguan, dan kalori yang sudah terbakar di tab Statistik.',
        icon: Icons.insert_chart_rounded,
        color: Colors.lightBlue,
      ),
      _Step(
        number: '5',
        title: 'Kumpulkan Pencapaian',
        desc: 'Selesaikan target untuk mendapatkan badge, naik level, dan bersaing di leaderboard komunitas.',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFFD700),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CARA MEMULAI',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) => _StepTile(
                step: e.value,
                isLast: e.key == steps.length - 1,
              )),
        ],
      ),
    );
  }

  Widget _buildFaq(BuildContext context, Color accent, Color surface) {
    final faqs = [
      _Faq(
        q: 'Bagaimana cara kerja peta tracking?',
        a: 'Peta menggunakan OpenStreetMap (gratis, tanpa biaya). GPS mendeteksi posisimu setiap beberapa meter dan menggambar jalur pada peta secara real-time. Pastikan GPS aktif dan sinyal kuat untuk hasil terbaik.',
      ),
      _Faq(
        q: 'Apakah data saya aman?',
        a: 'Data disimpan di Firebase (cloud aman Google). Hanya kamu yang dapat mengakses data olahraga, profil, dan riwayat aktivitas milikmu.',
      ),
      _Faq(
        q: 'Mengapa GPS tidak akurat di dalam ruangan?',
        a: 'GPS membutuhkan sinyal satelit yang terhalang atap/bangunan. Untuk latihan indoor (gym, renang), statistik tetap dihitung berdasarkan waktu aktif.',
      ),
      _Faq(
        q: 'Bagaimana mengganti tema warna?',
        a: 'Buka tab Profil → Tema Aplikasi. Pilih dari 5 preset warna: Lime, Ocean, Violet, Ember, dan Mint. Tema langsung berubah di seluruh aplikasi.',
      ),
      _Faq(
        q: 'Bagaimana cara bergabung dengan komunitas?',
        a: 'Buka tab Profil → Komunitas, atau tekan ikon komunitas. Kamu bisa menambah teman, ikut tantangan mingguan, dan melihat papan peringkat.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PERTANYAAN UMUM',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          ...faqs.asMap().entries.map((e) => _FaqTile(
                faq: e.value,
                index: e.key,
                isExpanded: _expandedIndex == e.key,
                accent: accent,
                onTap: () => setState(
                    () => _expandedIndex = _expandedIndex == e.key ? -1 : e.key),
              )),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, Color accent, Color surface) {
    final features = [
      _Feature('Peta Real-Time', 'Tracking rute olahraga menggunakan GPS + OpenStreetMap', Icons.map_rounded, accent),
      _Feature('Statistik Lengkap', 'Langkah, kalori, jarak, waktu aktif, detak jantung', Icons.insert_chart_rounded, Colors.lightBlue),
      _Feature('Gamifikasi', 'Level, XP, badge pencapaian, dan streak harian', Icons.emoji_events_rounded, const Color(0xFFFFD700)),
      _Feature('Komunitas', 'Teman, tantangan, dan papan peringkat mingguan', Icons.group_rounded, Colors.greenAccent),
      _Feature('Diet & Nutrisi', 'Panduan gizi, BMI, kalori, dan pola makan sehat', Icons.restaurant_menu_rounded, Colors.orange),
      _Feature('Tema Aplikasi', '5 preset warna: Lime, Ocean, Violet, Ember, Mint', Icons.palette_rounded, Colors.purple),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SEMUA FITUR',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: features
                .map((f) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: f.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: f.color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(f.icon, color: f.color, size: 22),
                          const Spacer(),
                          Text(f.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                          Text(f.desc,
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 9),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Step {
  final String number, title, desc;
  final IconData icon;
  final Color color;

  const _Step({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });
}

class _Faq {
  final String q, a;

  const _Faq({required this.q, required this.a});
}

class _Feature {
  final String title, desc;
  final IconData icon;
  final Color color;

  const _Feature(this.title, this.desc, this.icon, this.color);
}

class _StepTile extends StatelessWidget {
  final _Step step;
  final bool isLast;

  const _StepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.color.withValues(alpha: 0.2),
                border: Border.all(color: step.color.withValues(alpha: 0.5)),
              ),
              child: Icon(step.icon, color: step.color, size: 18),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 36,
                color: AppTheme.surfaceLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(step.desc,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  final int index;
  final bool isExpanded;
  final Color accent;
  final VoidCallback onTap;

  const _FaqTile({
    required this.faq,
    required this.index,
    required this.isExpanded,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isExpanded
                ? accent.withValues(alpha: 0.08)
                : AppTheme.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: isExpanded ? Border.all(color: accent.withValues(alpha: 0.3)) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(faq.q,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: isExpanded ? accent : AppTheme.textMuted,
                    size: 20,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                Text(faq.a,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12, height: 1.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
