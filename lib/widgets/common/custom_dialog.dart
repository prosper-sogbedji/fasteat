import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

enum FeedbackType { success, error, info, warning }

class CustomFeedbackDialog extends StatelessWidget {
  const CustomFeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
  });

  final String title;
  final String message;
  final FeedbackType type;

  Color get _color {
    switch (type) {
      case FeedbackType.success:
        return Colors.green; // AppColors.success
      case FeedbackType.error:
        return Colors.red; // AppColors.error
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.info:
        return Colors.blue;
    }
  }

  IconData get _icon {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_rounded;
      case FeedbackType.error:
        return Icons.close_rounded;
      case FeedbackType.warning:
        return Icons.warning_rounded;
      case FeedbackType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5), // Light gray background like the screenshot
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _color, width: 3),
                ),
                child: Center(
                  child: Icon(
                    _icon,
                    color: _color,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _color,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Affiche la modale de feedback et se ferme automatiquement après un délai.
Future<void> showCustomFeedback(
  BuildContext context, {
  required String title,
  required String message,
  required FeedbackType type,
  Duration duration = const Duration(seconds: 2),
}) async {
  if (type == FeedbackType.success) {
    HapticFeedback.lightImpact();
  } else if (type == FeedbackType.error) {
    HapticFeedback.heavyImpact();
  } else {
    HapticFeedback.selectionClick();
  }

  // Permet de stocker la référence de la route du dialog
  Route? dialogRoute;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.2),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      dialogRoute = ModalRoute.of(context);
      return CustomFeedbackDialog(
        title: title,
        message: message,
        type: type,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );

  // Attendre puis fermer la dialog si elle est toujours active
  await Future.delayed(duration);
  
  // Utilisation d'un context root pour pop, en vérifiant si la route existe toujours
  if (dialogRoute != null && dialogRoute!.isActive) {
    // navigatorState
    // ignore: use_build_context_synchronously
    if (context.mounted) {
       Navigator.of(context).removeRoute(dialogRoute!);
    }
  }
}
