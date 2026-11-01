import 'package:flutter/material.dart';

String fmtDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final min = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${m[d.month - 1]} ${d.year}, $h:$min $ap';
}

class Vals {
  final Map<String, String> m;
  Vals(this.m);
  String operator [](String k) => (m[k] ?? '').trim();
}

enum FieldKind { text, choice, datetime }

class QrField {
  final String key;
  final String label;
  final FieldKind kind;
  final TextInputType keyboard;
  final List<String> options;
  final int lines;
  final String? dependsOn;
  final String? dependsValue;
  const QrField(
    this.key,
    this.label, {
    this.kind = FieldKind.text,
    this.keyboard = TextInputType.text,
    this.options = const [],
    this.lines = 1,
    this.dependsOn,
    this.dependsValue,
  });
}

class QrType {
  final String label;
  final String group;
  final IconData icon;
  final List<Color> colors;
  final List<QrField> fields;
  final String Function(Vals v) build;
  final String? note;
  QrType(this.label, this.group, this.icon, this.colors, this.fields, this.build,
      {this.note});
}

const qrGroupOrder = [
  'Basics',
  'People & Places',
  'Social & Video',
  'Files & More',
  'Payments',
];

// ---------- helpers ----------
String _url(String u) {
  if (u.isEmpty) return '';
  return u.startsWith('http://') || u.startsWith('https://') ? u : 'https://$u';
}

String _query(Map<String, String> p) {
  final parts = <String>[];
  p.forEach((k, v) {
    if (v.isNotEmpty) parts.add('$k=${Uri.encodeComponent(v)}');
  });
  return parts.isEmpty ? '' : '?${parts.join('&')}';
}

String _wifiEsc(String s) =>
    s.replaceAllMapped(RegExp(r'([\\;,:"])'), (m) => '\\${m[1]}');

String _icsTime(String iso) => iso.replaceAll('-', '').replaceAll(':', '');

String _profile(String base, String s) {
  if (s.isEmpty) return '';
  if (s.startsWith('http') || s.contains('/')) return _url(s);
  return '$base${s.startsWith('@') ? s.substring(1) : s}';
}

// ---------- colours (sab ek hi indigo family) ----------
const _violet = Color(0xFF4F46E5);
const _violet2 = Color(0xFF6366F1);
const _pink = Color(0xFF4338CA);
const _pink2 = Color(0xFF6366F1);
const _yellow = Color(0xFF6366F1);
const _mint = Color(0xFF818CF8);
const _teal = Color(0xFF4F46E5);
const _orange = Color(0xFF4338CA);
const _blue = Color(0xFF4F46E5);
const _blue2 = Color(0xFF6366F1);
const _red = Color(0xFF4338CA);
const _red2 = Color(0xFF6366F1);
const _green = Color(0xFF4F46E5);

// ---------- all types ----------
final List<QrType> qrTypes = [
  // ===== Basics =====
  QrType('Website', 'Basics', Icons.language, [_violet, _violet2],
      const [QrField('url', 'Website link', keyboard: TextInputType.url)],
      (v) => _url(v['url'])),
  QrType('Text', 'Basics', Icons.text_fields, [_pink, _pink2],
      const [QrField('text', 'Your text', lines: 4)], (v) => v['text']),
  QrType('Email', 'Basics', Icons.email, [_blue, _blue2], const [
    QrField('email', 'Email address', keyboard: TextInputType.emailAddress),
    QrField('subject', 'Subject (optional)'),
    QrField('body', 'Message (optional)', lines: 3),
  ],
      (v) => v['email'].isEmpty
          ? ''
          : 'mailto:${v['email']}${_query({'subject': v['subject'], 'body': v['body']})}'),
  QrType('Phone', 'Basics', Icons.call, [_red, _red2],
      const [QrField('phone', 'Phone number', keyboard: TextInputType.phone)],
      (v) => v['phone'].isEmpty ? '' : 'tel:${v['phone']}'),
  QrType('SMS', 'Basics', Icons.sms, [_violet, _pink], const [
    QrField('phone', 'Phone number', keyboard: TextInputType.phone),
    QrField('msg', 'Message', lines: 3),
  ], (v) => v['phone'].isEmpty ? '' : 'SMSTO:${v['phone']}:${v['msg']}'),

  // ===== People & Places =====
  QrType('vCard', 'People & Places', Icons.contact_page, [_orange, _yellow], const [
    QrField('name', 'Full name'),
    QrField('org', 'Company (optional)'),
    QrField('phone', 'Phone', keyboard: TextInputType.phone),
    QrField('email', 'Email', keyboard: TextInputType.emailAddress),
    QrField('website', 'Website (optional)', keyboard: TextInputType.url),
    QrField('address', 'Address (optional)'),
  ], (v) {
    if (v['name'].isEmpty) return '';
    return [
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:${v['name']}',
      if (v['org'].isNotEmpty) 'ORG:${v['org']}',
      if (v['phone'].isNotEmpty) 'TEL:${v['phone']}',
      if (v['email'].isNotEmpty) 'EMAIL:${v['email']}',
      if (v['website'].isNotEmpty) 'URL:${_url(v['website'])}',
      if (v['address'].isNotEmpty) 'ADR:;;${v['address']};;;;',
      'END:VCARD',
    ].join('\n');
  }),
  QrType('MeCard', 'People & Places', Icons.badge, [_pink, _orange], const [
    QrField('name', 'Full name'),
    QrField('phone', 'Phone', keyboard: TextInputType.phone),
    QrField('email', 'Email', keyboard: TextInputType.emailAddress),
    QrField('website', 'Website (optional)', keyboard: TextInputType.url),
    QrField('address', 'Address (optional)'),
  ], (v) {
    if (v['name'].isEmpty) return '';
    final parts = [
      'N:${v['name']}',
      if (v['phone'].isNotEmpty) 'TEL:${v['phone']}',
      if (v['email'].isNotEmpty) 'EMAIL:${v['email']}',
      if (v['website'].isNotEmpty) 'URL:${_url(v['website'])}',
      if (v['address'].isNotEmpty) 'ADR:${v['address']}',
    ];
    return 'MECARD:${parts.join(';')};;';
  }),
  QrType('Location', 'People & Places', Icons.location_on, [_green, _mint], const [
    QrField('mode', 'Find location by',
        kind: FieldKind.choice, options: ['Address', 'Coordinates']),
    QrField('address', 'Full address',
        lines: 2, dependsOn: 'mode', dependsValue: 'Address'),
    QrField('lat', 'Latitude (e.g. 19.0760)',
        keyboard: TextInputType.numberWithOptions(decimal: true, signed: true),
        dependsOn: 'mode',
        dependsValue: 'Coordinates'),
    QrField('lng', 'Longitude (e.g. 72.8777)',
        keyboard: TextInputType.numberWithOptions(decimal: true, signed: true),
        dependsOn: 'mode',
        dependsValue: 'Coordinates'),
  ], (v) {
    if (v['mode'] == 'Coordinates') {
      return (v['lat'].isEmpty || v['lng'].isEmpty)
          ? ''
          : 'geo:${v['lat']},${v['lng']}';
    }
    return v['address'].isEmpty
        ? ''
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(v['address'])}';
  },
      note: 'With an address, scanning opens the place in Google Maps.'),
  QrType('Wi-Fi', 'People & Places', Icons.wifi, [_teal, _mint], const [
    QrField('ssid', 'Wi-Fi name (SSID)'),
    QrField('pass', 'Password'),
    QrField('enc', 'Security', kind: FieldKind.choice, options: ['WPA/WPA2', 'WEP', 'None']),
  ], (v) {
    if (v['ssid'].isEmpty) return '';
    final t = v['enc'] == 'WEP' ? 'WEP' : (v['enc'] == 'None' ? 'nopass' : 'WPA');
    final p = t == 'nopass' ? '' : 'P:${_wifiEsc(v['pass'])};';
    return 'WIFI:T:$t;S:${_wifiEsc(v['ssid'])};$p;';
  }),
  QrType('Event', 'People & Places', Icons.event, [_violet, _blue], const [
    QrField('title', 'Event title'),
    QrField('loc', 'Location (optional)'),
    QrField('start', 'Starts', kind: FieldKind.datetime),
    QrField('end', 'Ends (optional)', kind: FieldKind.datetime),
  ], (v) {
    if (v['title'].isEmpty || v['start'].isEmpty) return '';
    final end = v['end'].isEmpty ? v['start'] : v['end'];
    return [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'BEGIN:VEVENT',
      'SUMMARY:${v['title']}',
      if (v['loc'].isNotEmpty) 'LOCATION:${v['loc']}',
      'DTSTART:${_icsTime(v['start'])}',
      'DTEND:${_icsTime(end)}',
      'END:VEVENT',
      'END:VCALENDAR',
    ].join('\n');
  }),

  // ===== Social & Video =====
  QrType('Facebook', 'Social & Video', Icons.facebook, [_blue, _violet],
      const [QrField('link', 'Profile / page link or username')],
      (v) => _profile('https://facebook.com/', v['link'])),
  QrType('Twitter / X', 'Social & Video', Icons.alternate_email, [_violet, _blue2],
      const [QrField('link', 'Username or profile link')],
      (v) => _profile('https://x.com/', v['link'])),
  QrType('YouTube', 'Social & Video', Icons.smart_display, [_red, _pink],
      const [QrField('link', 'Video / channel link or video ID')], (v) {
    final s = v['link'];
    if (s.isEmpty) return '';
    if (s.startsWith('http') || s.contains('.')) return _url(s);
    return 'https://youtu.be/$s';
  }),
  QrType('WhatsApp', 'Social & Video', Icons.chat, [_green, _teal], const [
    QrField('phone', 'Phone number (with country code)',
        keyboard: TextInputType.phone),
    QrField('msg', 'Pre-filled message (optional)', lines: 2),
  ], (v) {
    final d = v['phone'].replaceAll(RegExp(r'[^0-9]'), '');
    if (d.isEmpty) return '';
    return 'https://wa.me/$d${_query({'text': v['msg']})}';
  },
      note: 'Scanning opens a WhatsApp chat with this number. Example: 919876543210'),
  QrType('Social Media', 'Social & Video', Icons.share, [_pink, _yellow], const [
    QrField('insta', 'Instagram (username or link)'),
    QrField('fb', 'Facebook (username or link)'),
    QrField('x', 'X / Twitter (username or link)'),
    QrField('linkedin', 'LinkedIn (profile link)'),
    QrField('yt', 'YouTube (channel link)'),
    QrField('wa', 'WhatsApp number (with country code)', keyboard: TextInputType.phone),
  ], (v) {
    final waDigits = v['wa'].replaceAll(RegExp(r'[^0-9]'), '');
    return [
      if (v['insta'].isNotEmpty) 'Instagram: ${_profile('https://instagram.com/', v['insta'])}',
      if (v['fb'].isNotEmpty) 'Facebook: ${_profile('https://facebook.com/', v['fb'])}',
      if (v['x'].isNotEmpty) 'X: ${_profile('https://x.com/', v['x'])}',
      if (v['linkedin'].isNotEmpty) 'LinkedIn: ${_url(v['linkedin'])}',
      if (v['yt'].isNotEmpty) 'YouTube: ${_url(v['yt'])}',
      if (waDigits.isNotEmpty) 'WhatsApp: https://wa.me/$waDigits',
    ].join('\n');
  },
      note: 'Scanners will show all your links as a list that people can tap.'),
  QrType('Video', 'Social & Video', Icons.videocam, [_orange, _red],
      const [QrField('link', 'Video link')], (v) => _url(v['link']),
      note: 'Paste a link to any video (YouTube, Vimeo, Google Drive...).'),

  // ===== Files & More =====
  QrType('PDF', 'Files & More', Icons.picture_as_pdf, [_red, _orange],
      const [QrField('link', 'PDF link')], (v) => _url(v['link']),
      note: 'Upload your PDF to Google Drive or Dropbox, set sharing to "Anyone with the link", then paste the link here. Direct file upload is coming soon.'),
  QrType('MP3', 'Files & More', Icons.music_note, [_pink, _violet],
      const [QrField('link', 'Audio link')], (v) => _url(v['link']),
      note: 'Paste a link to your audio (Drive, Spotify, SoundCloud...). Direct upload is coming soon.'),
  QrType('Image Gallery', 'Files & More', Icons.photo_library, [_mint, _blue],
      const [QrField('link', 'Album / gallery link')], (v) => _url(v['link']),
      note: 'Paste a Google Photos or Drive album link.'),
  QrType('App Store', 'Files & More', Icons.storefront, [_green, _teal],
      const [QrField('link', 'Play Store / App Store link')], (v) => _url(v['link']),
      note: 'Paste the link to your app on Google Play or the App Store.'),
  QrType('Rating', 'Files & More', Icons.star_rate, [_yellow, _orange],
      const [QrField('link', 'Review page link')], (v) => _url(v['link']),
      note: 'Paste your Google Maps or Play Store review link so people can rate you right after scanning.'),
  QrType('Feedback', 'Files & More', Icons.rate_review, [_violet2, _pink], const [
    QrField('email', 'Where should feedback go? (email)', keyboard: TextInputType.emailAddress),
    QrField('subject', 'Subject (optional)'),
  ],
      (v) => v['email'].isEmpty
          ? ''
          : 'mailto:${v['email']}${_query({'subject': v['subject'].isEmpty ? 'Feedback' : v['subject'], 'body': 'My feedback: '})}',
      note: 'Scanning opens the email app with the subject filled in, so people can send feedback quickly.'),

  // ===== Payments =====
  QrType('UPI', 'Payments', Icons.account_balance_wallet, [_green, _blue], const [
    QrField('vpa', 'UPI ID (e.g. name@bank)', keyboard: TextInputType.emailAddress),
    QrField('name', 'Payee name'),
    QrField('amount', 'Amount in INR (optional)',
        keyboard: TextInputType.numberWithOptions(decimal: true)),
    QrField('note', 'Note (optional)'),
  ], (v) {
    if (v['vpa'].isEmpty) return '';
    final p = <String>[
      'pa=${v['vpa']}',
      if (v['name'].isNotEmpty) 'pn=${Uri.encodeComponent(v['name'])}',
      if (v['amount'].isNotEmpty) 'am=${v['amount']}',
      'cu=INR',
      if (v['note'].isNotEmpty) 'tn=${Uri.encodeComponent(v['note'])}',
    ];
    return 'upi://pay?${p.join('&')}';
  },
      note: 'Works with UPI apps like Google Pay, PhonePe and Paytm. Double-check the UPI ID before printing.'),
  QrType('Bitcoin', 'Payments', Icons.currency_bitcoin, [_orange, _yellow], const [
    QrField('addr', 'Wallet address'),
    QrField('amount', 'Amount in BTC (optional)', keyboard: TextInputType.numberWithOptions(decimal: true)),
    QrField('label', 'Label (optional)'),
  ],
      (v) => v['addr'].isEmpty
          ? ''
          : 'bitcoin:${v['addr']}${_query({'amount': v['amount'], 'label': v['label']})}'),
];