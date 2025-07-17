import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_docs/screens/auth_screen.dart';
import 'package:quick_docs/services/firestore_service.dart';
import 'package:quick_docs/services/api_service.dart';
import '../models/folder_model.dart';
import '../core/constants.dart';
import '../utils/snackbar_util.dart';
import '../core/exceptions.dart';

class HomeService {
  static final HomeService _instance = HomeService._internal();
  factory HomeService() => _instance;
  HomeService._internal();

  final ApiService _apiService = ApiService();

  Future<bool> confirmFolderDeletion(
      BuildContext context, FolderModel folder) async {
    final data = await FirebaseConstants.firestore;
    final allDocument = data['documents'];
    final documents = data['documents'].where((doc) {
      return doc['folderId'] == folder.id;
    }).toList();

    if (documents.isEmpty) {
      final confirm = await HomeService().deleteFolder(context, folder);
      FirestoreService.deleteFolder(folder);
      return confirm;
    }

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
      try {
        final fileIds =
            documents.map<String>((doc) => doc['fileId'] as String).toList();

        if (fileIds.isNotEmpty) {
          await _apiService.deleteMultipleFiles(fileIds);
        }

        allDocument.removeWhere((doc) => doc['folderId'] == folder.id);

        // _apiService.deleteFile(folder.id);

        await FirebaseConstants.firebaseUserDoc.update({
          'documents': allDocument,
        });

        FirestoreService.deleteFolder(folder);
      } catch (e) {
        print('Error deleting files from storage: $e');
        allDocument.removeWhere((doc) => doc['folderId'] == folder.id);
        await FirebaseConstants.firebaseUserDoc.update({
          'documents': allDocument,
        });
        FirestoreService.deleteFolder(folder);
      }
    }

    return result ?? false;
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
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => const _CreateFolderDialog(),
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

  /// Deletes a single document from both storage and Firestore
  Future<bool> deleteDocument(BuildContext context, dynamic document) async {
    try {
      // First delete from storage database
      await _apiService.deleteFile(document.fileId);

      // Then remove from Firestore
      final data = await FirebaseConstants.firestore;
      final allDocuments = List<Map<String, dynamic>>.from(data['documents']);
      allDocuments.removeWhere((doc) => doc['fileId'] == document.fileId);

      await FirebaseConstants.firebaseUserDoc.update({
        'documents': allDocuments,
      });

      if (context.mounted) {
        SnackBarUtil.showSuccessSnackBar(
          context: context,
          message: 'Document deleted successfully',
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Error deleting document';
        if (e is NetworkException) {
          errorMessage =
              'No internet connection - unable to delete file from storage';
        } else if (e is FileUploadException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Unexpected error: ${e.toString()}';
        }

        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: errorMessage,
        );
      }
      return false;
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

  /// Builds the folder selection dialog with enhanced modern design
  Widget _buildFolderSelectionDialog(
      BuildContext context, List<FolderModel> folders) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3),
                      Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.drive_file_move_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Move Document',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose destination folder',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "No Folder" option with enhanced design
                      _buildEnhancedFolderOption(
                        context,
                        icon: Icons.folder_off_rounded,
                        title: 'No Folder',
                        subtitle: 'Move to All Documents',
                        isSpecial: true,
                        onTap: () => Navigator.pop(
                          context,
                          FolderModel.createNew(name: '').copyWith(id: ''),
                        ),
                      ),

                      if (folders.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Available folders
                      Flexible(
                        child: folders.isEmpty
                            ? _buildEmptyState(context)
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: folders.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final folder = folders[index];
                                  return AnimatedContainer(
                                    duration: Duration(
                                        milliseconds: 200 + (index * 50)),
                                    curve: Curves.easeOutBack,
                                    child: _buildEnhancedFolderOption(
                                      context,
                                      icon: Icons.folder_rounded,
                                      title: folder.name,
                                      subtitle: 'Tap to move here',
                                      onTap: () =>
                                          Navigator.pop(context, folder),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Enhanced Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds enhanced individual folder option in the selection dialog
  Widget _buildEnhancedFolderOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpecial
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        gradient: isSpecial
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.1),
                  Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.05),
                ],
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSpecial
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSpecial
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSpecial
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds empty state widget for when no folders are available
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No folders available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a folder first to organize your documents',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful dialog widget for creating folders with proper controller lifecycle management
class _CreateFolderDialog extends StatefulWidget {
  const _CreateFolderDialog();

  @override
  State<_CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<_CreateFolderDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitFolder() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Create New Folder',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Enter folder name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(context, value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitFolder,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
