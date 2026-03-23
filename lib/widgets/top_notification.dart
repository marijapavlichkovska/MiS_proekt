import 'package:flutter/material.dart';


void showTopNotification(BuildContext context, String message) {
  showTopNotificationWith(
    overlay: Overlay.of(context),
    padding: MediaQuery.paddingOf(context),
    message: message,
    colorScheme: Theme.of(context).colorScheme,
    textTheme: Theme.of(context).textTheme,
  );
}

void showTopNotificationWith({
  required OverlayState overlay,
  required EdgeInsets padding,
  required String message,
  ColorScheme? colorScheme,
  TextTheme? textTheme,
}) {
  late OverlayEntry entry;
  final scheme = colorScheme ?? const ColorScheme.light();
  final theme = textTheme ?? const TextTheme();

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: scheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2500), () {
    entry.remove();
  });
}
