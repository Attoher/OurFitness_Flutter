import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../services/social_service.dart';
import '../widgets/pressable.dart';
import 'friend_detail_screen.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final accent = AppTheme.accent;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, accent)),
            SliverToBoxAdapter(child: _buildIncomingRequests(context, accent)),
            SliverToBoxAdapter(child: _buildFriendsList(context, accent)),
            SliverToBoxAdapter(child: _buildChallenge(context, accent)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Pressable(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Komunitas', style: Theme.of(context).textTheme.displaySmall),
                const Text('Teman & Aktivitas',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Pressable(
            onTap: () {
              HapticFeedback.lightImpact();
              _showAddFriendSheet(context, accent);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.person_add_alt_1_rounded, color: accent, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Incoming friend requests ───────────────────────────────────────────────

  Widget _buildIncomingRequests(BuildContext context, Color accent) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.read<SocialService>().incomingRequestsStream(),
      builder: (context, snap) {
        final requests = snap.data ?? [];
        if (requests.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('PERMINTAAN MASUK',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.streakOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${requests.length}',
                        style: const TextStyle(color: AppTheme.streakOrange, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...requests.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RequestTile(request: req, accent: accent),
              )),
            ],
          ),
        );
      },
    );
  }

  // ── Real friends list ──────────────────────────────────────────────────────

  Widget _buildFriendsList(BuildContext context, Color accent) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.read<SocialService>().friendsStream(),
      builder: (context, snap) {
        final friends = snap.data ?? [];

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('TEMAN SAYA',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  const Spacer(),
                  Text('${friends.length} teman',
                      style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              if (snap.connectionState == ConnectionState.waiting)
                Center(child: SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: accent)))
              else if (friends.isEmpty)
                _buildEmptyFriends(context, accent)
              else
                Column(
                  children: friends.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FriendTile(friend: f, accent: accent),
                  )).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyFriends(BuildContext context, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.group_add_rounded, size: 40, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text('Belum ada teman',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Tambahkan teman untuk melihat aktivitas mereka',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          Pressable(
            onTap: () => _showAddFriendSheet(context, accent),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tambah Teman',
                style: TextStyle(
                  color: ThemeService.isLightColor(accent) ? Colors.black : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Challenge card (static) ────────────────────────────────────────────────

  Widget _buildChallenge(BuildContext context, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.06)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'TANTANGAN MINGGU INI',
                  style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Lari 5K dalam 7 Hari',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('128 anggota bergabung • 4 hari tersisa',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.62,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('3,1 / 5 km',
                    style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: ThemeService.isLightColor(accent) ? Colors.black : Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                child: const Text('Ikut Tantangan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendSheet(BuildContext context, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AddFriendSheet(accent: accent),
    );
  }
}

// ── Incoming request tile ──────────────────────────────────────────────────────

class _RequestTile extends StatefulWidget {
  final Map<String, dynamic> request;
  final Color accent;
  const _RequestTile({required this.request, required this.accent});

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.request['name'] ?? widget.request['displayName'] ?? 'Pengguna';
    final uid = widget.request['uid'] as String;
    final requestId = widget.request['requestId'] as String;
    final initial = name.isNotEmpty ? (name as String)[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.streakOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.streakOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initial,
                  style: const TextStyle(color: AppTheme.streakOrange, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const Text('Ingin berteman dengan kamu',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (_loading)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() => _loading = true);
                    final social = context.read<SocialService>();
                    await social.declineFriendRequest(requestId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Tolak',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    setState(() => _loading = true);
                    final social = context.read<SocialService>();
                    final err = await social.acceptFriendRequest(requestId, uid);
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Terima',
                        style: TextStyle(
                          color: ThemeService.isLightColor(widget.accent) ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Friend tile ────────────────────────────────────────────────────────────────

class _FriendTile extends StatelessWidget {
  final Map<String, dynamic> friend;
  final Color accent;
  const _FriendTile({required this.friend, required this.accent});

  @override
  Widget build(BuildContext context) {
    final name = friend['displayName'] ?? friend['name'] ?? 'Teman';
    final level = friend['level'] as int? ?? 1;
    final streak = friend['streak'] as int? ?? 0;
    final initial = (name as String).isNotEmpty ? name[0].toUpperCase() : '?';

    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FriendDetailScreen(friend: friend),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 260),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Center(
                child: Text(initial,
                    style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.xpGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Lv $level',
                            style: const TextStyle(color: AppTheme.xpGold, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      if (streak > 0) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.local_fire_department_rounded, size: 12, color: AppTheme.streakOrange),
                        const SizedBox(width: 2),
                        Text('$streak hari', style: const TextStyle(color: AppTheme.streakOrange, fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Add friend bottom sheet ────────────────────────────────────────────────────

class _AddFriendSheet extends StatefulWidget {
  final Color accent;
  const _AddFriendSheet({required this.accent});

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  bool _hasSearched = false;

  Future<void> _search() async {
    if (_ctrl.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    final social = context.read<SocialService>();
    final res = await social.searchUsers(_ctrl.text.trim());
    if (mounted) setState(() { _results = res; _searching = false; _hasSearched = true; });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tambah Teman',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Cari berdasarkan nama atau email',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Nama atau email...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _search,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(14)),
                  child: _searching
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                      : Icon(Icons.search_rounded, color: ThemeService.isLightColor(accent) ? Colors.black : Colors.white),
                ),
              ),
            ],
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _SearchResultTile(user: _results[i], accent: accent),
              ),
            ),
          ] else if (_hasSearched && !_searching) ...[
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 10),
                  const Text('Pengguna tidak ditemukan',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Coba nama atau email yang berbeda',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ] else if (!_hasSearched) ...[
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Icon(Icons.group_add_rounded, size: 40, color: accent.withValues(alpha: 0.4)),
                  const SizedBox(height: 10),
                  const Text('Temukan teman barumu',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Ketik nama atau email lalu tekan cari',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Search result tile (status-aware) ──────────────────────────────────────────

class _SearchResultTile extends StatefulWidget {
  final Map<String, dynamic> user;
  final Color accent;
  const _SearchResultTile({required this.user, required this.accent});

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  late String _relation; // none | pending | friend
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _relation = widget.user['_relation'] as String? ?? 'none';
  }

  Future<void> _add() async {
    setState(() => _loading = true);
    final name = widget.user['displayName'] ?? widget.user['name'] ?? 'Pengguna';
    final social = context.read<SocialService>();
    final err = await social.sendFriendRequest(widget.user['uid'] as String);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (err == null) _relation = 'pending';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Permintaan terkirim ke $name!'),
      backgroundColor: err != null ? Colors.redAccent : widget.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final name = (widget.user['displayName'] ?? widget.user['name'] ?? 'Pengguna') as String;
    final email = widget.user['email'] as String? ?? '';
    final level = widget.user['level'] as int? ?? 1;
    final photo = widget.user['photoBase64'] as String? ?? '';
    final hasPhoto = photo.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
            ),
            child: ClipOval(
              child: hasPhoto
                  ? Image.memory(base64Decode(photo), fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initial(name, accent))
                  : _initial(name, accent),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  email.isNotEmpty ? email : 'Level $level',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildButton(accent),
        ],
      ),
    );
  }

  Widget _initial(String name, Color accent) => Container(
        color: accent.withValues(alpha: 0.15),
        child: Center(child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 16),
        )),
      );

  Widget _buildButton(Color accent) {
    if (_loading) {
      return const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_relation == 'friend') {
      return _statusChip(Icons.check_circle_rounded, 'Teman', AppTheme.ringSteps);
    }
    if (_relation == 'pending') {
      return _statusChip(Icons.schedule_rounded, 'Terkirim', AppTheme.textMuted);
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _add();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded, size: 13,
                color: ThemeService.isLightColor(accent) ? Colors.black : Colors.white),
            const SizedBox(width: 4),
            Text('Tambah',
                style: TextStyle(
                  color: ThemeService.isLightColor(accent) ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
