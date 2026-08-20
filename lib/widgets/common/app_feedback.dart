import 'package:flutter/material.dart';
import 'custom_dialog.dart';

/// Messages utilisateur uniformes dans toute l'application.
abstract final class AppFeedback {
  static void show(
    BuildContext context,
    String message, {
    String title = 'Information',
    FeedbackType type = FeedbackType.info,
  }) {
    showCustomFeedback(
      context,
      title: title,
      message: message,
      type: type,
    );
  }

  static void success(BuildContext context, String message, {String title = 'Succès'}) =>
      show(context, message, title: title, type: FeedbackType.success);

  static void error(BuildContext context, String message, {String title = 'Erreur'}) =>
      show(context, message, title: title, type: FeedbackType.error);

  static void warning(BuildContext context, String message, {String title = 'Attention'}) =>
      show(context, message, title: title, type: FeedbackType.warning);

  static void info(BuildContext context, String message, {String title = 'Information'}) =>
      show(context, message, title: title, type: FeedbackType.info);
}
