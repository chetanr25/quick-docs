import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf_made_easy/file_handling/read_files.dart';
import 'package:pdf_made_easy/screens/home/local_pdf_view.dart';
import 'package:pdf_made_easy/screens/search_screen.dart';
import 'package:pdf_made_easy/screens/home/second_page.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf_made_easy/AlertDialogUtil/edit_folder_name_dialoguebox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  SharedPreferences? prefs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? email;
  bool isLoading = true;
  void fromFire() async {
    email = prefs?.getString('email') ?? '';
    setState(() {
      isLoading = false;
    });
  }

  void snack(text, {color = null, context, textColor = null}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  List<String> folders = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    // FirebaseAuth.instance.signOut();
    prefs = await SharedPreferences.getInstance();
    email = prefs?.getString('email') ?? '';
    fromFire();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folder'),
        actions: [
          if (!kIsWeb && Platform.isAndroid)
            PopupMenuButton(
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.more_vert,
                  size: 30,
                ),
              ),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<Object?>>[
                  PopupMenuItem<String>(
                    value: 'Basic',
                    child: const Text('Scan device files'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReadFromStorage(),
                        ),
                      );
                      // setState(() {

                      //   // isCustomised = false;
                      // });
                    },
                  ),
                  // PopupMenuItem<String>(
                  //   padding: const EdgeInsets.all(10),
                  //   value: 'Customised',
                  //   child: Row(
                  //     children: [
                  //       Icon(isCustomised
                  //           ? Icons.check_box_outlined
                  //           : Icons.check_box_outline_blank),
                  //       const SizedBox(width: 8),
                  //       const Text('Customised QR Code'),
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     setState(() {
                  //       isCustomised = true;
                  //     });
                  //   },
                  // ),
                  // IconButton(
                  //   onPressed: () {

                  // },
                  //   icon: const Icon(Icons.delete),
                  // ),
                ];
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String folderName = '';
              return AlertDialog(
                title: const Text('Enter folder name'),
                content: TextField(
                  keyboardType: TextInputType.text,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    folderName = value;
                  },
                  decoration: const InputDecoration(
                    hintText: "Folder name",
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () async {
                      if (folderName.trim() == '') {
                        snack(
                          'Folder name cannot be empty',
                          context: context,
                          color: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      if (folders.contains(folderName.trim())) {
                        snack(
                          'Folder already exists',
                          context: context,
                          color: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      final uid = const Uuid().v1();
                      Navigator.of(context).pop(); // Close the dialog
                      await firestore.collection(email!).doc(uid).set({
                        'uid': uid,
                        'folder': folderName,
                        'files': [],
                        // 'folderColor': Colors.blue,
                      });
                      snack('Folder created',
                          context: context,
                          color: Colors.green,
                          textColor: Colors.white);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: !isLoading
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(email ?? '')
                  .snapshots(),
              initialData: const CircularProgressIndicator(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data.docs.isEmpty) {
                  return const Center(
                    child: Text('No folders created'),
                  );
                }
                return GestureDetector(
                  onHorizontalDragDown: (details) {
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 30,
                            child: TextButton.icon(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchScreen(
                                      controller: searchController,
                                    ),
                                  ),
                                );
                              },
                              label: const Text('Search'),
                            ),
                          ),
                          if (Platform.isAndroid)
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height - 100,
                                maxWidth:
                                    MediaQuery.of(context).size.width - 30,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LocalPdfView(),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.blue.withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.folder_outlined,
                                        color: Colors.blue,
                                      ),
                                      title: Text('All local files'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height - 100,
                              maxWidth: MediaQuery.of(context).size.width - 30,
                            ),
                            child: snapshot.data.docs.length != 0
                                ? ListView.builder(
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SecondPage(
                                                folder: snapshot
                                                    .data.docs[index]['folder'],
                                                uid: snapshot.data.docs[index]
                                                    ['uid'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  Colors.blue.withOpacity(0.5),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          color: index != 0
                                              ? Colors.blue.withOpacity(0.2)
                                              : Colors.blue.withOpacity(0.2),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListTile(
                                                leading: const Icon(
                                                  Icons.folder_outlined,
                                                  color: Colors.blue,
                                                ),
                                                title: Text(snapshot.data
                                                    .docs[index]['folder']),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    // color: snapshot.data.docs[index]
                                                    //     ['folderColor'],
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        String folderName = '';
                                                        void t() async {
                                                          folderName = snapshot
                                                                  .data
                                                                  .docs[index]
                                                              ['folder'];
                                                        }

                                                        t();
                                                        return EditFolderDialog(
                                                          uid: snapshot.data
                                                                  .docs[index]
                                                              ['uid'],
                                                          folderName:
                                                              folderName,
                                                          // folders: folders,
                                                          index: index,
                                                        );
                                                      },
                                                    );
                                                  },
                                                )),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const Text('No folders'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReadFromStorage(),
                    ),
                  );
                },
                child: const Text('Scan device files'),
              ),
            ),
    );
  }
}
