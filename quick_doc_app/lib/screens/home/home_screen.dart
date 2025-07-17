import 'package:flutter/material.dart';
import 'package:quick_docs/core/constants.dart';
import 'package:quick_docs/screens/file_upload_screen.dart';
import 'package:quick_docs/screens/search_screen.dart';
import 'package:quick_docs/screens/home/document_screen.dart';
import 'package:quick_docs/services/home_service.dart';
import 'package:quick_docs/widgets/home/app_bar_menu_button.dart';
import 'package:quick_docs/widgets/home/folders_list_widget.dart';
import 'package:quick_docs/widgets/home/search_bar_widget.dart';
import 'package:quick_docs/widgets/loading_widget.dart';
import '../../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  bool _isRefreshing = false; // Prevent multiple simultaneous refreshes
  List<FolderModel> folders = [];
  List<DocumentModel> documents = [];
  UserModel? user;
  final HomeService _homeService = HomeService();

  void loadData() async {
    if (_isRefreshing) return; // Prevent multiple simultaneous calls

    _isRefreshing = true;
    print('Loading data...');

    try {
      // Force fresh data from server by using the new method
      final userData = await FirebaseConstants.getFreshUserData();
      user = UserModel.fromFirestore(userData);
      documents = user?.documents ?? [];

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          folders = user?.folders ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> _signOut() async {
    await _homeService.signOut(context);
  }

  Future<void> _createFolder() async {
    final newFolder = await _homeService.createFolder(context);
    if (newFolder != null && mounted) {
      // Reload data from Firebase to ensure consistency
      loadData();
    }
  }

  Future<void> _deleteFolder(FolderModel folder) async {
    final deleted = await _homeService.confirmFolderDeletion(context, folder);
    if (deleted && mounted) {
      // Reload data from Firebase to get the latest state
      // This ensures both folder and associated documents are removed from local state
      loadData();
    }
  }

  Future<void> _navigateToUpload() async {
    final uploadedDocument = await Navigator.push<DocumentModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FileUploadScreen(
          userEmail: FirebaseConstants.email,
          folderId: FirebaseConstants.uid,
          folderName: 'All Documents',
        ),
      ),
    );

    // Add the uploaded document to the local list if one was returned
    if (uploadedDocument != null && mounted) {
      setState(() {
        documents.add(uploadedDocument);
      });
    }
  }

  void _openDocumentsList(FolderModel? folder) async {
    // Navigate to documents list and wait for result
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => folder == null
            ? DocumentsListScreen(
                documents: documents,
                folders: folders,
                folderId: FirebaseConstants.uid,
                folderName: 'All Documents',
              )
            : DocumentsListScreen(
                documents: documents,
                folders: folders,
                folderId: folder.id ?? FirebaseConstants.uid,
                folderName: folder.name,
              ),
      ),
    );

    // Reload data when returning from documents screen
    // This ensures any changes (deletions, moves) are reflected
    if (mounted) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quick Docs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  userEmail: FirebaseConstants.email,
                  initialDocuments: documents,
                ),
              ),
            ), // Open all documents
          ),
          AppBarMenuButton(
            onUpload: _navigateToUpload,
            onSignOut: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () async {
                print('Refreshing data...');
                await Future.delayed(const Duration(
                    milliseconds: 300)); // Small delay for better UX
                loadData();
              },
              child: Column(
                children: [
                  SearchBarWidget(
                    documents: documents,
                    userEmail: FirebaseConstants.email,
                  ),

                  // const WelcomeSection(),
                  Expanded(
                    child: FoldersListWidget(
                      folders: folders,
                      onOpenDocuments: _openDocumentsList,
                      onDeleteFolder: _deleteFolder,
                      onCreateFolder: _createFolder,
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'upload',
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: _navigateToUpload,
            child: const Icon(Icons.upload_file),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'folder',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            onPressed: _createFolder,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
