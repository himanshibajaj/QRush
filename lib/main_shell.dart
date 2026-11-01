import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'scan_screen.dart';
import 'theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Har tab badalne par naya screen banta hai: camera sirf Scan tab mein
  // chalta hai, aur Library hamesha taza data dikhati hai.
  Widget _page() {
    switch (_index) {
      case 1:
        return const ScanScreen();
      case 2:
        return const LibraryScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.soft,
        onDestinationSelected: (i) => setState(() => _index = i),
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