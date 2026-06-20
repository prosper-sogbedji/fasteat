import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ─── Modèle ──────────────────────────────────────────────────────────────────

class CategorieFood {
  final String id;
  String nom;
  String description;
  String emoji;
  bool active;
  int nbRestaurants;
  int nbPlats;
  int ordreAffichage;

  CategorieFood({
    required this.id,
    required this.nom,
    required this.description,
    required this.emoji,
    required this.active,
    required this.nbRestaurants,
    required this.nbPlats,
    required this.ordreAffichage,
  });
}

// ─── Données mock ─────────────────────────────────────────────────────────────

final _mockCategories = <CategorieFood>[
  CategorieFood(id: 'c1', nom: 'Cuisine Béninoise', description: 'Plats traditionnels du Bénin : sauce arachide, gboman, fufu, etc.', emoji: '🇧🇯', active: true, nbRestaurants: 4, nbPlats: 87, ordreAffichage: 1),
  CategorieFood(id: 'c2', nom: 'Fast Food', description: 'Burgers, frites, sandwichs et repas rapides', emoji: '🍔', active: true, nbRestaurants: 3, nbPlats: 54, ordreAffichage: 2),
  CategorieFood(id: 'c3', nom: 'Cuisine Africaine', description: 'Spécialités culinaires d\'Afrique de l\'Ouest et centrale', emoji: '🌍', active: true, nbRestaurants: 2, nbPlats: 41, ordreAffichage: 3),
  CategorieFood(id: 'c4', nom: 'Grillades & Barbecue', description: 'Viandes grillées, brochettes, poulets rôtis', emoji: '🔥', active: true, nbRestaurants: 2, nbPlats: 29, ordreAffichage: 4),
  CategorieFood(id: 'c5', nom: 'Pizzeria & Italien', description: 'Pizzas, pâtes, risottos et cuisine méditerranéenne', emoji: '🍕', active: true, nbRestaurants: 1, nbPlats: 22, ordreAffichage: 5),
  CategorieFood(id: 'c6', nom: 'Boissons & Jus', description: 'Jus naturels, smoothies, boissons fraîches', emoji: '🥤', active: true, nbRestaurants: 3, nbPlats: 38, ordreAffichage: 6),
  CategorieFood(id: 'c7', nom: 'Desserts & Pâtisserie', description: 'Gâteaux, pâtisseries, glaces et douceurs', emoji: '🍰', active: false, nbRestaurants: 0, nbPlats: 0, ordreAffichage: 7),
  CategorieFood(id: 'c8', nom: 'Street Food', description: 'Snacks et spécialités de rue béninoises', emoji: '🌮', active: true, nbRestaurants: 1, nbPlats: 18, ordreAffichage: 8),
];

// ─── Widget principal ─────────────────────────────────────────────────────────

class AdminCategoriesTab extends StatefulWidget {
  const AdminCategoriesTab({super.key});

  @override
  State<AdminCategoriesTab> createState() => _AdminCategoriesTabState();
}

class _AdminCategoriesTabState extends State<AdminCategoriesTab> {
  final _categories = <CategorieFood>[..._mockCategories];
  CategorieFood? _selection;
  bool _showForm = false;

  // Formulaire
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _emojiForm = '🍽️';
  bool _editMode = false;
  CategorieFood? _editTarget;

  final _emojis = ['🍽️', '🇧🇯', '🍔', '🍕', '🌍', '🔥', '🥤', '🍰', '🌮', '🥗', '🍜', '🍱', '🥩', '🦐', '🥘', '🫕'];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _ouvrirFormulaire({CategorieFood? cible}) {
    setState(() {
      _editMode = cible != null;
      _editTarget = cible;
      _showForm = true;
      _selection = null;
      if (cible != null) {
        _nomCtrl.text = cible.nom;
        _descCtrl.text = cible.description;
        _emojiForm = cible.emoji;
      } else {
        _nomCtrl.clear();
        _descCtrl.clear();
        _emojiForm = '🍽️';
      }
    });
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      if (_editMode && _editTarget != null) {
        final idx = _categories.indexWhere((c) => c.id == _editTarget!.id);
        if (idx != -1) {
          _categories[idx].nom = _nomCtrl.text.trim();
          _categories[idx].description = _descCtrl.text.trim();
          _categories[idx].emoji = _emojiForm;
        }
      } else {
        _categories.add(CategorieFood(
          id: 'c${_categories.length + 1}',
          nom: _nomCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          emoji: _emojiForm,
          active: true,
          nbRestaurants: 0,
          nbPlats: 0,
          ordreAffichage: _categories.length + 1,
        ));
      }
      _showForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white),
        const SizedBox(width: 10),
        Text(_editMode ? 'Catégorie modifiée avec succès !' : 'Catégorie créée avec succès !'),
      ]),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _toggleActif(CategorieFood c) {
    setState(() {
      c.active = !c.active;
      if (_selection?.id == c.id) _selection = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;
    final actives = _categories.where((c) => c.active).length;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Catégories de Nourriture', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                Text('$actives catégories actives sur ${_categories.length} au total', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
              ]),
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nouvelle catégorie', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_showForm) ...[
            _buildForm(),
            const SizedBox(height: 20),
          ],
          Expanded(
            child: isDesktop
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 5, child: _buildGrid()),
                    if (_selection != null) ...[const SizedBox(width: 20), SizedBox(width: 320, child: _buildDetailPanel(_selection!))],
                  ])
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) => _buildCategorieCard(_categories[i]),
    );
  }

  Widget _buildCategorieCard(CategorieFood c) {
    final isSelected = _selection?.id == c.id;
    return GestureDetector(
      onTap: () => setState(() { _selection = c; _showForm = false; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : (c.active ? const Color(0xFFEDF2F3) : const Color(0xFFEDF2F3)), width: isSelected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.03), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 32)),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.active ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c.active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.active ? const Color(0xFF16A34A) : AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _ouvrirFormulaire(cible: c),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.edit_rounded, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.6))),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Text(c.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Expanded(
              child: Text(c.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip(Icons.storefront_rounded, '${c.nbRestaurants} restos', AppColors.primary),
                const SizedBox(width: 8),
                _chip(Icons.restaurant_menu_rounded, '${c.nbPlats} plats', const Color(0xFF7C3AED)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _buildDetailPanel(CategorieFood c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            child: Row(
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: c.active ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
                      child: Text(c.active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.active ? const Color(0xFF16A34A) : AppColors.textSecondary)),
                    ),
                  ]),
                ),
                IconButton(onPressed: () => setState(() => _selection = null), icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: _statBox('${c.nbRestaurants}', 'Restaurants', Icons.storefront_rounded, AppColors.primary, const Color(0xFFE6F3F3))),
                    const SizedBox(width: 10),
                    Expanded(child: _statBox('${c.nbPlats}', 'Plats', Icons.restaurant_menu_rounded, const Color(0xFF7C3AED), const Color(0xFFF5F3FF))),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEDF2F3))),
                    child: Text(c.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  _actionBtn(
                    c.active ? 'Désactiver la catégorie' : 'Activer la catégorie',
                    c.active ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    c.active ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    c.active ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                    () => _toggleActif(c),
                  ),
                  const SizedBox(height: 8),
                  _actionBtn('Modifier la catégorie', Icons.edit_rounded, AppColors.primary, const Color(0xFFE6F3F3), () => _ouvrirFormulaire(cible: c)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String val, String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, Color bg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE6F3F3), borderRadius: BorderRadius.circular(10)), child: Icon(_editMode ? Icons.edit_rounded : Icons.add_rounded, color: AppColors.primary, size: 18)),
                const SizedBox(width: 12),
                Text(_editMode ? 'Modifier la catégorie' : 'Nouvelle catégorie', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                const Spacer(),
                TextButton.icon(onPressed: () => setState(() => _showForm = false), icon: const Icon(Icons.close_rounded, size: 16), label: const Text('Annuler'), style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nom de la catégorie *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nomCtrl,
                        validator: (v) => v == null || v.trim().length < 3 ? 'Minimum 3 caractères.' : null,
                        decoration: _inputDeco('Ex: Cuisine Béninoise', Icons.label_rounded),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descCtrl,
                        validator: (v) => v == null || v.trim().length < 10 ? 'Minimum 10 caractères.' : null,
                        decoration: _inputDeco('Décrivez brièvement cette catégorie...', Icons.description_rounded),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emoji', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _emojis.map((e) => GestureDetector(
                        onTap: () => setState(() => _emojiForm = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: _emojiForm == e ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _emojiForm == e ? AppColors.primary : const Color(0xFFEDF2F3), width: _emojiForm == e ? 1.5 : 1),
                          ),
                          child: Center(child: Text(e, style: const TextStyle(fontSize: 18))),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _soumettre,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: Size.zero),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(_editMode ? 'Enregistrer les modifications' : 'Créer la catégorie', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDF2F3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDF2F3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }
}
