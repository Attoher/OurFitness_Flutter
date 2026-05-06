import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'warmup_screen.dart';

// Helper function to convert icon name to IconData
IconData _getIconFromName(String iconName) {
  switch (iconName) {
    case 'directions_run':
      return Icons.directions_run_rounded;
    case 'two_wheeler':
      return Icons.two_wheeler_rounded;
    case 'pool':
      return Icons.pool_rounded;
    case 'directions_walk':
      return Icons.directions_walk_rounded;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'fitness_center':
      return Icons.fitness_center_rounded;
    case 'sports_gymnastics':
      return Icons.sports_gymnastics_rounded;
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.sports_rounded;
  }
}

class SportSelectionSheet extends StatefulWidget {
  const SportSelectionSheet({super.key});

  @override
  State<SportSelectionSheet> createState() => _SportSelectionSheetState();
}

class _SportSelectionSheetState extends State<SportSelectionSheet> {
  String _searchQuery = '';
  String _selectedSport = 'Running';

  List<Sport> get _filteredCardio => cardioSports
      .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  List<Sport> get _filteredStrength => strengthSports
      .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left_rounded, size: 28, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text('Choose a Sport', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  if (_filteredCardio.isNotEmpty) ...[
                    _SectionLabel(label: 'CARDIO'),
                    const SizedBox(height: 8),
                    ..._filteredCardio.map((s) => _SportTile(
                          sport: s,
                          isSelected: _selectedSport == s.name,
                          onTap: () {
                            setState(() => _selectedSport = s.name);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WarmupScreen(sport: s),
                                ),
                              );
                            });
                          },
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (_filteredStrength.isNotEmpty) ...[
                    _SectionLabel(label: 'STRENGTH'),
                    const SizedBox(height: 8),
                    ..._filteredStrength.map((s) => _SportTile(
                          sport: s,
                          isSelected: _selectedSport == s.name,
                          onTap: () {
                            setState(() => _selectedSport = s.name);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WarmupScreen(sport: s),
                                ),
                              );
                            });
                          },
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  final Sport sport;
  final bool isSelected;
  final VoidCallback onTap;

  const _SportTile({
    required this.sport,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_getIconFromName(sport.icon), size: 20, color: AppTheme.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sport.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
