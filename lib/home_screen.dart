import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'create_screen.dart';
import 'qr_types.dart';
import 'theme.dart';

// Har group ka apna colour
const _accents = <String, List<Color>>{
  'Basics': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  'People & Places': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
  'Social & Video': [Color(0xFFEC4899), Color(0xFFF43F5E)],
  'Files & More': [Color(0xFFF59E0B), Color(0xFFF97316)],
  'Payments': [Color(0xFF10B981), Color(0xFF14B8A6)],
};

class HomeScreen extends StatelessWidget {
  /// Phone: true (apna background aur logo khud banata hai).
  /// Laptop: false (background aur upar ka bar MainShell dikhata hai).
  final bool standalone;
  final ValueChanged<int>? onTab;
  const HomeScreen({super.key, this.standalone = true, this.onTab});

  Widget _hero(bool big) {
    final headSize = big ? 46.0 : 30.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (standalone) ...[
          const Row(
            children: [
              BrandMark(size: 34),
              SizedBox(width: 10),
              Text('QRush',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 28),
        ],
        Text('Create QR codes',
            style: TextStyle(
                color: Colors.white,
                fontSize: headSize,
                fontWeight: FontWeight.w800,
                height: 1.1)),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [AppColors.accentCyan, AppColors.accentPink],
          ).createShader(r),
          child: Text('that stand out.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: headSize,
                  fontWeight: FontWeight.w800,
                  height: 1.15)),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Design, scan and manage every QR code in one place. 24 content types, 12 ready designs and a built-in scanner.',
            style: TextStyle(
                color: Colors.white70,
                fontSize: big ? 16 : 14,
                height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill('24 QR types'),
            _Pill('12 designs'),
            _Pill('Built-in scanner'),
            _Pill('PNG · JPG · PDF'),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _GradientButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan a QR code',
              onTap: () => onTab?.call(1),
            ),
            _GhostButton(
              icon: Icons.collections_bookmark_outlined,
              label: 'My QR Library',
              onTap: () => onTab?.call(2),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final pad = math.max(20.0, (w - 1200) / 2);
      final big = w >= 700;

      final slivers = <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, big ? 40 : 16, pad, 8),
            child: _hero(big),
          ),
        ),
      ];

      for (final g in qrGroupOrder) {
        final items = qrTypes.where((t) => t.group == g).toList();
        if (items.isEmpty) continue;
        final accent = _accents[g] ?? _accents['Basics']!;

        slivers.add(SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 34, pad, 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: accent),
                  ),
                ),
                const SizedBox(width: 10),
                Text(g,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Text('${items.length} types',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ));

        slivers.add(SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: big ? 200 : 170,
              mainAxisExtent: 124,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _Tile(type: items[i], accent: accent),
              childCount: items.length,
            ),
          ),
        ));
      }

      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 56)));
      return CustomScrollView(slivers: slivers);
    });

    return standalone
        ? DarkBackdrop(child: SafeArea(bottom: false, child: content))
        : content;
  }
}

class _Tile extends StatelessWidget {
  final QrType type;
  final List<Color> accent;
  const _Tile({required this.type, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        hoverColor: Colors.white.withOpacity(0.06),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateScreen(type: type)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: accent,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.first.withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(type.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                type.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [AppColors.accentIndigo, AppColors.accentPink],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GhostButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        hoverColor: Colors.white.withOpacity(0.06),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}