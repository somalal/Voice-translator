import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

void main() => runApp(const ConversationApp());

class Lang {
  final String name, code, locale;
  const Lang(this.name, this.code, this.locale);
}

const langs = <Lang>[
  Lang('සිංහල', 'si', 'si_LK'),
  Lang('English', 'en', 'en_US'),
  Lang('Svenska', 'sv', 'sv_SE'),
  Lang('தமிழ்', 'ta', 'ta_IN'),
  Lang('हिन्दी', 'hi', 'hi_IN'),
  Lang('日本語', 'ja', 'ja_JP'),
  Lang('中文', 'zh-cn', 'zh_CN'),
  Lang('한국어', 'ko', 'ko_KR'),
  Lang('Français', 'fr', 'fr_FR'),
  Lang('Deutsch', 'de', 'de_DE'),
  Lang('Español', 'es', 'es_ES'),
  Lang('العربية', 'ar', 'ar_SA'),
];

class Msg {
  final int side;
  final String original, translated;
  const Msg(this.side, this.original, this.translated);
}

class ConversationApp extends StatelessWidget {
  const ConversationApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Voice Translator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true),
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

  Future<void> _toggle(int side) async {
    if (active == side) {
      await _stt.stop();
      return;
    }
    if (active != null) await _stt.stop();
    await _tts.stop();
    handled = false;
    live = '';
    setState(() {
      active = side;
      status = 'අහගෙන ඉන්නවා (${_lang(side).name})...';
    });
    await _stt.listen(
      localeId: _lang(side).locale,
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
    final ok = await _tts.isLanguageAvailable(loc);
    if (ok == 1 || ok == true) {
      await _tts.setLanguage(loc);
      await _tts.speak(text);
    } else {
      setState(() => status =
          '⚠️ ${l.name} voice එකක් phone එකේ නැහැ (Settings > Text-to-speech)');
    }
  }

  Widget _dropdown(Lang value, ValueChanged<Lang> onChanged) =>
      DropdownButtonFormField<Lang>(
        value: value,
        isExpanded: true,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
        items: [
          for (final l in langs) DropdownMenuItem(value: l, child: Text(l.name))
        ],
        onChanged: (l) => onChanged(l!),
      );

  Widget _bubble(Msg m) {
    final cs = Theme.of(context).colorScheme;
    final left = m.side == 0;
    final to = _lang(1 - m.side);
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: left ? cs.primaryContainer : cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(14)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.original,
                    style: TextStyle(fontSize: 14, color: cs.outline)),
                const SizedBox(height: 4),
                Text(m.translated, style: const TextStyle(fontSize: 20)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _speak(m.translated, to),
                      icon: const Icon(Icons.volume_up, size: 20)),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _micButton(int side) {
    final cs = Theme.of(context).colorScheme;
    final on = active == side;
    final bg = on ? cs.error : (side == 0 ? cs.primary : cs.tertiary);
    final fg = on ? cs.onError : (side == 0 ? cs.onPrimary : cs.onTertiary);
    return Expanded(
      child: SizedBox(
        height: 84,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg),
          onPressed: sttReady ? () => _toggle(side) : null,
          icon: Icon(on ? Icons.stop : Icons.mic, size: 30),
          label: Text(_lang(side).name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎙️ සංවාදය'),
        actions: [
          IconButton(
              tooltip: 'Clear',
              onPressed: () => setState(log.clear),
              icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              Expanded(child: _dropdown(a, (l) => setState(() => a = l))),
              IconButton(
                  onPressed: () => setState(() {
                        final t = a;
                        a = b;
                        b = t;
                      }),
                  icon: const Icon(Icons.swap_horiz)),
              Expanded(child: _dropdown(b, (l) => setState(() => b = l))),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: log.isEmpty
                  ? Center(
                      child: Text('පහළ බොත්තමක් ඔබලා කතා කරන්න',
                          style: TextStyle(color: cs.outline)))
                  : ListView(
                      controller: _scroll,
                      children: [for (final m in log) _bubble(m)]),
            ),
            if (live.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(live,
                    style: TextStyle(fontSize: 16, color: cs.primary)),
              ),
            SizedBox(
                height: 22,
                child: Text(status, style: TextStyle(color: cs.outline))),
            Row(children: [
              _micButton(0),
              const SizedBox(width: 10),
              _micButton(1),
            ]),
          ]),
        ),
      ),
    );
  }
}
