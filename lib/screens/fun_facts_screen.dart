import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';

class FunFactsScreen extends StatelessWidget {
  const FunFactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Tips & Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: const [
              Tab(text: 'Tips Olahraga'),
              Tab(text: 'Event'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TipsTab(),
            _EventsTab(),
          ],
        ),
      ),
    );
  }
}

class _TipsTab extends StatelessWidget {
  const _TipsTab();

  static const _tips = [
    _TipData(
      sport: 'Lari',
      icon: Icons.directions_run_rounded,
      tips: [
        'Mulai dengan lari 20-30 menit, 3x seminggu untuk pemula.',
        'Jaga form: condong sedikit ke depan, langkah kaki di bawah pinggul.',
        'Tambah jarak maksimal 10% per minggu untuk mencegah cedera.',
        'Lari pagi membakar lemak lebih efektif karena glikogen rendah.',
        'Gunakan sepatu lari khusus sesuai tipe kaki (pronasi/supinasi).',
      ],
    ),
    _TipData(
      sport: 'Bersepeda',
      icon: Icons.directions_bike_rounded,
      tips: [
        'Setel sadel pada ketinggian yang tepat — kaki hampir lurus saat pedal bawah.',
        'Cadence ideal 70-90 RPM untuk efisiensi dan perlindungan lutut.',
        'Minum tiap 15-20 menit, jangan tunggu haus saat bersepeda.',
        'Bersepeda 30 menit membakar 200-400 kalori tergantung intensitas.',
        'Latihan interval: 1 menit sprint, 2 menit recovery, ulangi 8x.',
      ],
    ),
    _TipData(
      sport: 'Berenang',
      icon: Icons.pool_rounded,
      tips: [
        'Teknik pernapasan: buang napas dalam air, hirup saat kepala ke samping.',
        'Freestyle (crawl) adalah gaya paling efisien untuk kardio.',
        'Renang 30 menit setara membakar 250-400 kalori.',
        'Pull buoy membantu fokus pada teknik lengan tanpa melelahkan kaki.',
        'Renang cocok untuk rehabilitasi sendi karena impact rendah.',
      ],
    ),
    _TipData(
      sport: 'HIIT',
      icon: Icons.bolt_rounded,
      tips: [
        'HIIT 20-30 menit lebih efektif dari kardio biasa 45-60 menit.',
        'Rasio kerja:istirahat ideal untuk pemula adalah 1:2 (mis. 20 dtk: 40 dtk).',
        'After-burn effect: tubuh terus bakar kalori hingga 24 jam setelah HIIT.',
        'Lakukan maksimal 3-4x seminggu; butuh pemulihan 48 jam antar sesi.',
        'Selalu awali dengan warm-up 5-10 menit untuk mencegah cedera.',
      ],
    ),
    _TipData(
      sport: 'Gym / Beban',
      icon: Icons.fitness_center_rounded,
      tips: [
        'Progressive overload: tambah beban atau repetisi setiap 1-2 minggu.',
        'Istirahat 48-72 jam antar sesi otot yang sama untuk pemulihan optimal.',
        'Protein 1.6-2.2 g/kg berat badan untuk pertumbuhan otot maksimal.',
        'Compound movement (squat, deadlift, bench) lebih efisien dari isolasi.',
        'Catat setiap sesi workout untuk melacak progress secara konsisten.',
      ],
    ),
    _TipData(
      sport: 'Yoga',
      icon: Icons.self_improvement_rounded,
      tips: [
        'Yoga rutin 3x seminggu meningkatkan fleksibilitas signifikan dalam 8 minggu.',
        'Pernapasan (pranayama) sama pentingnya dengan pose (asana).',
        'Yoga Vinyasa untuk kardio; Yin/Restorative untuk pemulihan dan relaksasi.',
        'Pose Downward Dog memperkuat bahu, inti, dan meregangkan hamstring.',
        'Yoga dapat menurunkan kortisol dan meningkatkan kualitas tidur.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _tips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _TipCard(data: _tips[i]),
    );
  }
}

class _TipData {
  final String sport;
  final IconData icon;
  final List<String> tips;
  const _TipData({required this.sport, required this.icon, required this.tips});
}

class _TipCard extends StatefulWidget {
  final _TipData data;
  const _TipCard({required this.data});

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: _expanded
              ? Border.all(color: AppTheme.accent.withValues(alpha: 0.4))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.data.icon, color: AppTheme.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.data.sport,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              ...widget.data.tips.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1, right: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab();

  static const _events = [
    _EventData(
      title: 'Surabaya 10K Run',
      date: 'Agustus 2025',
      location: 'Surabaya, Jawa Timur',
      category: 'Lari',
      icon: Icons.directions_run_rounded,
      description: 'Lari 10K menyusuri jalur ikonik Surabaya, terbuka untuk semua level. Tersedia kategori 5K dan 10K.',
    ),
    _EventData(
      title: 'Tour de Bromo 2025',
      date: 'September 2025',
      location: 'Probolinggo, Jawa Timur',
      category: 'Bersepeda',
      icon: Icons.directions_bike_rounded,
      description: 'Ajang bersepeda dengan pemandangan Gunung Bromo. Rute 60km dan 120km tersedia.',
    ),
    _EventData(
      title: 'ITS Campus Triathlon',
      date: 'Oktober 2025',
      location: 'ITS Surabaya',
      category: 'Triathlon',
      icon: Icons.emoji_events_rounded,
      description: 'Kompetisi triathlon tahunan di kampus ITS: 750m renang, 20km bersepeda, 5km lari.',
    ),
    _EventData(
      title: 'Bali Ultra Marathon',
      date: 'November 2025',
      location: 'Ubud, Bali',
      category: 'Lari',
      icon: Icons.directions_run_rounded,
      description: 'Ultra marathon menembus alam Bali. Kategori 50K dan 100K dengan pemandangan sawah terasering.',
    ),
    _EventData(
      title: 'Jakarta Fitness Expo',
      date: 'Desember 2025',
      location: 'Jakarta Convention Center',
      category: 'Fitness',
      icon: Icons.fitness_center_rounded,
      description: 'Pameran fitness terbesar Indonesia: demo atlet, sertifikasi personal trainer, dan kompetisi powerlifting.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _EventCard(event: _events[i]),
    );
  }
}

class _EventData {
  final String title;
  final String date;
  final String location;
  final String category;
  final IconData icon;
  final String description;
  const _EventData({
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.icon,
    required this.description,
  });
}

class _EventCard extends StatelessWidget {
  final _EventData event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(event.icon, color: AppTheme.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.category,
                        style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      event.date,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: AppTheme.textMuted, size: 12),
                    const SizedBox(width: 3),
                    Text(event.location, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
