import 'package:flutter/material.dart';
import 'package:quick_docs/core/constants.dart';
import 'package:quick_docs/screens/file_upload_screen.dart';
import 'package:quick_docs/screens/search_screen.dart';
import 'package:quick_docs/services/home_service.dart';
import 'package:quick_docs/services/navigation_service.dart';
import 'package:quick_docs/widgets/home/app_bar_menu_button.dart';
import 'package:quick_docs/widgets/home/folders_list_widget.dart';
import 'package:quick_docs/widgets/loading_widget.dart';
import '../../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<FolderModel> folders = [];
  List<DocumentModel> documents = [];
  UserModel? user;
  final HomeService _homeService = HomeService();

  void loadData() async {
    final userData = await FirebaseConstants.firestore;
    user = UserModel.fromFirestore(userData);

    documents = user?.documents ?? [];
    isLoading = false;
    setState(() {
      folders = user?.folders ?? [];
      isLoading = false;
    });
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
    if (newFolder != null) {
      setState(() {
        folders.add(newFolder);
      });
    }
  }

  Future<void> _deleteFolder(FolderModel folder) async {
    final deleted = await _homeService.confirmFolderDeletion(context, folder);
    if (deleted) {
      setState(() {
        folders.remove(folder);
      });
    }
  }

  void _navigateToUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileUploadScreen(
          userEmail: FirebaseConstants.email,
          folderId: FirebaseConstants.uid,
          folderName: 'All Documents',
        ),
      ),
    );
  }

  void _openDocumentsList(FolderModel? folder) {
    NavigationService.openDocumentsList(context, folder, documents, folders);
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
            onPressed: () {
              if (FirebaseConstants.email != '') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(
                      userEmail: FirebaseConstants.email,
                      initialDocuments: documents,
                    ),
                  ),
                );
              }
            },
          ),
          AppBarMenuButton(
            onUpload: _navigateToUpload,
            onSignOut: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const LoadingWidget()
          : Column(
              children: [
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
