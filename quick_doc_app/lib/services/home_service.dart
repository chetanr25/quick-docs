import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_docs/screens/auth_screen.dart';
import 'package:quick_docs/services/firestore_service.dart';
import '../models/folder_model.dart';
import '../core/constants.dart';
import '../utils/snackbar_util.dart';

class HomeService {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  Future<bool> confirmFolderDeletion(
      BuildContext context, FolderModel folder) async {
    // try {
    final data = await FirebaseConstants.firestore;
    final allDocument = data['documents'];
    final documents = data['documents'].where((doc) {
      return doc['folderId'] == folder.id;
    }).toList();
    print(documents);

    if (documents.isEmpty) {
      print('hehee');
      final confirm = await HomeService().deleteFolder(context, folder);
      FirestoreService.deleteFolder(folder);
      return confirm;
    }
    // List<String> fileNames = documents.map((doc) => doc['filename']).toList();
    // print(fileNames);

    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Folder?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The following files will be deleted:'),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(documents[index]['filename']),
                        dense: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete !'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Remove documents from allDocument array
      allDocument.removeWhere((doc) => doc['folderId'] == folder.id);
      await FirebaseConstants.firebaseUserDoc.update({
        'documents': allDocument,
      });
      FirestoreService.deleteFolder(folder);
      // for (final doc in documents) {
      //   // await FirebaseConstants.firebaseUserDoc
      // }
    }

    return result ?? false;
    // } catch (e) {
    //   print('Error checking folder contents: $e');
    //   return false;
    // }
  }

  /// Handles user sign out process
  Future<bool> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: 'Error signing out: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Shows create folder dialog and handles folder creation
  Future<FolderModel?> createFolder(BuildContext context) async {
    final controller = TextEditingController();

    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create New Folder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Create'),
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty) {
        final FolderModel newFolder =
            FolderModel.createNew(name: result).copyWith();
        print(newFolder.id);
        // Save to Firestore
        await _saveFolderToFirestore(newFolder);

        if (context.mounted) {
          SnackBarUtil.showSuccessSnackBar(
            context: context,
            message: 'Folder "$result" created successfully',
          );
        }

        return newFolder;
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: 'Error creating folder: ${e.toString()}',
        );
      }
      return null;
    } finally {
      controller.dispose();
    }
  }

  /// Shows delete confirmation dialog and handles folder deletion
  Future<bool> deleteFolder(BuildContext context, FolderModel folder) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Folder',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${folder.name}"? This action cannot be undone.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Delete from Firestore
        await _deleteFolderFromFirestore(folder);

        if (context.mounted) {
          SnackBarUtil.showSuccessSnackBar(
            context: context,
            message: 'Folder "${folder.name}" deleted successfully',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: 'Error deleting folder: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Private method to save folder to Firestore
  Future<void> _saveFolderToFirestore(FolderModel folder) async {
    try {
      final folderData = folder.toFirestore();
      await FirebaseConstants.firebaseUserDoc.update({
        'folders': FieldValue.arrayUnion([folderData]),
      });
    } catch (e) {
      throw Exception('Failed to save folder to Firestore: $e');
    }
  }

  /// Private method to delete folder from Firestore
  Future<void> _deleteFolderFromFirestore(FolderModel folder) async {
    try {
      final folderData = folder.toFirestore();
      await FirebaseConstants.firebaseUserDoc.update({
        'folders': FieldValue.arrayRemove([folderData]),
      });
    } catch (e) {
      throw Exception('Failed to delete folder from Firestore: $e');
    }
  }

  /// Loads user data and folders from Firestore
  Future<Map<String, dynamic>> loadUserData() async {
    try {
      await FirebaseConstants.firestore;
      // Note: This would need to be implemented based on your UserModel structure
      // For now, returning a placeholder structure
      return {
        'folders': <FolderModel>[],
        'documents': [],
        'isLoading': false,
      };
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  /// Shows folder selection dialog and moves document to selected folder
  Future<bool> moveDocumentToFolder(
    BuildContext context,
    dynamic document,
    List<FolderModel> availableFolders,
  ) async {
    try {
      // Show folder selection dialog
      final selectedFolder = await showDialog<FolderModel?>(
        context: context,
        builder: (context) =>
            _buildFolderSelectionDialog(context, availableFolders),
      );

      if (selectedFolder != null) {
        // Move document to selected folder
        await FirestoreService.moveDocument(
          document.fileId,
          selectedFolder.id ?? '',
          selectedFolder.name,
        );

        if (context.mounted) {
          SnackBarUtil.showSuccessSnackBar(
            context: context,
            message: 'Document moved to "${selectedFolder.name}" successfully',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: 'Error moving document: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Builds the folder selection dialog with glassmorphic design
  Widget _buildFolderSelectionDialog(
      BuildContext context, List<FolderModel> folders) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      title: Row(
        children: [
          Icon(
            Icons.drive_file_move,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text(
            'Move to Folder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            // "No Folder" option
            _buildFolderOption(
              context,
              icon: Icons.folder_off,
              title: 'No Folder',
              subtitle: 'Move to root directory',
              onTap: () => Navigator.pop(
                context,
                FolderModel.createNew(name: '').copyWith(id: ''),
              ),
            ),
            const Divider(),
            // Available folders
            Expanded(
              child: folders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No folders available',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        return _buildFolderOption(
                          context,
                          icon: Icons.folder,
                          title: folder.name,
                          subtitle: 'Move to this folder',
                          onTap: () => Navigator.pop(context, folder),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  /// Builds individual folder option in the selection dialog
  Widget _buildFolderOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
