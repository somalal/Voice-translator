import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

void main() => runApp(const LankaVoiceApp());

class Lang {
  final String native, english, country, flag, code, locale;
  const Lang(this.native, this.english, this.country, this.flag, this.code,
      this.locale);
}

const langs = <Lang>[
  Lang('සිංහල', 'Sinhala', 'ශ්‍රී ලංකාව / Sri Lanka', '🇱🇰', 'si', 'si_LK'),
  Lang('தமிழ்', 'Tamil', 'இலங்கை / Sri Lanka', '🇱🇰', 'ta', 'ta_LK'),
  Lang('தமிழ்', 'Tamil', 'இந்தியா / India', '🇮🇳', 'ta', 'ta_IN'),
  Lang('English', 'English', 'United States', '🇺🇸', 'en', 'en_US'),
  Lang('English', 'English', 'United Kingdom', '🇬🇧', 'en', 'en_GB'),
  Lang('Svenska', 'Swedish', 'Sverige / Sweden', '🇸🇪', 'sv', 'sv_SE'),
  Lang('हिन्दी', 'Hindi', 'भारत / India', '🇮🇳', 'hi', 'hi_IN'),
  Lang('日本語', 'Japanese', '日本 / Japan', '🇯🇵', 'ja', 'ja_JP'),
  Lang('中文', 'Chinese', '中国 / China', '🇨🇳', 'zh-cn', 'zh_CN'),
  Lang('한국어', 'Korean', '대한민국 / South Korea', '🇰🇷', 'ko', 'ko_KR'),
  Lang('Français', 'French', 'France', '🇫🇷', 'fr', 'fr_FR'),
  Lang('Deutsch', 'German', 'Deutschland / Germany', '🇩🇪', 'de', 'de_DE'),
  Lang('Español', 'Spanish', 'España / Spain', '🇪🇸', 'es', 'es_ES'),
  Lang('العربية', 'Arabic', 'السعودية / Saudi Arabia', '🇸🇦', 'ar', 'ar_SA'),
];

const bgColor = Color(0xFF030712);
const cardColor = Color(0xFF0F172A);
const lineColor = Color(0xFF1E293B);
const green1 = Color(0xFF059669);
const green2 = Color(0xFF0D9488);
const purple1 = Color(0xFF4F46E5);
const purple2 = Color(0xFF7C3AED);

class Msg {
  final int side;
  final String original, translated;
  const Msg(this.side, this.original, this.translated);
}

class LankaVoiceApp extends StatelessWidget {
  const LankaVoiceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lanka Voice AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          scaffoldBackgroundColor: bgColor,
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _stt = SpeechToText();
  final _tts = FlutterTts();
  final _translator = GoogleTranslator();
  final _scroll = ScrollController();

  Lang a = langs[0], b = langs[1];
  final List<Msg> log = [];
  int? active;
  bool handled = false, sttReady = false;
  String live = '', status = '';

  Lang _lang(int side) => side == 0 ? a : b;

  @override
  void initState() {
    super.initState();
    _stt.initialize(
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && active != null) {
          _finish(active!);
        }
      },
      onError: (e) => setState(() {
        active = null;
        status = 'Voice error: ${e.errorMsg}';
      }),
    ).then((ok) => setState(() => sttReady = ok));
  }

  Future<String> _sttLocale(Lang l) async {
    String norm(String s) => s.replaceAll('-', '_').toLowerCase();
    final all = await _stt.locales();
    final want = norm(l.locale);
    for (final x in all) {
      if (norm(x.localeId) == want) return x.localeId;
    }
    final base = want.split('_').first;
    for (final x in all) {
      if (norm(x.localeId).startsWith('${base}_')) return x.localeId;
    }
    return l.locale;
  }

  Future<void> _toggle(int side) async {
    if (active == side) {
      await _stt.stop();
      return;
    }
    if (active != null) await _stt.stop();
    await _tts.stop();
    handled = false;
    live = '';
    final loc = await _sttLocale(_lang(side));
    setState(() {
      active = side;
      status = 'අහගෙන ඉන්නවා (${_lang(side).native})...';
    });
    await _stt.listen(
      localeId: loc,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (r) {
        setState(() => live = r.recognizedWords);
        if (r.finalResult) _finish(side);
      },
    );
  }

  Future<void> _finish(int side) async {
    if (handled) return;
    handled = true;
    final text = live.trim();
    setState(() {
      active = null;
      status = '';
    });
    if (text.isEmpty) return;
    final from = _lang(side), to = _lang(1 - side);
    setState(() => status = 'පරිවර්තනය කරනවා...');
    try {
      final t = await _translator.translate(text, from: from.code, to: to.code);
      setState(() {
        log.add(Msg(side, text, t.text));
        live = '';
        status = '';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });
      await _speak(t.text, to);
    } catch (e) {
      setState(() => status = 'දෝෂයක්: Internet එක බලන්න');
    }
  }

  Future<void> _speak(String text, Lang l) async {
    final loc = l.locale.replaceAll('_', '-');
    final base = loc.split('-').first;
    for (final c in [loc, base]) {
      final ok = await _tts.isLanguageAvailable(c);
      if (ok == 1 || ok == true) {
        await _tts.setLanguage(c);
        await _tts.speak(text);
        return;
      }
    }
    setState(() => status =
        '⚠️ ${l.native} voice එකක් phone එකේ නැහැ (Settings > Text-to-speech)');
  }

  void _swap() => setState(() {
        final t = a;
        a = b;
        b = t;
      });

  void _help() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('උදව්'),
        content: const Text(
            '1. උඩින් භාෂා දෙක (රටත් සමඟ) තෝරන්න.\n'
            '2. කොළ බොත්තම ඔබලා ඔයා කතා කරන්න.\n'
            '3. දම් බොත්තම ඔබලා අනෙක් පාර්ශ්වය කතා කරන්න.\n'
            '4. පරිවර්තනය text සහ කටහඬින් ලැබෙනවා.\n\n'
            'Internet එක ඕනෙ.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('හරි'))
        ],
      ),
    );
  }

  Widget _dropdown(Lang value, ValueChanged<Lang> onChanged) {
    return DropdownButtonFormField<Lang>(
      value: value,
      isExpanded: true,
      dropdownColor: cardColor,
      itemHeight: 64,
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: lineColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: lineColor)),
      ),
      selectedItemBuilder: (_) => [
        for (final l in langs)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l.flag} ${l.native} (${l.english})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16)),
              Text(l.country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          )
      ],
      items: [
        for (final l in langs)
          DropdownMenuItem(
            value: l,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l.flag} ${l.native} (${l.english})',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(l.country,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
      ],
      onChanged: (l) => onChanged(l!),
    );
  }

  Widget _bubble(Msg m) {
    final left = m.side == 0;
    final to = _lang(1 - m.side);
    final c = left ? green1 : purple1;
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
          decoration: BoxDecoration(
            color: c.withOpacity(0.18),
            border: Border.all(color: c.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.original,
                    style: const TextStyle(fontSize: 14, color: Colors.white60)),
                const SizedBox(height: 4),
                Text(m.translated, style: const TextStyle(fontSize: 21)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _speak(m.translated, to),
                      icon: const Icon(Icons.volume_up, size: 22)),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _micButton(int side) {
    final on = active == side;
    final colors = on
        ? [const Color(0xFFDC2626), const Color(0xFFE11D48)]
        : (side == 0 ? [green1, green2] : [purple1, purple2]);
    final title = on
        ? 'නවත්වන්න'
        : (side == 0 ? 'මම කතා කරන්න' : 'අනෙක් පස කතා කරන්න');
    return Expanded(
      child: Opacity(
        opacity: sttReady ? 1 : 0.5,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            height: 104,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(26),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: sttReady ? () => _toggle(side) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(on ? Icons.stop : Icons.mic_external_on, size: 30),
                    const SizedBox(height: 6),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('(${_lang(side).native})',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
                color: cardColor,
                border: Border(bottom: BorderSide(color: lineColor))),
            child: Row(children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [purple1, green2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.mic_external_on),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lanka Voice AI',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('සිංහල | தமிழ் | Global',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF34D399))),
                    ]),
              ),
              IconButton(
                  tooltip: 'Clear',
                  onPressed: () => setState(log.clear),
                  icon: const Icon(Icons.delete_outline)),
              TextButton.icon(
                  onPressed: _help,
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('උදව්')),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: lineColor)),
              child: Column(children: [
                Row(children: [
                  const Expanded(
                    child: Text('භාෂා තේරීම / மொழி தேர்வு',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  TextButton.icon(
                      onPressed: _swap,
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('මාරු කරන්න')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _dropdown(a, (l) => setState(() => a = l))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _dropdown(b, (l) => setState(() => b = l))),
                ]),
              ]),
            ),
          ),
          Expanded(
            child: log.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic_external_on,
                                size: 60, color: Colors.white24),
                            SizedBox(height: 16),
                            Text('කතා කිරීමට පහත මයික්‍රෝෆෝන බොත්තමක් ඔබන්න',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white38)),
                            SizedBox(height: 6),
                            Text(
                                'பேச கீழே உள்ள மைக்ரோஃபோனை அழுத்தவும்',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white30)),
                          ]),
                    ),
                  )
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [for (final m in log) _bubble(m)]),
          ),
          if (live.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(live,
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF34D399))),
            ),
          SizedBox(
              height: 22,
              child: Text(status,
                  style: const TextStyle(color: Colors.white54))),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: const BoxDecoration(
                color: cardColor,
                border: Border(top: BorderSide(color: lineColor))),
            child: Row(children: [
              _micButton(0),
              const SizedBox(width: 12),
              _micButton(1),
            ]),
          ),
        ]),
      ),
    );
  }
}
