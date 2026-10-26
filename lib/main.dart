import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

void main() => runApp(const VoiceTranslatorApp());

// name, translator code, speech locale
const langs = <Lang>[
  Lang('සිංහල', 'si', 'si_LK'),
  Lang('English', 'en', 'en_US'),
  Lang('Svenska (Swedish)', 'sv', 'sv_SE'),
  Lang('தமிழ் (Tamil)', 'ta', 'ta_IN'),
  Lang('हिन्दी (Hindi)', 'hi', 'hi_IN'),
  Lang('日本語 (Japanese)', 'ja', 'ja_JP'),
  Lang('中文 (Chinese)', 'zh-cn', 'zh_CN'),
  Lang('한국어 (Korean)', 'ko', 'ko_KR'),
  Lang('Français', 'fr', 'fr_FR'),
  Lang('Deutsch', 'de', 'de_DE'),
  Lang('Español', 'es', 'es_ES'),
  Lang('العربية (Arabic)', 'ar', 'ar_SA'),
];

class Lang {
  final String name, code, locale;
  const Lang(this.name, this.code, this.locale);
}

class VoiceTranslatorApp extends StatelessWidget {
  const VoiceTranslatorApp({super.key});
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
  final _input = TextEditingController();

  Lang from = langs[0], to = langs[1];
  String output = '';
  String status = '';
  bool sttReady = false, listening = false, busy = false;

  @override
  void initState() {
    super.initState();
    _stt.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') _onListenEnd();
      },
      onError: (e) => setState(() {
        listening = false;
        status = 'Voice error: ${e.errorMsg}';
      }),
    ).then((ok) => setState(() => sttReady = ok));
  }

  Future<void> _toggleMic() async {
    if (listening) {
      await _stt.stop();
      return;
    }
    await _tts.stop();
    _input.clear();
    setState(() {
      listening = true;
      status = 'අහගෙන ඉන්නවා...';
    });
    await _stt.listen(
      localeId: from.locale,
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (r) => setState(() => _input.text = r.recognizedWords),
    );
  }

  void _onListenEnd() {
    if (!listening) return;
    setState(() {
      listening = false;
      status = '';
    });
    if (_input.text.trim().isNotEmpty) _translate();
  }

  Future<void> _translate() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      busy = true;
      status = 'පරිවර්තනය කරනවා...';
    });
    try {
      final t = await _translator.translate(text, from: from.code, to: to.code);
      setState(() {
        output = t.text;
        status = '';
      });
      await _speak(t.text);
    } catch (e) {
      setState(() => status = 'දෝෂයක්: Internet එක බලන්න');
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _speak(String text) async {
    final ok = await _tts.isLanguageAvailable(to.locale.replaceAll('_', '-'));
    if (ok == 1 || ok == true) {
      await _tts.setLanguage(to.locale.replaceAll('_', '-'));
      await _tts.speak(text);
    } else {
      setState(() => status =
          '⚠️ ${to.name} voice එකක් phone එකේ නැහැ (Settings > Text-to-speech)');
    }
  }

  void _swap() => setState(() {
        final f = from;
        from = to;
        to = f;
        _input.text = output;
        output = '';
      });

  Widget _dropdown(Lang value, ValueChanged<Lang> onChanged) =>
      DropdownButtonFormField<Lang>(
        value: value,
        isExpanded: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: [
          for (final l in langs) DropdownMenuItem(value: l, child: Text(l.name))
        ],
        onChanged: (l) => onChanged(l!),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('🎙️ Voice Translator')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              Expanded(child: _dropdown(from, (l) => setState(() => from = l))),
              IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz)),
              Expanded(child: _dropdown(to, (l) => setState(() => to = l))),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _input,
              minLines: 3,
              maxLines: 5,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                  labelText: 'ඔයා කිව්වේ', border: OutlineInputBorder()),
              onSubmitted: (_) => _translate(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  child: SelectableText(
                      output.isEmpty ? 'පරිවර්තනය මෙතන පෙනෙනවා...' : output,
                      style: TextStyle(
                          fontSize: 20,
                          color: output.isEmpty ? cs.outline : cs.onSurface)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton.icon(
                  onPressed: output.isEmpty ? null : () => _speak(output),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('නැවත ඇසෙන්න')),
              TextButton.icon(
                  onPressed: output.isEmpty
                      ? null
                      : () => Clipboard.setData(ClipboardData(text: output)),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy')),
              TextButton.icon(
                  onPressed: busy ? null : _translate,
                  icon: const Icon(Icons.translate),
                  label: const Text('පරිවර්තනය')),
            ]),
            Text(status, style: TextStyle(color: cs.outline)),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              height: 80,
              child: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: listening ? cs.error : cs.primary,
                foregroundColor: listening ? cs.onError : cs.onPrimary,
                onPressed: sttReady ? _toggleMic : null,
                child: Icon(listening ? Icons.stop : Icons.mic, size: 38),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
