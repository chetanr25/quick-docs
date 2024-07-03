import 'package:flutter/material.dart';

class UploadFirestorage extends StatefulWidget {
  const UploadFirestorage({Key? key, required this.initialData})
      : super(key: key);
  final initialData;
  @override
  State<UploadFirestorage> createState() => _UploadFirestorageState();
}

class _UploadFirestorageState extends State<UploadFirestorage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.initialData.snapshotEvents,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        double progress = 0;
        if (snapshot.connectionState == ConnectionState.active) {
          progress = snapshot.data.bytesTransferred / snapshot.data.totalBytes;
        }
        if (snapshot.connectionState == ConnectionState.done) {
          progress = 1;
          Navigator.of(context).pop();
        }
        return Column(
          children: [
            LinearProgressIndicator(value: progress),
          ],
        );
      },
    );
  }
}
