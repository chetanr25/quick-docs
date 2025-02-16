// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quick_docs/screens/pdf/pdf_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.controller});
  final controller;

  @override
  State<SearchScreen> createState() => _SearchSearchState();
}

class _SearchSearchState extends State<SearchScreen> {
  late FocusNode myFocusNode;
  bool isLoading = false;
  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  String? email;
  SharedPreferences? prefs;
  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs?.getString('email');
  }

  List<Map<String, dynamic>> listTileObjects = [];

  void searchLemma(words) async {
    var lemmaObj =
        await FirebaseFirestore.instance.collection('lemma').doc(email).get();
    words = words.map((e) => e.toString().toLowerCase()).toList();
    List<dynamic> data = lemmaObj.data()?['data'] ?? [];
    List<Map<String, dynamic>> filteredPDF = [];
    for (var i = 0; i < data.length; i++) {
      int flag = 0;
      for (var j = 0; j < words.length; j++) {
        if (data[i]['lemma'] != null &&
            (!data[i]['lemma']!.contains(words[j]) &&
                !data[i]['str']!.contains(words[j]))) {
          flag = 1;
          break;
        }
      }
      if (flag == 0) {
        filteredPDF.add(data[i]);
      }
    }
    setState(() {
      listTileObjects = filteredPDF;
    });
    List<String> filePath = prefs!.getStringList('processedFilesPath') ?? [];
    List<String> fileName = prefs!.getStringList('processedFilesName') ?? [];
    List<String> fileFolder =
        prefs!.getStringList('processedFilesFolder') ?? [];
    List<String> filesStr = prefs!.getStringList('processedFilesStr') ?? [];

    for (var i = 0; i < filePath.length; i++) {
      int flag = 0;
      for (var j = 0; j < words.length; j++) {
        if (filesStr[i] != null &&
            (!(filesStr[i]).toString().toLowerCase().contains(words[j]))) {
          flag = 1;
          break;
        }
      }
      if (flag == 0) {
        filteredPDF.add({
          'path': filePath[i].toString(),
          'name': fileName[i].toString(),
          'folder': fileFolder[i].toString(),
        });
      }
    }
    setState(() {
      listTileObjects = filteredPDF;
    });

    // for (var i = 0; i < filteredPDF.length; i++) {
    //   if () {
    //     filePath.add(filteredPDF[i]['path']);
    //     fileName.add(filteredPDF[i]['name']);
    //     fileFolder.add(filteredPDF[i]['folder']);
    //     filesStr.add(filteredPDF[i]['str']);
    //   }
    // }

    // for()
  }

  @override
  void initState() {
    super.initState();
    initPrefs();

    myFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(myFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Magic search'),
        ),
        body: !isLoading
            ? GestureDetector(
                onVerticalDragCancel: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 2, bottom: 2),
                        child: Row(
                          children: [
                            const Gap(20),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  List<String> words =
                                      widget.controller.text.split(' ');
                                  searchLemma(words);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                focusNode: myFocusNode,
                                cursorRadius: const Radius.circular(70),
                                decoration: const InputDecoration(
                                    icon: Icon(
                                  Icons.search,
                                )),
                                controller: widget.controller,
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  if (widget.controller.text.trim() == '')
                                    return;
                                  setState(() {
                                    isLoading = true;
                                  });
                                  List<String> words =
                                      widget.controller.text.split(' ');
                                  FocusScope.of(context).unfocus();
                                  searchLemma(words);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: const Text('Search'))
                          ],
                        ),
                      ),
                    ),
                    const Gap(5),
                    if (listTileObjects.isEmpty)
                      const Text(
                        'No files found',
                        style: TextStyle(fontSize: 20),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: listTileObjects.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              PdfViewer(
                                fileName: listTileObjects[index]['name']!,
                                path: listTileObjects[index]['path']!,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Card.outlined(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: listTileObjects[index]['path']
                                            .toString()
                                            .contains('fire')
                                        ? Colors.blue.withOpacity(0.5)
                                        : Colors.green.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                semanticContainer: true,
                                margin: const EdgeInsets.only(top: 10),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfViewer(
                                            fileName: listTileObjects[index]
                                                ['name']!,
                                            path: listTileObjects[index]
                                                ['path']!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading:
                                          const Icon(Icons.file_open_outlined),
                                      title:
                                          Text(listTileObjects[index]['name']!),
                                      subtitle: Text(
                                          '${listTileObjects[index]['folder']}'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : const Center(
                child: Column(
                  children: [
                    Text('Searching for the file'),
                    Gap(10),
                    CircularProgressIndicator(),
                  ],
                ),
              ));
  }
}
