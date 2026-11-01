import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import 'qr_style.dart';

QrImage? buildQrImage(String data, {required bool hasLogo}) {
  try {
    final code = QrCode.fromData(
      data: data,
      // Logo ho toh High error correction, warna Medium
      errorCorrectLevel:
          hasLogo ? QrErrorCorrectLevel.H : QrErrorCorrectLevel.M,
    );
    return QrImage(code);
  } catch (_) {
    return null; // data QR ke liye bahut zyada hai
  }
}

void paintStyledQr(
  Canvas canvas,
  double size,
  QrImage qr,
  QrStyle st, {
  ui.Image? logo,
  bool logoClearBg = true,
}) {
  final n = qr.moduleCount;
  final cell = size / n;

  final body = Paint()..isAntiAlias = true;
  if (st.fg2 != null) {
    body.shader =
        ui.Gradient.linear(Offset.zero, Offset(size, size), [st.fg, st.fg2!]);
  } else {
    body.color = st.fg;
  }

  final eyePaint = Paint()..isAntiAlias = true;
  if (st.eye != null) {
    eyePaint.color = st.eye!;
  } else {
    eyePaint.color = st.fg;
    eyePaint.shader = body.shader;
  }

  bool inEye(int r, int c) =>
      (r < 7 && c < 7) || (r < 7 && c >= n - 7) || (r >= n - 7 && c < 7);
  bool dark(int r, int c) =>
      r >= 0 && c >= 0 && r < n && c < n && !inEye(r, c) && qr.isDark(r, c);

  // ---------- body ----------
  for (var r = 0; r < n; r++) {
    for (var c = 0; c < n; c++) {
      if (!dark(r, c)) continue;
      final x = c * cell;
      final y = r * cell;
      final rect = Rect.fromLTWH(x, y, cell, cell);
      final center = rect.center;

      switch (st.body) {
        case BodyShape.square:
          canvas.drawRect(rect.inflate(0.3), body);
        case BodyShape.rounded:
          final rad = Radius.circular(cell * 0.45);
          final up = dark(r - 1, c);
          final down = dark(r + 1, c);
          final left = dark(r, c - 1);
          final right = dark(r, c + 1);
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              rect.inflate(0.2),
              topLeft: (!up && !left) ? rad : Radius.zero,
              topRight: (!up && !right) ? rad : Radius.zero,
              bottomLeft: (!down && !left) ? rad : Radius.zero,
              bottomRight: (!down && !right) ? rad : Radius.zero,
            ),
            body,
          );
        case BodyShape.dots:
          canvas.drawCircle(center, cell * 0.5, body);
        case BodyShape.smallDots:
          canvas.drawCircle(center, cell * 0.34, body);
        case BodyShape.diamond:
          final d = cell * 0.56;
          canvas.drawPath(
            Path()
              ..moveTo(center.dx, center.dy - d)
              ..lineTo(center.dx + d, center.dy)
              ..lineTo(center.dx, center.dy + d)
              ..lineTo(center.dx - d, center.dy)
              ..close(),
            body,
          );
        case BodyShape.leaf:
          final rad = Radius.circular(cell * 0.5);
          canvas.drawRRect(
            RRect.fromRectAndCorners(rect.inflate(0.2),
                topLeft: rad, bottomRight: rad),
            body,
          );
      }
    }
  }

  // ---------- eyes (teen kone ke bade square) ----------
  void drawEye(int er, int ec) {
    final outer = Rect.fromLTWH(ec * cell, er * cell, 7 * cell, 7 * cell);
    final inner = outer.deflate(cell);
    final path = Path()..fillType = PathFillType.evenOdd;

    switch (st.frame) {
      case FrameShape.square:
        path
          ..addRect(outer)
          ..addRect(inner);
      case FrameShape.rounded:
        path
          ..addRRect(RRect.fromRectAndRadius(outer, Radius.circular(cell * 2)))
          ..addRRect(
              RRect.fromRectAndRadius(inner, Radius.circular(cell * 1.2)));
      case FrameShape.circle:
        path
          ..addOval(outer)
          ..addOval(inner);
      case FrameShape.leaf:
        path
          ..addRRect(RRect.fromRectAndCorners(outer,
              topLeft: Radius.circular(cell * 3),
              bottomRight: Radius.circular(cell * 3)))
          ..addRRect(RRect.fromRectAndCorners(inner,
              topLeft: Radius.circular(cell * 2),
              bottomRight: Radius.circular(cell * 2)));
    }
    canvas.drawPath(path, eyePaint);

    final ball =
        Rect.fromLTWH((ec + 2) * cell, (er + 2) * cell, 3 * cell, 3 * cell);
    switch (st.ball) {
      case BallShape.square:
        canvas.drawRect(ball, eyePaint);
      case BallShape.rounded:
        canvas.drawRRect(
            RRect.fromRectAndRadius(ball, Radius.circular(cell * 0.9)),
            eyePaint);
      case BallShape.circle:
        canvas.drawOval(ball, eyePaint);
      case BallShape.leaf:
        canvas.drawRRect(
          RRect.fromRectAndCorners(ball,
              topLeft: Radius.circular(cell * 1.5),
              bottomRight: Radius.circular(cell * 1.5)),
          eyePaint,
        );
      case BallShape.diamond:
        final e = cell * 0.2;
        canvas.drawPath(
          Path()
            ..moveTo(ball.center.dx, ball.top - e)
            ..lineTo(ball.right + e, ball.center.dy)
            ..lineTo(ball.center.dx, ball.bottom + e)
            ..lineTo(ball.left - e, ball.center.dy)
            ..close(),
          eyePaint,
        );
    }
  }

  drawEye(0, 0);
  drawEye(0, n - 7);
  drawEye(n - 7, 0);

  // ---------- logo ----------
  if (logo != null) {
    final box = Rect.fromCenter(
        center: Offset(size / 2, size / 2), width: size * 0.2, height: size * 0.2);
    if (logoClearBg) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            box.inflate(cell * 0.7), Radius.circular(cell * 1.5)),
        Paint()..color = st.bg,
      );
    }
    final iw = logo.width.toDouble();
    final ih = logo.height.toDouble();
    final s = (box.width / iw) < (box.height / ih)
        ? box.width / iw
        : box.height / ih;
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, iw, ih),
      Rect.fromCenter(center: box.center, width: iw * s, height: ih * s),
      Paint()..filterQuality = FilterQuality.high,
    );
  }
}

/// QR ko bina screen ke, high-quality PNG mein banata hai (download/share ke liye).
Future<Uint8List> renderStyledPng({
  required String data,
  required QrStyle style,
  Uint8List? logo,
  bool logoClearBg = true,
  double size = 1024,
}) async {
  final qr = buildQrImage(data, hasLogo: logo != null);
  if (qr == null) throw Exception('Too much data for one QR code');

  ui.Image? logoImg;
  if (logo != null) logoImg = await decodeImageFromList(logo);

  final pad = size * 0.08; // quiet zone
  final total = size + pad * 2;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, total, total), Paint()..color = style.bg);
  canvas.translate(pad, pad);
  paintStyledQr(canvas, size, qr, style,
      logo: logoImg, logoClearBg: logoClearBg);

  final image =
      await recorder.endRecording().toImage(total.round(), total.round());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

/// Screen par QR dikhane wala widget. `size` poori widget ki width hai (padding ke saath).
class StyledQr extends StatefulWidget {
  final String data;
  final double size;
  final QrStyle style;
  final Uint8List? logo;
  final bool logoClearBg;

  const StyledQr({
    super.key,
    required this.data,
    required this.size,
    required this.style,
    this.logo,
    this.logoClearBg = true,
  });

  @override
  State<StyledQr> createState() => _StyledQrState();
}

class _StyledQrState extends State<StyledQr> {
  QrImage? _qr;
  ui.Image? _logoImg;

  @override
  void initState() {
    super.initState();
    _qr = buildQrImage(widget.data, hasLogo: widget.logo != null);
    _decodeLogo();
  }

  @override
  void didUpdateWidget(StyledQr old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data || (old.logo == null) != (widget.logo == null)) {
      _qr = buildQrImage(widget.data, hasLogo: widget.logo != null);
    }
    if (!identical(old.logo, widget.logo)) _decodeLogo();
  }

  Future<void> _decodeLogo() async {
    final bytes = widget.logo;
    if (bytes == null) {
      _logoImg = null;
      return;
    }
    final img = await decodeImageFromList(bytes);
    if (!mounted || !identical(widget.logo, bytes)) return;
    setState(() => _logoImg = img);
  }

  @override
  Widget build(BuildContext context) {
    final inner = widget.size / 1.16;
    final pad = (widget.size - inner) / 2;
    return Container(
      width: widget.size,
      height: widget.size,
      color: widget.style.bg,
      padding: EdgeInsets.all(pad),
      child: _qr == null
          ? const Center(
              child: Text('Too much data\nfor one QR',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            )
          : CustomPaint(
              size: Size.square(inner),
              painter: _QrPainter(
                  _qr!, widget.style, _logoImg, widget.logoClearBg),
            ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final QrImage qr;
  final QrStyle style;
  final ui.Image? logo;
  final bool clearBg;
  _QrPainter(this.qr, this.style, this.logo, this.clearBg);

  @override
  void paint(Canvas canvas, Size size) => paintStyledQr(
      canvas, size.width, qr, style,
      logo: logo, logoClearBg: clearBg);

  @override
  bool shouldRepaint(covariant _QrPainter old) => true;
}