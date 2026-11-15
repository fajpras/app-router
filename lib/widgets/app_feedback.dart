import 'package:flutter/material.dart';

import '../theme/router_theme.dart';

enum FeedbackType { error, warning, success }

/// Helper for displaying high-contrast, visible SnackBars and inline alerts.
class AppFeedback {
  AppFeedback._();

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.error_outline,
  }) {
    _show(
      context,
      type: FeedbackType.error,
      title: title,
      message: message,
      icon: icon,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    _show(
      context,
      type: FeedbackType.warning,
      title: title,
      message: message,
      icon: icon,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String title = 'Berhasil',
  }) {
    _show(
      context,
      type: FeedbackType.success,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
    );
  }

  static void _show(
    BuildContext context, {
    required FeedbackType type,
    required String title,
    required String message,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final Color bg;
    final Color border;
    final Color accent;
    final Color bodyColor;

    switch (type) {
      case FeedbackType.error:
        bg = const Color(0xFFC62828);
        border = const Color(0xFFFF5252);
        accent = Colors.white;
        bodyColor = const Color(0xFFFFEBEE);
      case FeedbackType.warning:
        bg = const Color(0xFF33280E);
        border = RouterColors.warning.withValues(alpha: 0.75);
        accent = RouterColors.warning;
        bodyColor = RouterColors.onSurface;
      case FeedbackType.success:
        bg = const Color(0xFF102E18);
        border = RouterColors.tertiary.withValues(alpha: 0.75);
        accent = RouterColors.tertiary;
        bodyColor = RouterColors.onSurface;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 8,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: bg,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border, width: 1.2),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: bodyColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Tutup',
            textColor: accent,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
  }
}

/// Animated inline alert banner for form validation and network exceptions.
class InlineErrorBanner extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const InlineErrorBanner({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.error_outline,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = message != null && message!.isNotEmpty;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: hasError
          ? Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RouterColors.errorSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF5252),
                  width: 1.4,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null && title!.isNotEmpty) ...[
                          Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFEBEE),
                            height: 1.35,
                          ),
                        ),
                        if (onRetry != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: onRetry,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ),
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text(
                              'Coba Lagi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
