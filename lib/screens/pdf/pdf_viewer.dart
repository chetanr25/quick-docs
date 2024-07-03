// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
// import 'package:gap/gap.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewer extends StatelessWidget {
  const PdfViewer({Key? key, required this.path, required this.fileName})
      : super(key: key);
  final path;
  final fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          if (Platform.isAndroid)
            IconButton(
              onPressed: () async {
                try {
                  final result = await OpenFile.open(path);
                  // print(result.type);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open file')),
                    );
                  }
                } catch (e) {
                  final url = 'file://$path';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                }
              },
              icon: const Icon(Icons.open_in_browser),
            ),
          if (Platform.isIOS)
            IconButton(
              onPressed: () async {
                PermissionStatus status = await Permission.storage.request();
                if (!status.isPermanentlyDenied) {
                  Dio dio = Dio();

                  try {
                    var dir = await getApplicationDocumentsDirectory();

                    await dio.download(path, "${dir.path}/file.pdf",
                        onReceiveProgress: (rec, total) {
                      // print("Rec: $rec , Total: $total");
                    });

                    final result = await OpenFile.open("${dir.path}/file.pdf");
                    // print(result.type);
                    if (result.type != ResultType.done) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open file')),
                      );
                    }
                  } catch (e) {
                    // print(e);
                  }
                } else {
                  print('Permission denied');
                }
              },
              icon: const Icon(Icons.open_in_new),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // child: SfPdfViewer.file(
        //   File(path),
        //   canShowScrollHead: true,
        //   canShowPaginationDialog: false,
        //   canShowHyperlinkDialog: true,
        //   // canShowPageLoadingIndicator: false,
        //   // undoController: UndoHistoryController(),
        //   // initialPageNumber: 10,
        // ),
        child: path.toString().contains('fire')
            ? const PDF().cachedFromUrl(path,
                placeholder: (progress) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Loading your PDF',
                              style: TextStyle(fontSize: 20),
                            ),
                            Gap(10),
                            LinearProgressIndicator(),
                          ],
                        ),
                      ),
                    )
                // )
                )
            : SfPdfViewer.file(
                File(path),
                enableDoubleTapZooming: true,
                canShowHyperlinkDialog: true,
                // canShowPageLoadingIndicator: false,
                canShowScrollHead: true,
                canShowPaginationDialog: false,
                // undoController: UndoHistoryController(),
                // initialPageNumber: 10,
              ),
      ),
      // File(
      //   '/Users/chetanr/Library/Developer/CoreSimulator/Devices/5CBB732B-6557-42E0-BEA6-687D1B4DE80E/data/Containers/Data/Application/DA1F9458-356F-4E3A-B464-972747488445/tmp/First .pdf')),
    );
  }
}
