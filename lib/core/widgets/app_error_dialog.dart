import 'package:flutter/material.dart';
import '../services/error_handler_service.dart';
import '../../theme/app_colors.dart';

/// Dialog error yang comprehensive dengan berbagai tipe error
void showAppErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  required ErrorType errorType,
  String? technicalDetails,
  VoidCallback? onRetry,
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _AppErrorDialog(
      title: title,
      message: message,
      errorType: errorType,
      technicalDetails: technicalDetails,
      onRetry: onRetry,
      onClose: onClose,
    ),
  );
}

class _AppErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final ErrorType errorType;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const _AppErrorDialog({
    required this.title,
    required this.message,
    required this.errorType,
    this.technicalDetails,
    this.onRetry,
    this.onClose,
  });

  @override
  State<_AppErrorDialog> createState() => _AppErrorDialogState();
}

class _AppErrorDialogState extends State<_AppErrorDialog> {
  bool _showTechnicalDetails = false;

  @override
  Widget build(BuildContext context) {
    final errorConfig = _getErrorConfig(widget.errorType);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: errorConfig.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(errorConfig.icon, size: 40, color: errorConfig.color),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Error type badge
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: errorConfig.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorConfig.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(errorConfig.icon, size: 16, color: errorConfig.color),
                  const SizedBox(width: 6),
                  Text(
                    errorConfig.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: errorConfig.color,
                    ),
                  ),
                ],
              ),
            ),

            // Technical details (collapsible)
            if (widget.technicalDetails != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(
                  () => _showTechnicalDetails = !_showTechnicalDetails,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Detail Teknis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showTechnicalDetails
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              if (_showTechnicalDetails) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    widget.technicalDetails!,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Retry button (if provided)
                if (widget.onRetry != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onRetry!();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: errorConfig.color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 18,
                            color: errorConfig.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Coba Lagi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: errorConfig.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Close button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorConfig.color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _ErrorConfig _getErrorConfig(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          color: AppColors.warning,
          label: 'Koneksi Terputus',
        );
      case ErrorType.server:
        return _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          color: AppColors.danger,
          label: 'Server Error',
        );
      case ErrorType.notFound:
        return _ErrorConfig(
          icon: Icons.search_off_rounded,
          color: AppColors.info,
          label: 'Tidak Ditemukan',
        );
      case ErrorType.validation:
        return _ErrorConfig(
          icon: Icons.error_outline_rounded,
          color: AppColors.warning,
          label: 'Validasi Gagal',
        );
      case ErrorType.permission:
        return _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          color: AppColors.danger,
          label: 'Akses Ditolak',
        );
      case ErrorType.conflict:
        return _ErrorConfig(
          icon: Icons.content_copy_rounded,
          color: AppColors.warning,
          label: 'Data Konflik',
        );
      case ErrorType.database:
        return _ErrorConfig(
          icon: Icons.storage_rounded,
          color: AppColors.danger,
          label: 'Database Error',
        );
      case ErrorType.auth:
        return _ErrorConfig(
          icon: Icons.person_off_rounded,
          color: AppColors.danger,
          label: 'Autentikasi Gagal',
        );
      case ErrorType.storage:
        return _ErrorConfig(
          icon: Icons.cloud_upload_rounded,
          color: AppColors.warning,
          label: 'Storage Error',
        );
      case ErrorType.navigation:
        return _ErrorConfig(
          icon: Icons.map_rounded,
          color: AppColors.info,
          label: 'Navigasi Error',
        );
      case ErrorType.unknown:
        return _ErrorConfig(
          icon: Icons.help_outline_rounded,
          color: AppColors.danger,
          label: 'Error Tidak Diketahui',
        );
    }
  }
}

class _ErrorConfig {
  final IconData icon;
  final Color color;
  final String label;

  _ErrorConfig({required this.icon, required this.color, required this.label});
}
