import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quick_docs/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokenizer/tokenizer.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

// ignore: must_be_immutable
class ProcessingScreen extends StatefulWidget {
  ProcessingScreen({
    required this.homeDirectory,
    required this.pdfFiles,
    required this.processedPdfFiles,
  });
  final homeDirectory;
  final Map<String, dynamic> processedPdfFiles;
  final List<String> pdfFiles;
  bool isProcessing = false;
  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with WidgetsBindingObserver {
  SharedPreferences? prefs;
  bool isProcessing = true;
  Future<Set<String>> extractText(path) async {
    Map<String, dynamic> result = await extractTextFromPdf(path);
    String tempText = '';
    if (result['status'] == 'success') {
      tempText = result['processed_text'] ?? '';
    }
    return tokenise(tempText, path);
  }

  bool _isRunning = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _isRunning = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      initPrefs();
      Future.delayed(Durations.short1, () {
        processPdfFiles();
      });
    });
  }

  String getFileName(String path) {
    return p.basename(path);
  }

  Future<Set<String>> tokenise(text, path) async {
    // final string = 'Hello, world';
    final tokenizer = Tokenizer({',', ' ', '[', '\n', ']', '(', ')', '{', '}'});
    final c = StreamController<String>();

    c.add(text);
    c.close();
    final tokens = await c.stream.transform(tokenizer.transformer).toList();

    tokens.removeWhere((element) =>
        element == '' || element == ' ' || element == ',' || element == '\n');

    List<String> fileName = getFileName(path).split(' ').toList();
    tokens.addAll(fileName);
    tokens.map((e) => e.toLowerCase()).toList();
    return tokens.toSet();
  }

  void processPdfFiles() async {
    widget.processedPdfFiles['pdfFilesCount'] = widget.pdfFiles.length;
    List<String> processedFilesPath =
        prefs!.getStringList('processedFilesPath') ?? [];
    List<String> processedFilesName =
        prefs!.getStringList('processedFilesName') ?? [];
    List<String> processedFilesFolder =
        prefs!.getStringList('processedFilesFolder') ?? [];
    List<String> processedFilesStr =
        prefs!.getStringList('processedFilesStr') ?? [];

    if (processedFilesStr.length == processedFilesFolder.length &&
        processedFilesFolder.length == processedFilesName.length &&
        processedFilesName.length == processedFilesPath.length) {
      final min1 = min(processedFilesStr.length, processedFilesFolder.length);
      final min2 = min(processedFilesName.length, processedFilesPath.length);
      final min3 = min(min1, min2);
      processedFilesStr = processedFilesStr.sublist(0, min3);
      processedFilesFolder = processedFilesFolder.sublist(0, min3);
      processedFilesName = processedFilesName.sublist(0, min3);
      processedFilesPath = processedFilesPath.sublist(0, min3);
    }
    widget.pdfFiles
        .removeWhere((element) => processedFilesPath.contains(element));
    setState(() {
      widget.processedPdfFiles['pdfFilesCount'] = widget.pdfFiles.length;
    });

    for (var i = 0; i < widget.pdfFiles.length; i++) {
      if (_isRunning == false) {
        break;
      }
      Set<String> textLemmaSet = await extractText(widget.pdfFiles[i]);
      processedFilesStr.add(textLemmaSet.join(' '));
      processedFilesPath.add(widget.pdfFiles[i]);
      processedFilesName.add(getFileName(widget.pdfFiles[i]));
      processedFilesFolder.add(
          'Home${File(widget.pdfFiles[i]).parent.path.toString().replaceFirst(widget.homeDirectory, '')}');

      prefs!.setStringList('processedFilesPath', processedFilesPath);
      prefs!.setStringList('processedFilesName', processedFilesName);
      prefs!.setStringList('processedFilesFolder', processedFilesFolder);
      prefs!.setStringList('processedFilesStr', processedFilesStr);

      setState(() {
        widget.processedPdfFiles['count'] = i + 1;
        widget.processedPdfFiles['currentFileName'] =
            getFileName(widget.pdfFiles[i]);
      });
    }
    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.pdfFiles.isNotEmpty && isProcessing
        ? Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blue.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minHeight: 100),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '${widget.processedPdfFiles['count']} / ${widget.processedPdfFiles['pdfFilesCount']} files processed',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${widget.processedPdfFiles['currentFileName']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Gap(10),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LinearProgressIndicator(
                          value: widget.processedPdfFiles['count'] /
                              widget.processedPdfFiles['pdfFilesCount'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Column(
                      children: [
                        Center(
                          child: ListTile(
                            title: const Text('Quick doc is up to date!',
                                style: TextStyle(fontSize: 20)),
                            subtitle: Text(
                              '${widget.pdfFiles.length} new files\n${prefs!.get('processedFilesPath') != null ? prefs!.getStringList('processedFilesPath')!.length : 0} files found in total!',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const Gap(15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.white,
                            elevation: 6,
                            side: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Go back'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
