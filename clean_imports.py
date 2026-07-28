import os
import re

# Files with unused imports to clean up
to_remove = {
    'lib/screens/commande/panier_livraison_screen.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/commande/panier_programmee_screen.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/historique/historique_placeholder.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/historique/historique_screen.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/paiement/commande_confirmee_screen.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/profil/parrainage_screen.dart': [
        "import 'package:go_router/go_router.dart';",
        "import '../../app_routes.dart';",
        "import '../../widgets/common/bottom_nav_bar.dart';",
    ],
    'lib/screens/profil/profil_placeholder.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/reservations/reservations_screen.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/restaurant/plat_detail_screen.dart': ["import '../../widgets/common/app_feedback.dart';"],
    'lib/screens/restaurant/restaurant_screen.dart': ["import '../../widgets/common/offline_banner.dart';"],
    'lib/screens/suivi/suivi_placeholder.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/suivi/suivi_screen.dart': ["import '../../widgets/common/bottom_nav_bar.dart';"],
    'lib/screens/paiement/choix_paiement_screen.dart': ["import 'package:feda_flutter/feda_flutter.dart';"],
}

for filepath, imports_to_rm in to_remove.items():
    if not os.path.exists(filepath):
        print(f"SKIPPED (not found): {filepath}")
        continue
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    changed = False
    for imp in imports_to_rm:
        if imp in content:
            content = content.replace(imp + '\n', '')
            changed = True
    
    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Cleaned: {filepath}")
    else:
        print(f"No match: {filepath}")
