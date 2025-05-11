import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

/// A utility class for showing snackbars across the app.
/// 
/// This class provides static methods to display various types of snackbars
/// (success, error, info) with consistent styling.
class SnackBarUtils {
  /// Shows a success snackbar with a green background.
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Shows an error snackbar with a red background.
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: RaceColors.red,
      icon: Icons.error,
    );
  }

  /// Shows an info snackbar with the primary color background.
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: RaceColors.primary,
      icon: Icons.info,
    );
  }

  /// Shows a warning snackbar with an amber background.
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.amber,
      icon: Icons.warning,
    );
  }

  /// The core method that displays a snackbar with customized styling.
  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: RaceColors.white,
          ),
          const SizedBox(width: RaceSpacings.xs),
          Expanded(
            child: Text(
              message,
              style: RaceTextStyles.subbody.copyWith(
                color: RaceColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaceSpacings.radius),
      ),
      margin: const EdgeInsets.all(RaceSpacings.s),
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: RaceColors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    // Clear any existing snackbars before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
} 