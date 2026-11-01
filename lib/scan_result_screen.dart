import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'qr_store.dart';
import 'saved_qr.dart';
import 'scan_info.dart';
import 'theme.dart';

class ScanResultScreen extends StatelessWidget {
  final String raw;
  const ScanResultScreen({super.key, required this.raw});

  void _toast(BuildContext c, String m) => ScaffoldMessenger.of(c)
      .showSnackBar(SnackBar(content: Text(m)));

  Future<void> _open(BuildContext context, Uri u) async {
    var ok = false;
    try {
      ok = await launchUrl(u, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && context.mounted) {
      _toast(context, 'Could not open this on your device');
    }
  }

  Future<void> _copy(BuildContext context, String text, String done) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) _toast(context, done);
  }

  Future<void> _save(BuildContext context, ScanInfo info) async {
    await QrStore.add(SavedQr(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Scanned ${info.type}',
      type: info.type,
      payload: raw,
      purpose: 'Scanned',
      recipient: '',
      fg: AppColors.navy.value,
      bg: Colors.white.value,
      round: false,
      favorite: false,
      createdAt: DateTime.now(),
    ));
    if (context.mounted) _toast(context, 'Saved to My QR Library');
  }

  ButtonStyle get _outlined => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.border),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      );

  @override
  Widget build(BuildContext context) {
    final info = parseScan(raw);
    final risky = info.openUri != null &&
        const {'Website', 'WhatsApp', 'UPI', 'Bitcoin'}.contains(info.type);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Scan result',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _card,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(info.icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.type,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deep)),
                    const Text('Detected content type',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
          if (info.details.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _card,
              child: Column(
                children: [
                  for (final e in info.details.entries) _row(e.key, e.value),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Content',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                SelectableText(raw),
              ],
            ),
          ),
          if (risky) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD8A8)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 20, color: Color(0xFFB45309)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Only open links and payment requests from sources you trust. Check the address above first.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (info.openUri != null) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _open(context, info.openUri!),
              icon: const Icon(Icons.open_in_new),
              label: Text(info.openLabel),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: _outlined,
                  onPressed: () => _copy(context, raw, 'Copied'),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: _outlined,
                  onPressed: () => _save(context, info),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          if (info.extraCopyValue != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: _outlined,
              onPressed: () => _copy(context, info.extraCopyValue!, 'Copied'),
              icon: const Icon(Icons.key, size: 18),
              label: Text(info.extraCopyLabel ?? 'Copy'),
            ),
          ],
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Scan again'),
          ),
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
              width: 90,
              child: Text(k, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: SelectableText(v,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}