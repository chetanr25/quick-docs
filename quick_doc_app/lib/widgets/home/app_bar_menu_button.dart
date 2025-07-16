import 'package:flutter/material.dart';

class AppBarMenuButton extends StatelessWidget {
  final VoidCallback onUpload;
  final VoidCallback onSignOut;

  const AppBarMenuButton({
    Key? key,
    required this.onUpload,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'upload':
            onUpload();
            break;
          case 'signout':
            onSignOut();
            break;
        }
      },
      itemBuilder: (context) => [
        _buildUploadMenuItem(context),
        _buildSignOutMenuItem(context),
      ],
    );
  }

  PopupMenuItem<String> _buildUploadMenuItem(BuildContext context) {
    return PopupMenuItem(
      value: 'upload',
      child: Row(
        children: [
          Icon(
            Icons.upload_file,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Upload Files',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSignOutMenuItem(BuildContext context) {
    return PopupMenuItem(
      value: 'signout',
      child: Row(
        children: [
          Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Sign Out',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
