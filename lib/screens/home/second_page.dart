import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lemmatizerx/lemmatizerx.dart';
import 'package:pdf_made_easy/screens/pdf/pdf_viewer.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stemmer/stemmer.dart';
import 'package:tokenizer/tokenizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, required this.uid, required this.folder})
      : super(key: key);
  final uid;
  final folder;

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool uploadingToCloud = false;
  Widget uploadWidget = const CircularProgressIndicator();
  String? email;
  String text = '';
  dynamic firestoreData;
  SharedPreferences? prefs;

  void fire() async {
    firestoreData = await FirebaseFirestore.instance
        .collection(email ?? 'cc')
        .doc(widget.uid)
        .get();
    firestoreData = firestoreData.data();
    setState(() {
      isUploading = false;
      uploadingString = '';
    });
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs!.getString('email')!;
    setState(() {
      isUploading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    setState(() {
      isUploading = false;
    });
  }

  Future<String> getTempDirectoryPath() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  Future<String> uploadPdf(String path) async {
    try {
      // Create a Reference to the file
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child('$email/${DateTime.now().toIso8601String()}.pdf');
      // Upload the file
      UploadTask uploadTask = ref.putFile(File(path));
      setState(() {
        isUploading = true;
        uploadingString = 'Uploading the file to cloud!';
        uploadWidget = StreamBuilder(
          stream: uploadTask.snapshotEvents,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            double progress = 0;
            if (snapshot.connectionState == ConnectionState.active) {
              progress =
                  snapshot.data.bytesTransferred / snapshot.data.totalBytes;
            }
            if (snapshot.connectionState == ConnectionState.done) {
              progress = 1;
              uploadWidget = const CircularProgressIndicator();
            }
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: LinearProgressIndicator(value: progress),
                ),
              ],
            );
          },
        );
      });
      uploadTask.whenComplete(() {
        setState(() {
          isUploading = false;
        });
      });
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();
      // print(downloadUrl);
      return downloadUrl;
    } catch (e) {
      // e.g, e.toString()
      // print('An error occurred while uploading the file.');
      throw e;
    }
  }

  Future<String> pickFileAndStoreInTemp() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false);

    if (result != null) {
      File file = File(result.paths.single!);
      String path = file.path;
      return path;
    } else {
      setState(() {
        isUploading = false;
      });
      throw Exception('No file selected.');
    }
  }

  Future<Set<String>> extractText(path) async {
    PDFDoc doc = await PDFDoc.fromPath(path);
    String tempText = await doc.text;
    text = tempText;
    return tokenise(text);
  }

  tokenReturn(c, tokenizer) async {
    final x = await c.stream.transform(tokenizer.transformer).toList();
    return x;
  }

  Future<Set<String>> tokenise(text) async {
    final tokenizer = Tokenizer({',', ' ', '[', '\n', ']', '(', ')', '{', '}'});
    final c = StreamController<String>();
    c.add(text);
    c.close();
    final tokens = await c.stream.transform(tokenizer.transformer).toList();

    tokens.removeWhere((element) =>
        element == '' || element == ' ' || element == ',' || element == '\n');
    return lemma(tokens);
  }

  Set<String> lemma(listText) {
    Lemmatizer lemmatizer = Lemmatizer();
    Set<String> lemmaList = {};
    for (var i = 0; i < listText.length; i++) {
      lemmaList.add(listText[i].toString().trim().toLowerCase());
      SnowballStemmer stemmer = SnowballStemmer();
      lemmaList.add(stemmer.stem(listText[i]));
      List<Lemma> lemmasTemp = lemmatizer.lemmas(listText[i]);
      for (var i = 0; i < lemmasTemp.length; i++) {
        lemmaList.add(lemmasTemp[0].form);
      }
    }
    return lemmaList;
  }

  String getFileName(String path) {
    return p.basename(path);
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw e; // Re-throw the exception to allow calling code to handle it.
    }
  }

  String uploadingString = 'Loading...';
  bool isUploading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            kIsWeb ? const Color.fromARGB(141, 158, 158, 158) : null,
        child: const Icon(
          Icons.add,
          // color: !kIsWeb
          // ? Theme.of(context).floatingActionButtonTheme.foregroundColor
          // : Colors.white,
        ),
        onPressed: () async {
          if (kIsWeb) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'This feature is not available on web\nPlease use app to upload files!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
            return;
          }

          setState(() {
            isUploading = true;
            uploadingString = 'Getting started';
          });
          String path1 = await pickFileAndStoreInTemp();
          setState(() {
            uploadingString = 'Processing the text';
          });
          Set<String> lemma = await extractText(path1);
          setState(() {
            uploadingString = 'Uploading the file to cloud!';
          });
          String downloadUrl = await uploadPdf(path1);
          TextEditingController controller = TextEditingController(
              text: getFileName(path1).replaceAll('.pdf', ''));
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Name your Document'),
                  content: TextField(
                    controller: controller,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        deleteFile(downloadUrl);
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Set temp = await tokenise(controller.text);
                        for (var element in temp) {
                          lemma.add(element);
                        }
                        String text = lemma.join(' ');
                        Navigator.of(context).pop();
                        await FirebaseFirestore.instance
                            .collection(email ?? 'cc')
                            .doc(widget.uid)
                            .set({
                          'files': FieldValue.arrayUnion([
                            {
                              'name': controller.text,
                              'path': downloadUrl,
                              'lemma': lemma.toList(),
                              'str': text,
                            }
                          ])
                        }, SetOptions(merge: true));

                        await FirebaseFirestore.instance
                            .collection('lemma')
                            .doc(email)
                            .set({
                          'data': FieldValue.arrayUnion([
                            {
                              'folder': widget.folder,
                              'name': controller.text,
                              'path': downloadUrl,
                              'lemma': lemma.toList(),
                              'str': text,
                            }
                          ])
                        }, SetOptions(merge: true));
                        setState(() {
                          isUploading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'File uploaded successfully to cloud! \nIn ${firestoreData['folder']} folder',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              });
        },
      ),
      body: !isUploading
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(email ?? 'cc')
                  .doc(widget.uid)
                  .snapshots(),
              initialData: null,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data['files'].isEmpty) {
                  return const Center(
                    child: Text(
                      'No files found',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                return Container(
                    padding:
                        const EdgeInsets.only(top: 20, left: 15, right: 15),
                    child: ListView.builder(
                      itemCount: snapshot.data['files'].length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Color.fromARGB(65, 33, 149, 243),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: const Text(
                                            'Confirm you want to delete the file permanently?',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('cancel'),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteFile(
                                                    snapshot.data['files']
                                                        [index]['path']);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    content: Text(
                                                      'File deleted!',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                );
                                                FirebaseFirestore.instance
                                                    .collection(email!)
                                                    .doc(widget.uid)
                                                    .update({
                                                  'files':
                                                      FieldValue.arrayRemove([
                                                    snapshot.data['files']
                                                        [index]
                                                  ])
                                                });
                                              },
                                              label: const Text(
                                                'Confirm',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              icon: const Icon(
                                                Icons.warning,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                              leading: const Icon(Icons.file_open_outlined),
                              title: Text(
                                snapshot.data['files'][index]['name'] ??
                                    'something',
                                style: const TextStyle(fontSize: 16),
                              ),
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewer(
                                      path: snapshot.data['files'][index]
                                          ['path'],
                                      fileName: snapshot.data['files'][index]
                                          ['name'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ));
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !uploadingString.contains('Processing')
                      ? uploadWidget
                      : const Text(''),
                  const Gap(12),
                  Text(
                    uploadingString,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
    );
  }
}
