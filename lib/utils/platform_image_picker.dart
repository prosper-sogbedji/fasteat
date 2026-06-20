// Point d'entrée unique — Flutter choisit automatiquement
// l'implémentation selon la plateforme cible.
export 'platform_image_picker_io.dart'
    if (dart.library.html) 'platform_image_picker_web.dart';
