import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import 'home_service.dart';

/// Wrapper class for folder operations
/// Provides a clean interface for folder-related actions
class FolderService {
  static final HomeService _homeService = HomeService();

  /// Creates a new folder
  static Future<FolderModel?> createFolder(BuildContext context) async {
    return await _homeService.createFolder(context);
  }

  /// Deletes an existing folder
  static Future<bool> deleteFolder(
      BuildContext context, FolderModel folder) async {
    return await _homeService.deleteFolder(context, folder);
  }
}

/// Wrapper class for authentication operations
/// Provides a clean interface for auth-related actions
class AuthService {
  static final HomeService _homeService = HomeService();

  /// Signs out the current user
  static Future<bool> signOut(BuildContext context) async {
    return await _homeService.signOut(context);
  }
}
