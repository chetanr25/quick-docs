import 'package:flutter/material.dart';
import '../../models/document_model.dart';
import '../../screens/search_screen.dart';

class SearchBarWidget extends StatelessWidget {
  final List<DocumentModel> documents;
  final String userEmail;

  const SearchBarWidget({
    Key? key,
    required this.documents,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.7),
            Theme.of(context)
                .colorScheme
                .surfaceContainer
                .withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSearch(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildSearchIcon(context),
                const SizedBox(width: 16),
                _buildPlaceholderText(context),
                // _buildDocumentCounter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.search_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildPlaceholderText(BuildContext context) {
    return Expanded(
      child: Text(
        'Search your documents...',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  // Widget _buildDocumentCounter(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context)
  //           .colorScheme
  //           .secondaryContainer
  //           .withValues(alpha: 0.7),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Text(
  //       '${documents.length}',
  //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //             color: Theme.of(context).colorScheme.onSecondaryContainer,
  //             fontWeight: FontWeight.w600,
  //           ),
  //     ),
  //   );
  // }

  void _navigateToSearch(BuildContext context) {
    if (userEmail.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            userEmail: userEmail,
            initialDocuments: documents,
          ),
        ),
      );
    }
  }
}
