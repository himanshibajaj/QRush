import 'package:flutter/material.dart';
import 'create_screen.dart';
import 'library_screen.dart';
import 'qr_types.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  /// Laptop layout mein upar ka bar MainShell dikhata hai, isliye wahan false.
  final bool showBar;
  const HomeScreen({super.key, this.showBar = true});

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Create a QR code',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deep)),
              SizedBox(height: 6),
              Text('Choose what you want your QR code to open or share.',
                  style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    ];

    for (final g in qrGroupOrder) {
      final items = qrTypes.where((t) => t.group == g).toList();
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
          child: Text(g.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.black45)),
        ),
      ));
      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _TypeTile(type: items[i]),
            childCount: items.length,
          ),
        ),
      ));
    }
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 40)));

    return Scaffold(
      appBar: showBar
          ? AppBar(
              backgroundColor: AppColors.deep,
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 20,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_2,
                        color: AppColors.deep, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('QRush',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: 0.3)),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LibraryScreen()),
                  ),
                  icon: const Icon(Icons.collections_bookmark_outlined,
                      size: 18, color: Colors.white),
                  label: const Text('My QR Library',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: CustomScrollView(slivers: slivers),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final QrType type;
  const _TypeTile({required this.type});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateScreen(type: type)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                type.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}