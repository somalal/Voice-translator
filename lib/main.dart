Claude
නියමයි, ඔයා හරියටම හරි තැනයි ඉන්නේ. “Use workflow from main” කියලා පොඩි window එකක් open වෙලා තියෙනවා.

ඒ window එක ඇතුළේ තියෙන කොළ පාට Run workflow බොත්තම ඔබන්න (Cancel එකට දකුණින් තියෙන එක, ඔයාගේ screenshot එකේ පහළ දකුණේ).
එතකොට window එක වැහිලා යනවා. තත්පර කිහිපයක් ඉඳලා page එක refresh කරන්න (page එක පහළට ඇදලා).
“Create build-apk.yml” කියන රතු ✗ run එකට උඩින් අලුත් run එකක් එනවා, කහ පාට කැරකෙන ලකුණක් සහිතව. ඒ කියන්නේ build එක පටන් අරන්.
විනාඩි 5-10ක් බලාගෙන ඉන්න, ඒ අතරේ page එක refresh කරන්න (නැත්නම් ඒක තත්පර 30කට සැරයක් ඉබේම refresh වෙනවා).

කොළ ✓ ලකුණක් ආවොත්: ඒ run එක ඔබලා, පහළට scroll කරලා Artifacts වල තියෙන voice-translator-apk download කරන්න.
රතු ✗ ලකුණක් ආවොත්: ඒ run එක ඔබලා, කලින් වගේම රතු ✗ සහිත step එක open කරලා screenshot එකක් upload කරන්න.
ඒ ✓ හෝ ✗ ලකුණ දැක්කම මට කියන්න.

Screenshot_20261026_235537_com_android_chrome_ChromeTabbedActivity.jpg
Drafting a workaround to locate the file regardless of folder name
Build #2 ත් ✗ වුණා. ඒත් මට හිතෙන හේතුවක් තියෙනවා.

ඔයා කලින් පණිවිඩයක folder නම type කළේ Iib කියලා (මුල අකුර ලොකු I, ඉංග්‍රීසි i ලොකුවට). GitHub අකුරු වල ලොකු I සහ කුඩා l එකම වගේ පේනවා. ඒ නිසා folder එක lib වගේ පේන්නේ, ඒත් ඇත්තටම නම Iib වෙන්න පුළුවන්. එතකොට build server එකට lib/main.dart හොයාගන්න බැරි වෙනවා, කලින් error එකත් ඒක තමයි.

ඒක නිවැරදි කරන්න, නම හරියටම කලින්ම පිරිලා එන link එකකින් file එක ආයෙත් හදමු:

අලුත් tab එකක් open කරලා (උඩ + ඔබලා) මේ link එක paste කරන්න:
https://github.com/somalal/Voice-translator/new/main?filename=lib/main.dart
Enter ඔබන්න. නම lib/main.dart කියලා කලින්ම පිරිලා ඇති. නම අතින් ටයිප් කරන්න එපා.
පහළ ලොකු edit box එකේ main.dart code එක paste කරන්න. මම දීපු main.dart file එක open කරලා, අකුරු ඔක්කොම copy කරන්න.
උඩ දකුණේ කොළ Commit changes... ඔබලා, එන window එකේ නැවත Commit changes ඔබන්න.
Commit කළාම build එක ඉබේම පටන් ගන්නවා, ආයෙත් Run workflow ඔබන්න ඕනෙ නැහැ. Actions tab එකට ගිහින් විනාඩි 5-10ක් බලන්න.

එක දෙයක් වෙන්න පුළුවන්: step 2 දී “A file with that name already exists” වගේ පණිවිඩයක් ආවොත්, ඒ කියන්නේ lib නම හරි, එතකොට මගේ අනුමානය වැරදියි. එහෙම වුණොත් ඒ screenshot එක upload කරන්න, මම වෙන හේතුවක් හොයන්නම්.

ඒ වගේම ඊළඟට ✗ ආවොත්, මේ වතාවේ build ඔබලා, රතු ✗ ලකුණ තියෙන step එක open කරලා ඒකේ screenshot එක upload කරන්න, එතකොට හරියටම මොකක්ද කියලා බලන්න පුළුවන්.

main.dart code එක නරවත දෙන්න

මේ තියෙන්නේ සම්පූර්ණ main.dart code එක. Code box එකේ උඩ දකුණු කෙළවරේ තියෙන copy ලකුණ ඔබලා copy කරන්න, ඒ වගේම import 'package:flutter/material.dart'; කියන පළමු පේළියේ සිට } කියන අන්තිම පේළිය දක්වා ඔක්කොම copy වෙනවද බලන්න.

dart
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




Claude is AI and can make mistakes.
Claude is responding
