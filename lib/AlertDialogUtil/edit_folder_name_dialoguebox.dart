// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFolderDialog extends StatefulWidget {
  const EditFolderDialog(
      {Key? key,
      required this.index,
      required this.folderName,
      required this.uid})
      : super(key: key);
  final folderName;
  final index;
  final uid;
  // List<String> folders;
  @override
  _EditFolderDialogState createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<EditFolderDialog> {
  String email = '';
  TextEditingController _controller = TextEditingController();
  SharedPreferences? prefs;
  Color colorFromString(str) {
    if (str == 'b') {
      return Colors.blue;
    } else if (str == 'g') {
      return Colors.green;
    } else if (str == 'r') {
      return Colors.red;
    } else if (str == 'y') {
      return Colors.yellow;
    }
    return Colors.blue;
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs?.getString('email') ?? '';
    setState(() {
      _controller = TextEditingController(text: widget.folderName);
    });
  }

  @override
  void initState() {
    initPrefs();
    _controller = TextEditingController(text: widget.folderName);
    super.initState();
  }

  Color _selectedColor = Colors.blue;

  @override
  // void initState() {
  //   super.initState();
  //   _selectedColor = colorFromString((prefs!.get('folderColors') as List<String>)[widget.index]);
  // }

  @override
  Widget build(BuildContext context) {
    void snack(text, {color = null, textColor = null}) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Text(text, style: TextStyle(color: textColor)),
        ),
      );
    }

    return AlertDialog(
      title: const Text('Edit folder name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.text,
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              icon: Icon(
                Icons.folder_outlined,
                color: _selectedColor,
              ),
              hintText: "Folder name",
              border: const OutlineInputBorder(),
            ),
          ),
          const Gap(10),
          ElevatedButton(
            onPressed: () {
              snack('Folder deleted',
                  color: Colors.red, textColor: Colors.white);
              Navigator.of(context).pop();
              FirebaseFirestore.instance
                  .collection(email)
                  .doc(widget.uid)
                  .delete();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return Colors.red;
                },
              ),
              side: MaterialStateProperty.resolveWith<BorderSide?>(
                (Set<MaterialState> states) {
                  return const BorderSide(
                    color: Colors.white,
                    width: 1,
                  );
                },
              ),
            ),
            child: const Text(
              'Delete Folder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () async {
            Navigator.of(context).pop();
            await FirebaseFirestore.instance
                .collection(email)
                .doc(widget.uid)
                .update({
              'folder': _controller.text,
            });
          },
        ),
      ],
    );
  }
}
