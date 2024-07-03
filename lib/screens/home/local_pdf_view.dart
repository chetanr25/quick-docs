import 'package:flutter/material.dart';
import 'package:pdf_made_easy/screens/pdf/pdf_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class LocalPdfView extends StatefulWidget {
  const LocalPdfView({Key? key}) : super(key: key);

  @override
  State<LocalPdfView> createState() => _LocalPdfViewState();
}

class _LocalPdfViewState extends State<LocalPdfView> {
  SharedPreferences? prefs;
  List<String> pdfFiles = [];
  bool isLoading = true;

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    pdfFiles = prefs!.getStringList('processedFilesPath') ?? [];
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  String getFileName(String path) {
    return p.basename(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF in your device!'),
        actions: [
          Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Text(
                prefs!.getStringList('processedFilesPath')?.length.toString() ??
                    '0'),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: !isLoading
            ? pdfFiles.isNotEmpty
                ? ListView.builder(
                    itemCount: pdfFiles.length,
                    itemBuilder: (context, index) {
                      if (pdfFiles.isEmpty) {
                        return const Center(
                          child: Text('No PDFs found in your device'),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: Card.outlined(
                          elevation: 30,
                          borderOnForeground: true,
                          child: ListTile(
                            leading: Text(
                              (index + 1).toString(),
                              style: const TextStyle(fontSize: 18),
                            ),
                            title: Text(
                              getFileName(pdfFiles[index])
                                  .replaceFirst('.pdf', ''),
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              'Home${pdfFiles[index].replaceFirst(prefs!.getString('homeDirectory') ?? '', '').replaceAll('/', ' > ')}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PdfViewer(
                                  path: pdfFiles[index],
                                  fileName: getFileName(pdfFiles[index])
                                      .replaceFirst('.pdf', ''),
                                ),
                              ));
                            },
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No PDFs found in your device',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
