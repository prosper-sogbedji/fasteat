import os

files = [
    'lib/screens/restaurant/restaurant_screen.dart',
    'lib/screens/restaurant/plat_detail_screen.dart'
]

replacements = {
    "ScaffoldMessenger.of(context).showSnackBar(\n                                const SnackBar(content: Text('Fonctionnalité de partage bientôt disponible.')),\n                              );": "AppFeedback.info(context, 'Fonctionnalité de partage bientôt disponible.');",
    "ScaffoldMessenger.of(context).showSnackBar(\n                                const SnackBar(content: Text('Merci, votre signalement a bien été reçu.')),\n                              );": "AppFeedback.success(context, 'Merci, votre signalement a bien été reçu.');",
    "ScaffoldMessenger.of(context).showSnackBar(\n                      SnackBar(\n                        content: Text('${p.nom} ajouté au panier'),\n                        duration: const Duration(seconds: 1),\n                        behavior: SnackBarBehavior.floating,\n                      ),\n                    );": "AppFeedback.success(context, '${p.nom} ajouté au panier');",
    "ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mode Livraison sélectionné')));": "AppFeedback.info(context, 'Mode Livraison sélectionné');",
    "ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mode À emporter sélectionné')));": "AppFeedback.info(context, 'Mode À emporter sélectionné');",
    "ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mode Sur place sélectionné')));": "AppFeedback.info(context, 'Mode Sur place sélectionné');",
    
    "ScaffoldMessenger.of(context).showSnackBar(\n                                      const SnackBar(content: Text('Fonctionnalité de partage bientôt disponible.')),\n                                    );": "AppFeedback.info(context, 'Fonctionnalité de partage bientôt disponible.');",
    "ScaffoldMessenger.of(context).showSnackBar(\n              SnackBar(\n                content: Text('$qte x ${plat.nom} ajouté(s) au panier'),\n                duration: const Duration(seconds: 1),\n                behavior: SnackBarBehavior.floating,\n              ),\n            );": "AppFeedback.success(context, '$qte x ${plat.nom} ajouté(s) au panier');"
}

for filepath in files:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        for k, v in replacements.items():
            content = content.replace(k, v)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Processed {filepath}")
