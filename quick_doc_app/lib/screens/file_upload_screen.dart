import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../widgets/widgets.dart' as custom_widgets;
import '../utils/snackbar_util.dart';
import '../utils/file_utils.dart';
import '../core/exceptions.dart';

class FileUploadScreen extends StatefulWidget {
  final String userEmail;
  final String? folderId;
  final String? folderName;

  const FileUploadScreen({
    Key? key,
    required this.userEmail,
    this.folderName,
    this.folderId,
  }) : super(key: key);

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final FileProcessingService _fileService = FileProcessingService();

  bool isUploading = false;
  File? selectedFile;
  DocumentModel? uploadResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File selection section
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Document',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: PDF, TXT, DOCX, DOC',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedFile == null) ...[
                      // File picker button
                      ElevatedButton.icon(
                        onPressed: isUploading ? null : _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Choose File'),
                        style: ElevatedButton.styleFrom(
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 16),
                        ),
                      ),
                    ] else ...[
                      // Selected file info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[600]!),
                        ),
                        child: Row(
                          children: [
                            Text(
                              FileUtils.getFileIcon(selectedFile!.path),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FileUtils.getFileName(selectedFile!.path),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    FileUtils.formatFileSize(
                                        FileUtils.getFileSize(
                                            selectedFile!.path)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[400],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isUploading)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedFile = null;
                                    uploadResult = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Upload button
                      ElevatedButton.icon(
                        onPressed: isUploading ? null : _uploadFile,
                        icon: isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(
                            isUploading ? 'Processing...' : 'Upload & Process'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Upload progress/result section
            if (isUploading) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: custom_widgets.LoadingWidget(
                    message:
                        'Uploading and processing your document...\nThis may take a few moments.',
                  ),
                ),
              ),
            ] else if (uploadResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Upload Successful!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Processing results
                      _buildResultItem(
                        icon: Icons.text_fields,
                        label: 'Text Length',
                        value: '${uploadResult!.textLength} characters',
                      ),
                      _buildResultItem(
                        icon: Icons.token,
                        label: 'Tokens',
                        value:
                            '${uploadResult!.tokenCount} tokens (${uploadResult!.uniqueTokens} unique)',
                      ),
                      _buildResultItem(
                        icon: Icons.timer,
                        label: 'Processing Time',
                        value:
                            '${uploadResult!.processingTime.toStringAsFixed(2)} seconds',
                      ),
                      // _buildResultItem(
                      //   icon: Icons.category,
                      //   label: 'Extraction Method',
                      //   value: uploadResult!,
                      // ),

                      const SizedBox(height: 16),

                      // Text preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Extracted Text Preview:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              uploadResult!.extractedText.length > 200
                                  ? '${uploadResult!.extractedText.substring(0, 200)}...'
                                  : uploadResult!.extractedText,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedFile = null;
                                  uploadResult = null;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Upload Another'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.done, color: Colors.white),
                              label: const Text('Done'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);

        // Validate file
        if (!FileUtils.isSupportedFileType(file.path)) {
          throw ValidationException('Unsupported file type');
        }

        setState(() {
          selectedFile = file;
          uploadResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: 'Error selecting file: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (selectedFile == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final DocumentModel result = await _fileService.processAndSaveFile(
        folderName: widget.folderName ?? 'All Documents',
        file: selectedFile!,
        userEmail: widget.userEmail,
        folderId: widget.folderId,
      );
      // final List<DocumentModel> result = [];
      setState(() {
        uploadResult = result;
        isUploading = false;
      });

      if (mounted) {
        SnackBarUtil.showSuccessSnackBar(
          context: context,
          message: 'Document uploaded and processed successfully!',
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      String errorMessage = 'Upload failed';
      if (e is NetworkException) {
        // print('NetworkException: ${e.message}');
        errorMessage = 'No internet connection';
      } else if (e is FileUploadException) {
        errorMessage = e.message;
      } else if (e is ValidationException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Unexpected error: ${e.toString()}';
      }

      if (mounted) {
        SnackBarUtil.showErrorSnackBar(
          context: context,
          message: errorMessage,
        );
      }
    }
  }
}
