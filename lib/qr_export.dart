import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'theme.dart';

typedef PngRenderer = Future<Uint8List> Function();

/// QR ko bina screen ke, seedha high-quality PNG mein banata hai.
Future<Uint8List> renderQrPng({
  required String data,
  required Color fg,
  required Color bg,
  bool roundDots = false,
  bool roundEyes = false,
  Uint8List? logo,
  double size = 1024,
}) async {
  ui.Image? logoImage;
  if (logo != null) {
    logoImage = await decodeImageFromList(logo);
  }

  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: logo != null ? 2 : 0,
    gapless: true,
    embeddedImage: logoImage,
    embeddedImageStyle: logoImage != null
        ? QrEmbeddedImageStyle(size: Size(size * 0.22, size * 0.22))
        : null,
    eyeStyle: QrEyeStyle(
      eyeShape: roundEyes ? QrEyeShape.circle : QrEyeShape.square,
      color: fg,
    ),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape:
          roundDots ? QrDataModuleShape.circle : QrDataModuleShape.square,
      color: fg,
    ),
  );

  final pad = size * 0.08; // quiet zone, scan ke liye zaroori
  final total = size + pad * 2;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, total, total), Paint()..color = bg);
  canvas.translate(pad, pad);
  painter.paint(canvas, Size(size, size));

  final image =
      await recorder.endRecording().toImage(total.toInt(), total.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

String _safeName(String s) {
  final t = s.trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
  return t.isEmpty ? 'qr_code' : t;
}

Uint8List _toJpg(Uint8List png) {
  final decoded = img.decodePng(png)!;
  return Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
}

Future<Uint8List> _toPdf(Uint8List png) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Center(
        child: pw.Image(pw.MemoryImage(png), width: 320, height: 320),
      ),
    ),
  );
  return doc.save();
}

void _toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

/// Library ke card se bhi isi ko call karte hain.
Future<void> shareQrPng(
    BuildContext context, PngRenderer render, String name) async {
  try {
    final png = await render();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png')],
        fileNameOverrides: ['${_safeName(name)}.png'],
      ),
    );
  } catch (e) {
    if (context.mounted) _toast(context, 'Could not share: $e');
  }
}

class ExportBar extends StatefulWidget {
  final PngRenderer render;
  final String name;
  const ExportBar({super.key, required this.render, required this.name});

  @override
  State<ExportBar> createState() => _ExportBarState();
}

class _ExportBarState extends State<ExportBar> {
  bool _busy = false;

  Future<void> _download(String fmt) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final png = await widget.render();
      final name = _safeName(widget.name);
      Uint8List bytes;
      String ext;
      MimeType mime;
      switch (fmt) {
        case 'jpg':
          bytes = _toJpg(png);
          ext = 'jpg';
          mime = MimeType.jpeg;
          break;
        case 'pdf':
          bytes = await _toPdf(png);
          ext = 'pdf';
          mime = MimeType.pdf;
          break;
        default:
          bytes = png;
          ext = 'png';
          mime = MimeType.png;
      }

      String? path;
      if (kIsWeb) {
        // Browser mein seedha download
        path = await FileSaver.instance.saveFile(
          name: name,
          bytes: bytes,
          fileExtension: ext,
          mimeType: mime,
        );
      } else {
        // Android: "Save as" dialog, jahan chaho wahan save karo
        path = await FileSaver.instance.saveAs(
          name: name,
          bytes: bytes,
          fileExtension: ext,
          mimeType: mime,
        );
      }
      if (!mounted) return;
      if (path != null) {
        _toast(context,
            kIsWeb ? 'Download started' : 'Saved as ${ext.toUpperCase()}');
      }
    } catch (e) {
      if (mounted) _toast(context, 'Could not save: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<String>(
            enabled: !_busy,
            onSelected: _download,
            position: PopupMenuPosition.under,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'png', child: Text('PNG image')),
              PopupMenuItem(value: 'jpg', child: Text('JPG image')),
              PopupMenuItem(value: 'pdf', child: Text('PDF document')),
            ],
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else
                    const Icon(Icons.download, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text('Download',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => shareQrPng(context, widget.render, widget.name),
              icon: const Icon(Icons.share_outlined, size: 20),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}