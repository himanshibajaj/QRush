import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'qr_export.dart';
import 'qr_painter.dart';
import 'qr_store.dart';
import 'qr_style.dart';
import 'qr_types.dart';
import 'saved_qr.dart';
import 'theme.dart';
import 'responsive.dart';

QrType typeOf(String label) =>
    qrTypes.firstWhere((t) => t.label == label, orElse: () => qrTypes.first);

// Purane saved QR (bina style wale) bhi chalte rahenge
QrStyle styleOf(SavedQr s) => s.style != null
    ? QrStyle.fromJson(s.style!)
    : QrStyle(
        fg: Color(s.fg),
        bg: Color(s.bg),
        body: s.round ? BodyShape.dots : BodyShape.square,
        frame: s.roundEyes ? FrameShape.circle : FrameShape.square,
        ball: s.roundEyes ? BallShape.circle : BallShape.square,
      );

// Saved settings se QR dobara banata hai (yahi "Regenerate" hai)
Widget qrOf(SavedQr q, double size) => StyledQr(
      data: q.payload,
      size: size,
      style: styleOf(q),
      logo: q.logo == null ? null : base64Decode(q.logo!),
      logoClearBg: q.logoClearBg,
    );

// Download / Share ke liye high-quality PNG
Future<Uint8List> renderSaved(SavedQr s) => renderStyledPng(
      data: s.payload,
      style: styleOf(s),
      logo: s.logo == null ? null : base64Decode(s.logo!),
      logoClearBg: s.logoClearBg,
    );

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<SavedQr> items = [];
  bool loading = true;
  bool favOnly = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = await QrStore.loadAll();
    if (!mounted) return;
    setState(() {
      items = l;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();
    final shown = items.where((e) {
      if (favOnly && !e.favorite) return false;
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.recipient.toLowerCase().contains(q) ||
          e.purpose.toLowerCase().contains(q) ||
          e.type.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My QR Library',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => query = v),
                          decoration: InputDecoration(
                            hintText: 'Search title, person, purpose...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Favorites only',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              favOnly ? AppColors.primary : Colors.white,
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onPressed: () => setState(() => favOnly = !favOnly),
                        icon: Icon(
                          Icons.star,
                          color: favOnly ? Colors.white : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: shown.isEmpty
                      ? (items.isEmpty
                          ? _emptyState()
                          : const Center(
                              child: Text('No matching QR codes found')))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          itemCount: shown.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => _card(shown[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: AppColors.soft, shape: BoxShape.circle),
                child: const Icon(Icons.qr_code_2,
                    size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text('No QR codes yet',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deep)),
              const SizedBox(height: 8),
              const Text(
                'Create your first QR code and save it here. You can search, share and regenerate it anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );

  Widget _card(SavedQr s) {
    final t = typeOf(s.type);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QrDetailScreen(qr: s)),
          );
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: qrOf(s, 72),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.deep)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(t.icon, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${s.type} · ${fmtDate(s.createdAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    if (s.purpose.isNotEmpty || s.recipient.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          [
                            if (s.purpose.isNotEmpty) s.purpose,
                            if (s.recipient.isNotEmpty) 'for ${s.recipient}',
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Favorite',
                    icon: Icon(
                      s.favorite ? Icons.star : Icons.star_border,
                      color: s.favorite ? AppColors.primary : Colors.black38,
                    ),
                    onPressed: () async {
                      await QrStore.update(s.copyWith(favorite: !s.favorite));
                      _load();
                    },
                  ),
                  IconButton(
                    tooltip: 'Share',
                    icon: const Icon(Icons.share_outlined,
                        color: AppColors.primary),
                    onPressed: () =>
                        shareQrPng(context, () => renderSaved(s), s.title),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrDetailScreen extends StatelessWidget {
  final SavedQr qr;
  const QrDetailScreen({super.key, required this.qr});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this QR?'),
        content: const Text('It will be removed from your library.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await QrStore.delete(qr.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(qr.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: qrOf(qr, 240),
                  ),
                ),
                const SizedBox(height: 16),
                ExportBar(name: qr.title, render: () => renderSaved(qr)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _row('Type', qr.type),
          _row('Created', fmtDate(qr.createdAt)),
          if (qr.purpose.isNotEmpty) _row('Purpose', qr.purpose),
          if (qr.recipient.isNotEmpty) _row('For', qr.recipient),
          _row('Content', qr.payload),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(k, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}