class SavedQr {
  final String id;
  final String title;
  final String type;
  final String payload;
  final String purpose;
  final String recipient;
  final int fg;
  final int bg;
  final bool round;
  final bool roundEyes;
  final String? logo; // base64
  final bool logoClearBg;
  final Map<String, dynamic>? style; // naya design (QrStyle ka JSON)
  final bool favorite;
  final DateTime createdAt;

  const SavedQr({
    required this.id,
    required this.title,
    required this.type,
    required this.payload,
    required this.purpose,
    required this.recipient,
    required this.fg,
    required this.bg,
    required this.round,
    this.roundEyes = false,
    this.logo,
    this.logoClearBg = true,
    this.style,
    required this.favorite,
    required this.createdAt,
  });

  SavedQr copyWith({bool? favorite}) => SavedQr(
        id: id,
        title: title,
        type: type,
        payload: payload,
        purpose: purpose,
        recipient: recipient,
        fg: fg,
        bg: bg,
        round: round,
        roundEyes: roundEyes,
        logo: logo,
        logoClearBg: logoClearBg,
        style: style,
        favorite: favorite ?? this.favorite,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'payload': payload,
        'purpose': purpose,
        'recipient': recipient,
        'fg': fg,
        'bg': bg,
        'round': round,
        'roundEyes': roundEyes,
        'logo': logo,
        'logoClearBg': logoClearBg,
        'style': style,
        'favorite': favorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedQr.fromJson(Map<String, dynamic> j) => SavedQr(
        id: j['id'],
        title: j['title'],
        type: j['type'],
        payload: j['payload'],
        purpose: j['purpose'] ?? '',
        recipient: j['recipient'] ?? '',
        fg: j['fg'],
        bg: j['bg'],
        round: j['round'] ?? false,
        roundEyes: j['roundEyes'] ?? false,
        logo: j['logo'],
        logoClearBg: j['logoClearBg'] ?? true,
        style: j['style'] == null
            ? null
            : Map<String, dynamic>.from(j['style'] as Map),
        favorite: j['favorite'] ?? false,
        createdAt: DateTime.parse(j['createdAt']),
      );
}