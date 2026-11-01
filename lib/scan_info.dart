import 'package:flutter/material.dart';

class ScanInfo {
  final String type; // qr_types.dart ke labels se match hona chahiye
  final IconData icon;
  final Map<String, String> details;
  final Uri? openUri;
  final String openLabel;
  final String? extraCopyLabel;
  final String? extraCopyValue;

  const ScanInfo(
    this.type,
    this.icon,
    this.details, {
    this.openUri,
    this.openLabel = 'Open',
    this.extraCopyLabel,
    this.extraCopyValue,
  });
}

final _domainLike =
    RegExp(r'^(www\.)?[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+(/\S*)?$');

Map<String, String> _wifi(String s) {
  final body = s.substring(5);
  final parts = <String>[];
  final buf = StringBuffer();
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    if (c == '\\' && i + 1 < body.length) {
      buf.write(body[i + 1]);
      i++;
    } else if (c == ';') {
      parts.add(buf.toString());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  if (buf.isNotEmpty) parts.add(buf.toString());
  final out = <String, String>{};
  for (final p in parts) {
    final k = p.indexOf(':');
    if (k > 0) out[p.substring(0, k).toUpperCase()] = p.substring(k + 1);
  }
  return out;
}

Map<String, String> _lines(String raw) {
  final out = <String, String>{};
  for (final line in raw.split(RegExp(r'\r?\n'))) {
    final i = line.indexOf(':');
    if (i <= 0) continue;
    final key = line.substring(0, i).split(';').first.toUpperCase();
    final val = line.substring(i + 1).trim();
    if (val.isEmpty) continue;
    out.putIfAbsent(key, () => val);
  }
  return out;
}

String _prettyIcs(String v) {
  final m =
      RegExp(r'^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2}))?').firstMatch(v);
  if (m == null) return v;
  final date = '${m[1]}-${m[2]}-${m[3]}';
  return m[4] == null ? date : '$date ${m[4]}:${m[5]}';
}

ScanInfo parseScan(String raw) {
  final t = raw.trim();
  final l = t.toLowerCase();

  if (l.startsWith('http://') || l.startsWith('https://')) {
    final u = Uri.tryParse(t);
    final wa = l.startsWith('https://wa.me/');
    return ScanInfo(
      wa ? 'WhatsApp' : 'Website',
      wa ? Icons.chat : Icons.language,
      {if (u != null && u.host.isNotEmpty) 'Site': u.host},
      openUri: u,
      openLabel: 'Open link',
    );
  }

  if (l.startsWith('wifi:')) {
    final m = _wifi(t);
    final pass = m['P'] ?? '';
    return ScanInfo(
      'Wi-Fi',
      Icons.wifi,
      {
        if ((m['S'] ?? '').isNotEmpty) 'Network': m['S']!,
        if (pass.isNotEmpty) 'Password': pass,
        if ((m['T'] ?? '').isNotEmpty) 'Security': m['T']!,
      },
      extraCopyLabel: pass.isNotEmpty ? 'Copy password' : null,
      extraCopyValue: pass.isNotEmpty ? pass : null,
    );
  }

  if (l.startsWith('begin:vcard')) {
    final m = _lines(t);
    return ScanInfo('vCard', Icons.contact_page, {
      if (m['FN'] != null) 'Name': m['FN']!,
      if (m['ORG'] != null) 'Company': m['ORG']!,
      if (m['TEL'] != null) 'Phone': m['TEL']!,
      if (m['EMAIL'] != null) 'Email': m['EMAIL']!,
      if (m['URL'] != null) 'Website': m['URL']!,
    });
  }

  if (l.startsWith('mecard:')) {
    final out = <String, String>{};
    for (final p in t.substring(7).split(';')) {
      final k = p.indexOf(':');
      if (k > 0) out[p.substring(0, k).toUpperCase()] = p.substring(k + 1);
    }
    return ScanInfo('MeCard', Icons.badge, {
      if (out['N'] != null) 'Name': out['N']!,
      if (out['TEL'] != null) 'Phone': out['TEL']!,
      if (out['EMAIL'] != null) 'Email': out['EMAIL']!,
      if (out['URL'] != null) 'Website': out['URL']!,
      if (out['ADR'] != null) 'Address': out['ADR']!,
    });
  }

  if (l.startsWith('mailto:')) {
    final u = Uri.tryParse(t);
    final subject = u?.queryParameters['subject'];
    return ScanInfo(
      'Email',
      Icons.email,
      {
        if (u != null && u.path.isNotEmpty) 'To': u.path,
        if (subject != null) 'Subject': subject,
      },
      openUri: u,
      openLabel: 'Write email',
    );
  }

  if (l.startsWith('tel:')) {
    return ScanInfo('Phone', Icons.call, {'Number': t.substring(4)},
        openUri: Uri.tryParse(t), openLabel: 'Call');
  }

  if (l.startsWith('smsto:') || l.startsWith('sms:')) {
    final body = t.substring(l.startsWith('smsto:') ? 6 : 4);
    final String number;
    final String msg;
    if (l.startsWith('sms:') && body.contains('?')) {
      number = body.split('?').first;
      msg = Uri.tryParse(t)?.queryParameters['body'] ?? '';
    } else {
      final i = body.indexOf(':');
      number = i == -1 ? body : body.substring(0, i);
      msg = i == -1 ? '' : body.substring(i + 1);
    }
    return ScanInfo(
      'SMS',
      Icons.sms,
      {'Number': number, if (msg.isNotEmpty) 'Message': msg},
      openUri: Uri(
        scheme: 'sms',
        path: number,
        queryParameters: msg.isEmpty ? null : {'body': msg},
      ),
      openLabel: 'Send SMS',
    );
  }

  if (l.startsWith('geo:')) {
    final c = t.substring(4).split('?').first;
    return ScanInfo(
      'Location',
      Icons.location_on,
      {'Coordinates': c},
      openUri:
          Uri.tryParse('https://www.google.com/maps/search/?api=1&query=$c'),
      openLabel: 'Open in Maps',
    );
  }

  if (l.startsWith('upi:')) {
    final u = Uri.tryParse(t);
    final q = u?.queryParameters ?? const <String, String>{};
    return ScanInfo(
      'UPI',
      Icons.account_balance_wallet,
      {
        if (q['pn'] != null) 'Payee': q['pn']!,
        if (q['pa'] != null) 'UPI ID': q['pa']!,
        if (q['am'] != null) 'Amount': '₹${q['am']}',
        if (q['tn'] != null) 'Note': q['tn']!,
      },
      openUri: u,
      openLabel: 'Open in UPI app',
    );
  }

  if (l.startsWith('bitcoin:')) {
    final u = Uri.tryParse(t);
    final amount = u?.queryParameters['amount'];
    return ScanInfo(
      'Bitcoin',
      Icons.currency_bitcoin,
      {
        if (u != null && u.path.isNotEmpty) 'Address': u.path,
        if (amount != null) 'Amount': '$amount BTC',
      },
      openUri: u,
      openLabel: 'Open wallet',
    );
  }

  if (l.contains('begin:vevent')) {
    final m = _lines(t);
    return ScanInfo('Event', Icons.event, {
      if (m['SUMMARY'] != null) 'Title': m['SUMMARY']!,
      if (m['LOCATION'] != null) 'Where': m['LOCATION']!,
      if (m['DTSTART'] != null) 'Starts': _prettyIcs(m['DTSTART']!),
      if (m['DTEND'] != null) 'Ends': _prettyIcs(m['DTEND']!),
    });
  }

  if (!t.contains(' ') && _domainLike.hasMatch(t)) {
    final u = Uri.tryParse('https://$t');
    return ScanInfo(
      'Website',
      Icons.language,
      {if (u != null) 'Site': u.host},
      openUri: u,
      openLabel: 'Open link',
    );
  }

  return const ScanInfo('Text', Icons.text_fields, {});
}