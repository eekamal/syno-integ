import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lemmatizerx/lemmatizerx.dart';

class SpeachText extends StatefulWidget {
  const SpeachText({Key? key}) : super(key: key);

  @override
  _SpeachTextState createState() => _SpeachTextState();
}

class _SpeachTextState extends State<SpeachText> {
  List<String> wordsList = [
    "kitchen",
    "cooking area",
    "kitchenette",
    "cookery",
    "bathroom",
    "restroom",
    "toilet",
    "washroom",
    "meeting room",
    "boardroom",
    "assembly room",
    "hall",
    "hr room ",
    "hr"
  ];

  Map<String, String> synonymsMap = {}; // New map to store synonyms

  List<String> words = [];

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  Lemmatizer lemmatizer = Lemmatizer();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _generateSynonyms();
  }

  void _generateSynonyms() {
    for (final word in wordsList) {
      final lemma = lemmatizer.lemma(word, POS.NOUN);
      final synonyms = lemma.lemmas.where((lemma) => lemma != word).toList();
      for (final synonym in synonyms) {
        synonymsMap[synonym] = word;
      }
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      words = _lastWords.split(' ');
      words.removeWhere((item) => !synonymsMap.keys.contains(item));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? '$_lastWords'
                      : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                ),
              ),
            ),
            ListView.builder(
                itemCount: words.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Text('WORD::' + words[index]);
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
