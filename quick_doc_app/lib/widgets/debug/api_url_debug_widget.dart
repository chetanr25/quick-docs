import 'package:flutter/material.dart';
import '../../services/api_url_service.dart';

/// Debug widget to test and monitor API URL service
/// This widget provides a UI to check status, refresh URL, and clear cache
class ApiUrlDebugWidget extends StatefulWidget {
  const ApiUrlDebugWidget({Key? key}) : super(key: key);

  @override
  State<ApiUrlDebugWidget> createState() => _ApiUrlDebugWidgetState();
}

class _ApiUrlDebugWidgetState extends State<ApiUrlDebugWidget> {
  Map<String, dynamic>? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await ApiUrlService.getStatus();
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading status: $e', isError: true);
    }
  }

  Future<void> _refreshUrl() async {
    setState(() => _isLoading = true);
    try {
      final newUrl = await ApiUrlService.refreshUrl();
      _showSnackBar('URL refreshed: $newUrl');
      await _loadStatus();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error refreshing URL: $e', isError: true);
    }
  }

  Future<void> _clearCache() async {
    setState(() => _isLoading = true);
    try {
      await ApiUrlService.clearCache();
      _showSnackBar('Cache cleared successfully');
      await _loadStatus();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error clearing cache: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API URL Debug'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        const Text(
                          'Service Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_status != null) ...[
                      _buildStatusItem(
                        'Initialized',
                        _status!['isInitialized']?.toString() ?? 'Unknown',
                        _status!['isInitialized'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      _buildStatusItem(
                        'Current URL',
                        _status!['currentUrl']?.toString() ?? 'Not set',
                        Colors.blue,
                      ),
                      _buildStatusItem(
                        'Cached URL',
                        _status!['cachedUrl']?.toString() ?? 'None',
                        Colors.orange,
                      ),
                      _buildStatusItem(
                        'Env URL',
                        _status!['envUrl']?.toString() ?? 'Not set',
                        Colors.purple,
                      ),
                      _buildStatusItem(
                        'Health Status',
                        _status!['isHealthy'] == true ? 'Healthy' : 'Unhealthy',
                        _status!['isHealthy'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      _buildStatusItem(
                        'Last Checked',
                        _formatDateTime(_status!['lastChecked']?.toString()),
                        Colors.grey,
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          'No status data available',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build),
                        SizedBox(width: 8),
                        Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reload Status'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _refreshUrl,
                      icon: const Icon(Icons.sync),
                      label: const Text('Refresh URL'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _clearCache,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Cache'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.help_outline),
                        SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '1. Health Check',
                      'The service automatically checks /health endpoint on startup',
                    ),
                    _buildInstructionItem(
                      '2. Firestore Fallback',
                      'If health check fails, fetches URL from settings/settings doc',
                    ),
                    _buildInstructionItem(
                      '3. Local Cache',
                      'Working URLs are cached in SharedPreferences',
                    ),
                    _buildInstructionItem(
                      '4. Manual Refresh',
                      'Use "Refresh URL" to manually check and update',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Never';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid';
    }
  }
}
