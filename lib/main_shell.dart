import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'responsive.dart';
import 'scan_screen.dart';
import 'theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  // Har tab badalne par naya screen banta hai: camera sirf Scan tab mein
  // chalta hai, aur Library hamesha taza data dikhati hai.
  Widget _tool() => _index == 1 ? const ScanScreen() : const LibraryScreen();

  @override
  Widget build(BuildContext context) {
    // ---------- Website (laptop) ----------
    if (isWide(context)) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _TopBar(index: _index, onTap: _go),
            Expanded(
              child: _index == 0
                  ? HomeScreen(standalone: false, onTab: _go)
                  : fitWidth(_tool(), max: _index == 1 ? 560 : 1200),
            ),
          ],
        ),
      );
    }

    // ---------- Phone ----------
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _index == 0
          ? HomeScreen(standalone: true, onTab: _go)
          : _tool(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.soft,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box, color: AppColors.primary),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            selectedIcon:
                Icon(Icons.qr_code_scanner, color: AppColors.primary),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon:
                Icon(Icons.collections_bookmark, color: AppColors.primary),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _TopBar({required this.index, required this.onTap});

  static const _labels = ['Create', 'Scan', 'Library'];
  static const _icons = [
    Icons.add_box_outlined,
    Icons.qr_code_scanner,
    Icons.collections_bookmark_outlined,
  ];

  Future<void> _openRepo() async {
    try {
      await launchUrl(
        Uri.parse('https://github.com/himanshibajaj/QRush'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(builder: (context, c) {
          final pad = math.max(24.0, (c.maxWidth - 1200) / 2);
          return Container(
            height: 68,
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              children: [
                const BrandMark(),
                const SizedBox(width: 12),
                const Text('QRush',
                    style: TextStyle(
                        color: AppColors.deep,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 0.3)),
                const SizedBox(width: 40),
                for (var i = 0; i < _labels.length; i++)
                  _TabButton(
                    icon: _icons[i],
                    label: _labels[i],
                    selected: i == index,
                    onTap: () => onTap(i),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openRepo,
                  icon: const Icon(Icons.code,
                      size: 18, color: Color(0xFF4B5563)),
                  label: const Text('GitHub',
                      style: TextStyle(color: Color(0xFF4B5563))),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF4B5563);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.soft,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.soft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}