import 'package:flutter/material.dart';
import '../../models/folder_model.dart';
import 'folder_card.dart';
import 'empty_state_widget.dart';

class FoldersListWidget extends StatelessWidget {
  final List<FolderModel> folders;
  final Function(FolderModel?) onOpenDocuments;
  final Function(FolderModel) onDeleteFolder;
  final VoidCallback onCreateFolder;

  const FoldersListWidget({
    Key? key,
    required this.folders,
    required this.onOpenDocuments,
    required this.onDeleteFolder,
    required this.onCreateFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return EmptyStateWidget(
        onCreateFolder: onCreateFolder,
        onOpenDocuments: onOpenDocuments,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: folders.length + 1, // +1 for "All Documents" option
      itemBuilder: (context, index) {
        if (index == 0) {
          // "All Documents" option
          return FolderCard(
            folderName: 'All Documents',
            isSpecial: true,
            onTap: () => onOpenDocuments(null),
          );
        }

        final folder = folders[index - 1];
        return FolderCard(
          folderName: folder.name,
          onTap: () => onOpenDocuments(folder),
          onDelete: () => onDeleteFolder(folder),
        );
      },
    );
  }
}
