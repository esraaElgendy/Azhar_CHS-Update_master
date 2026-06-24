import 'dart:io';
import 'package:flutter/material.dart';
import '../network/api_constants.dart';
import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String initials;
  final bool isLoading;
  final VoidCallback? onEdit;
  final bool showEditButton;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 55,
    required this.initials,
    this.isLoading = false,
    this.onEdit,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        CircleAvatar(
          radius: radius + 5,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: theme.primaryColor,
            child: _buildImage(context),
          ),
        ),
        if (showEditButton && onEdit != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        if (isLoading)
          Positioned.fill(
            child: ClipOval(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final path = imageUrl?.trim();
    
    if (path == null || path.isEmpty) {
      return _buildDefaultAvatar();
    }

    if (_isLocalPath(path)) {
      return ClipOval(
        child: Image.file(
          File(path.startsWith('file:') ? Uri.parse(path).toFilePath() : path),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      );
    }

    final resolvedUrl = _resolveUrl(path);
    return ClipOval(
      child: Image.network(
        resolvedUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              color: Colors.white70,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    // Try to load a local asset if available, otherwise fallback to initials
    return ClipOval(
      child: Image.asset(
        'assets/image (1).jpg',
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool _isLocalPath(String value) {
    return value.startsWith('/') ||
        value.startsWith('file:') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(value);
  }

  String _resolveUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      // If it's already a full URL, add a timestamp for cache busting
      if (value.contains('?')) {
        return '$value&t=${DateTime.now().millisecondsSinceEpoch}';
      }
      return '$value?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    final baseUri = Uri.parse(ApiConstants.baseUrl);
    final origin = '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
    final cleanPath = value.startsWith('/') ? value : '/$value';
    final fullUrl = '$origin$cleanPath';
    
    // Add cache buster
    return fullUrl.contains('?') 
        ? '$fullUrl&t=${DateTime.now().millisecondsSinceEpoch}' 
        : '$fullUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }
}
