// // ignore_for_file: deprecated_member_use, unused_local_variable, empty_catches, depend_on_referenced_packages
// ignore_for_file: dead_code

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pdf_made_easy/file_handling/processing_screen.dart';
import 'package:pdf_made_easy/file_handling/stream_all_files.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:path/path.dart' as p;

class ReadFromStorage extends StatefulWidget {
  const ReadFromStorage({Key? key}) : super(key: key);

  @override
  State<ReadFromStorage> createState() => _ReadFromStorageState();
}

class _ReadFromStorageState extends State<ReadFromStorage> {
  SharedPreferences? prefs;
  final FileManagerController controller = FileManagerController();
  bool isLoading = true;
  String homeDirectory = '';
  bool isProcessing = false;

  dynamic processedPdfFiles = {
    'pdfFiles': [],
    'pdfFilesCount': 0,
    'currentFileName': '',
    'count': 0,
  };

  String getFileName(String path) {
    return p.basename(path);
  }

  List<String> pdfFiles = [];
  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    processedPdfFiles['pdfFilesCount'] = pdfFiles.length;
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
    Future.delayed(Durations.short1, () {
      setState(() {
        pdfFiles.removeWhere((element) => processedFilesPath.contains(element));
        processedPdfFiles['pdfFilesCount'] = pdfFiles.length;
      });
    });
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  void getAllPdfFilesCustom() async {
    setState(() {
      isLoading = true;
    });
    Set<String> directories = {};
    Directory? externalStorageDirectory =
        await getExternalStoragePublicDirectory(
      const EnvironmentDirectory.custom(''),
    );
    homeDirectory = externalStorageDirectory!.path.toString();
    if (prefs!.getString('homeDirectory') == null) {
      prefs!.setString('homeDirectory', homeDirectory);
    }
    for (var dir in externalStorageDirectory.listSync(
        recursive: false, followLinks: false)) {
      if (dir is Directory) {
        if (dir.path.contains('DCIM') ||
            dir.path.contains('Stickers') ||
            dir.path.contains('cache') ||
            dir.path.contains('.')) {
          continue;
        }

        // change to true to get all pdf files
        try {
          for (var entity
              in dir.listSync(recursive: true, followLinks: false)) {
            try {
              if (entity is File && entity.path.endsWith('.pdf')) {
                directories.add(entity.path);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not get files'),
                ),
              );
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not get files'),
            ),
          );
        }
      } else {
        if (dir.path.endsWith('.pdf')) directories.add(dir.path);
      }
    }
    processedPdfFiles['pdfFiles'] = directories.toList();
    processedPdfFiles['pdfFilesCount'] = directories.length;
    processedPdfFiles['currentFileName'] = getFileName(directories.first);
    pdfFiles = directories.toList();

    // return pdfFiles;
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    Future.delayed(Durations.short1, () {
      getAllPdfFilesCustom();
      Future.delayed(Durations.short1, () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
        actions: [
          if (false)
            IconButton(
              onPressed: () {
                prefs!.setStringList('processedFilesPath', []);
                prefs!.setStringList('processedFilesName', []);
                prefs!.setStringList('processedFilesFolder', []);
                prefs!.setStringList('processedFilesStr', []);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All files deleted!'),
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever),
            )
        ],
      ),
      body: !isLoading
          ? StreamBuilder(
              stream: pdfFiles.isNotEmpty
                  ? Stream.fromFuture(Future.value(pdfFiles))
                  : Stream.fromFuture(Future.value([])),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data.length == 0 || pdfFiles.isEmpty) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                                    title: const Text(
                                        'Quick doc is up to date!',
                                        style: TextStyle(fontSize: 21)),
                                    subtitle: Text(
                                      'No new PDF files\n${prefs!.getStringList('processedFilesPath') != null ? prefs!.getStringList('processedFilesPath')!.length : 0} files processed!',
                                      style: const TextStyle(fontSize: 16),
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
                                    child: const Text('Go back'))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Getting your files',
                          style: TextStyle(fontSize: 20)),
                      Gap(20),
                      Padding(
                        padding: EdgeInsets.all(14.0),
                        child: LinearProgressIndicator(),
                      )
                    ],
                  );
                }

                return Container(
                  child: !isLoading
                      ? Column(
                          children: [
                            isProcessing
                                ? ProcessingScreen(
                                    homeDirectory: homeDirectory,
                                    pdfFiles: pdfFiles,
                                    processedPdfFiles: processedPdfFiles,
                                  )
                                : pdfFiles.isNotEmpty
                                    ? Card(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4,
                                              right: 4,
                                              top: 10,
                                              bottom: 10),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 100),
                                            // width: double.infinity - 100,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Card(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Center(
                                                        child: Text(
                                                          pdfFiles.isNotEmpty
                                                              ? 'New ${pdfFiles.length} PDF files found!'
                                                              : 'No new PDF files, Quick doc is up to date!',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shadowColor: Colors.white,
                                                      elevation: 6,
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        isProcessing = true;
                                                      });
                                                    },
                                                    child: const Text(
                                                      'Process all PDF',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                            Expanded(
                                child: StreamAllFiles(
                              pdfFiles: pdfFiles,
                              homeDirectory: homeDirectory,
                            )),
                          ],
                        )
                      : const Column(
                          children: [
                            Text('Getting your files',
                                style: TextStyle(fontSize: 20)),
                            Gap(20),
                            LinearProgressIndicator()
                          ],
                        ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
