import 'package:document_viewer/document_viewer.dart';
import 'package:flutter/material.dart';
import 'package:quick_docs/models/document_model.dart';

class ViewDocument extends StatelessWidget {
  final DocumentModel document;

  const ViewDocument({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: DocumentViewer(
      filePath: document.fileUrl,
    ));
  }
}
