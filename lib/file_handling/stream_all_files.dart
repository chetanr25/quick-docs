import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pdf_made_easy/screens/pdf/pdf_viewer.dart';
import 'package:path/path.dart' as p;

class StreamAllFiles extends StatefulWidget {
  const StreamAllFiles({
    Key? key,
    required this.pdfFiles,
    required this.homeDirectory,
  }) : super(key: key);
  final String homeDirectory;
  final List<String> pdfFiles;

  @override
  State<StreamAllFiles> createState() => _StreamAllFilesState();
}

class _StreamAllFilesState extends State<StreamAllFiles> {
  String getFileName(String path) {
    return p.basename(path);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.pdfFiles.isNotEmpty
            ? Stream.fromFuture(Future.value(widget.pdfFiles))
            : const Stream.empty(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Getting your files', style: TextStyle(fontSize: 20)),
                Gap(20),
                Padding(
                  padding: EdgeInsets.all(14.0),
                  child: LinearProgressIndicator(),
                )
              ],
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              File file = File(snapshot.data[index]);
              return Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Card(
                  child: ListTile(
                    leading: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(
                      getFileName(snapshot.data[index])
                          .replaceFirst('.pdf', ''),
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Home${file.parent.path.toString().replaceFirst(widget.homeDirectory, '')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PdfViewer(
                          path: snapshot.data[index],
                          fileName: getFileName(snapshot.data[index])
                              .replaceFirst('.pdf', ''),
                        ),
                      ));
                    },
                  ),
                ),
              );
            },
          );
        });
  }
}
