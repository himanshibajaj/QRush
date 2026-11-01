import 'package:flutter/material.dart';

enum BodyShape { square, rounded, dots, smallDots, diamond, leaf }

enum FrameShape { square, rounded, circle, leaf }

enum BallShape { square, rounded, circle, leaf, diamond }

const bodyNames = {
  BodyShape.square: 'Square',
  BodyShape.rounded: 'Rounded',
  BodyShape.dots: 'Dots',
  BodyShape.smallDots: 'Small dots',
  BodyShape.diamond: 'Diamond',
  BodyShape.leaf: 'Leaf',
};

const frameNames = {
  FrameShape.square: 'Square',
  FrameShape.rounded: 'Rounded',
  FrameShape.circle: 'Circle',
  FrameShape.leaf: 'Leaf',
};

const ballNames = {
  BallShape.square: 'Square',
  BallShape.rounded: 'Rounded',
  BallShape.circle: 'Circle',
  BallShape.leaf: 'Leaf',
  BallShape.diamond: 'Diamond',
};

class QrStyle {
  final Color fg;
  final Color? fg2; // gradient ka doosra colour (null = single colour)
  final Color bg;
  final Color? eye; // null = QR ke colour jaisa
  final BodyShape body;
  final FrameShape frame;
  final BallShape ball;

  const QrStyle({
    this.fg = const Color(0xFF1E1B4B),
    this.fg2,
    this.bg = Colors.white,
    this.eye,
    this.body = BodyShape.square,
    this.frame = FrameShape.square,
    this.ball = BallShape.square,
  });

  QrStyle copyWith({
    Color? fg,
    Color? fg2,
    Color? bg,
    Color? eye,
    BodyShape? body,
    FrameShape? frame,
    BallShape? ball,
    bool clearFg2 = false,
    bool clearEye = false,
  }) =>
      QrStyle(
        fg: fg ?? this.fg,
        fg2: clearFg2 ? null : (fg2 ?? this.fg2),
        bg: bg ?? this.bg,
        eye: clearEye ? null : (eye ?? this.eye),
        body: body ?? this.body,
        frame: frame ?? this.frame,
        ball: ball ?? this.ball,
      );

  Map<String, dynamic> toJson() => {
        'fg': fg.value,
        'fg2': fg2?.value,
        'bg': bg.value,
        'eye': eye?.value,
        'body': body.name,
        'frame': frame.name,
        'ball': ball.name,
      };

  factory QrStyle.fromJson(Map<String, dynamic> j) {
    Color? c(dynamic v) => v == null ? null : Color(v as int);
    T pick<T extends Enum>(List<T> values, dynamic name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return QrStyle(
      fg: c(j['fg']) ?? const Color(0xFF1E1B4B),
      fg2: c(j['fg2']),
      bg: c(j['bg']) ?? Colors.white,
      eye: c(j['eye']),
      body: pick(BodyShape.values, j['body'], BodyShape.square),
      frame: pick(FrameShape.values, j['frame'], FrameShape.square),
      ball: pick(BallShape.values, j['ball'], BallShape.square),
    );
  }
}

class QrTemplate {
  final String name;
  final QrStyle style;
  const QrTemplate(this.name, this.style);
}

const qrTemplates = <QrTemplate>[
  QrTemplate('Classic', QrStyle(fg: Color(0xFF000000))),
  QrTemplate(
    'Soft',
    QrStyle(
      fg: Color(0xFF1E3A5F),
      body: BodyShape.rounded,
      frame: FrameShape.rounded,
      ball: BallShape.circle,
    ),
  ),
  QrTemplate(
    'Ocean',
    QrStyle(
      fg: Color(0xFF0369A1),
      fg2: Color(0xFF1D4ED8),
      eye: Color(0xFF1D4ED8),
      body: BodyShape.dots,
      frame: FrameShape.circle,
      ball: BallShape.circle,
    ),
  ),
  QrTemplate(
    'Royal',
    QrStyle(
      fg: Color(0xFF4F46E5),
      bg: Color(0xFFEEF0FF),
      body: BodyShape.rounded,
      frame: FrameShape.rounded,
      ball: BallShape.rounded,
    ),
  ),
  QrTemplate(
    'Ruby',
    QrStyle(
      fg: Color(0xFFB91C1C),
      body: BodyShape.rounded,
      frame: FrameShape.leaf,
      ball: BallShape.leaf,
    ),
  ),
  QrTemplate(
    'Forest',
    QrStyle(
      fg: Color(0xFF166534),
      bg: Color(0xFFF0FDF4),
      body: BodyShape.leaf,
      frame: FrameShape.leaf,
      ball: BallShape.leaf,
    ),
  ),
  QrTemplate(
    'Mosaic',
    QrStyle(
      fg: Color(0xFF9F1239),
      fg2: Color(0xFF1D4ED8),
      body: BodyShape.square,
      frame: FrameShape.rounded,
      ball: BallShape.rounded,
    ),
  ),
  QrTemplate(
    'Dots',
    QrStyle(
      fg: Color(0xFF0284C7),
      body: BodyShape.smallDots,
      frame: FrameShape.rounded,
      ball: BallShape.circle,
    ),
  ),
  QrTemplate(
    'Coffee',
    QrStyle(
      fg: Color(0xFF5C4033),
      bg: Color(0xFFFDF2E9),
      body: BodyShape.diamond,
      frame: FrameShape.square,
      ball: BallShape.diamond,
    ),
  ),
  QrTemplate(
    'Ninja',
    QrStyle(
      fg: Color(0xFFBE185D),
      fg2: Color(0xFF7E22CE),
      eye: Color(0xFF1F2937),
      body: BodyShape.rounded,
      frame: FrameShape.circle,
      ball: BallShape.circle,
    ),
  ),
  QrTemplate(
    'Sunset',
    QrStyle(
      fg: Color(0xFFEA580C),
      fg2: Color(0xFFDB2777),
      body: BodyShape.dots,
      frame: FrameShape.leaf,
      ball: BallShape.rounded,
    ),
  ),
  QrTemplate(
    'Mint',
    QrStyle(
      fg: Color(0xFF0F766E),
      bg: Color(0xFFE6FFFA),
      body: BodyShape.rounded,
      frame: FrameShape.circle,
      ball: BallShape.circle,
    ),
  ),
];