import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ─── Modèle de données (mock) ──────────────────────────────────────────────────

enum StatutRestaurant { actif, inactif, enAttente, suspendu }

extension StatutRestaurantX on StatutRestaurant {
  String get libelle => switch (this) {
        StatutRestaurant.actif => 'Actif',
        StatutRestaurant.inactif => 'Inactif',
        StatutRestaurant.enAttente => 'En attente',
        StatutRestaurant.suspendu => 'Suspendu',
      };

  Color get couleur => switch (this) {
        StatutRestaurant.actif => const Color(0xFF16A34A),
        StatutRestaurant.inactif => const Color(0xFF6B7280),
        StatutRestaurant.enAttente => const Color(0xFFD97706),
        StatutRestaurant.suspendu => const Color(0xFFDC2626),
      };

  Color get fondCouleur => switch (this) {
        StatutRestaurant.actif => const Color(0xFFDCFCE7),
        StatutRestaurant.inactif => const Color(0xFFF3F4F6),
        StatutRestaurant.enAttente => const Color(0xFFFEF3C7),
        StatutRestaurant.suspendu => const Color(0xFFFEE2E2),
      };
}

class RestaurantAdmin {
  final String id;
  final String nom;
  final String proprietaire;
  final String email;
  final String telephone;
  final String quartier;
  final String ville;
  final StatutRestaurant statut;
  final DateTime dateInscription;
  final int nombreCommandes;
  final int chiffreAffaires;
  final String categorie;
  final double note;

  const RestaurantAdmin({
    required this.id,
    required this.nom,
    required this.proprietaire,
    required this.email,
    required this.telephone,
    required this.quartier,
    required this.ville,
    required this.statut,
    required this.dateInscription,
    required this.nombreCommandes,
    required this.chiffreAffaires,
    required this.categorie,
    required this.note,
  });
}

// ─── Données mock ──────────────────────────────────────────────────────────────

final _mockRestaurants = <RestaurantAdmin>[
  RestaurantAdmin(
    id: 'r1', nom: 'Restaurant Saveurs du Bénin', proprietaire: 'Kofi Ahouansou',
    email: 'saveurs@fasteat.bj', telephone: '+229 97 12 34 56',
    quartier: 'Cadjèhoun', ville: 'Cotonou', statut: StatutRestaurant.actif,
    dateInscription: DateTime(2024, 3, 15), nombreCommandes: 1248,
    chiffreAffaires: 4850000, categorie: 'Cuisine Béninoise', note: 4.8,
  ),
  RestaurantAdmin(
    id: 'r2', nom: 'Le Grill de Porto-Novo', proprietaire: 'Adéline Dossou',
    email: 'grill.pn@gmail.com', telephone: '+229 96 44 22 11',
    quartier: 'Ouando', ville: 'Porto-Novo', statut: StatutRestaurant.actif,
    dateInscription: DateTime(2024, 5, 20), nombreCommandes: 743,
    chiffreAffaires: 2900000, categorie: 'Grillades & Barbecue', note: 4.5,
  ),
  RestaurantAdmin(
    id: 'r3', nom: 'Chez Mama Africa', proprietaire: 'Raïssa Kossou',
    email: 'mama.africa@fasteat.bj', telephone: '+229 95 77 88 99',
    quartier: 'Akpakpa', ville: 'Cotonou', statut: StatutRestaurant.enAttente,
    dateInscription: DateTime(2025, 1, 8), nombreCommandes: 0,
    chiffreAffaires: 0, categorie: 'Street Food', note: 0.0,
  ),
  RestaurantAdmin(
    id: 'r4', nom: 'Fast & Fresh Burgers', proprietaire: 'Théo Zannou',
    email: 'fastfresh@bj.com', telephone: '+229 97 00 11 22',
    quartier: 'Ganhi', ville: 'Cotonou', statut: StatutRestaurant.suspendu,
    dateInscription: DateTime(2023, 11, 1), nombreCommandes: 512,
    chiffreAffaires: 1650000, categorie: 'Fast Food', note: 3.2,
  ),
  RestaurantAdmin(
    id: 'r5', nom: 'La Terrasse du Lac', proprietaire: 'Gilles Houngbo',
    email: 'terrasse.lac@fasteat.bj', telephone: '+229 96 55 66 77',
    quartier: 'Fidjrossè', ville: 'Cotonou', statut: StatutRestaurant.inactif,
    dateInscription: DateTime(2024, 7, 10), nombreCommandes: 198,
    chiffreAffaires: 720000, categorie: 'Pizzeria & Italien', note: 4.1,
  ),
  RestaurantAdmin(
    id: 'r6', nom: 'Délices d\'Afrique', proprietaire: 'Judith Hounkpé',
    email: 'delices.afrique@gmail.com', telephone: '+229 95 11 22 33',
    quartier: 'Étoile Rouge', ville: 'Cotonou', statut: StatutRestaurant.actif,
    dateInscription: DateTime(2024, 9, 5), nombreCommandes: 876,
    chiffreAffaires: 3200000, categorie: 'Cuisine Africaine', note: 4.6,
  ),
];

// ─── Widget principal ──────────────────────────────────────────────────────────

class AdminRestaurantsTab extends StatefulWidget {
  const AdminRestaurantsTab({super.key});

  @override
  State<AdminRestaurantsTab> createState() => _AdminRestaurantsTabState();
}

class _AdminRestaurantsTabState extends State<AdminRestaurantsTab> {
  final _searchCtrl = TextEditingController();
  StatutRestaurant? _filtreStatut;
  RestaurantAdmin? _selection;
  bool _showForm = false;
  final _restaurants = <RestaurantAdmin>[..._mockRestaurants];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RestaurantAdmin> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _restaurants.where((r) {
      final matchSearch = q.isEmpty ||
          r.nom.toLowerCase().contains(q) ||
          r.proprietaire.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q) ||
          r.ville.toLowerCase().contains(q);
      final matchStatut = _filtreStatut == null || r.statut == _filtreStatut;
      return matchSearch && matchStatut;
    }).toList();
  }

  String _formatFcfa(int amount) {
    final s = amount.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      b.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) b.write(' ');
    }
    return '${b.toString()} FCFA';
  }

  void _changerStatut(RestaurantAdmin r, StatutRestaurant nouveau) {
    setState(() {
      final idx = _restaurants.indexWhere((x) => x.id == r.id);
      if (idx != -1) {
        _restaurants[idx] = RestaurantAdmin(
          id: r.id, nom: r.nom, proprietaire: r.proprietaire,
          email: r.email, telephone: r.telephone, quartier: r.quartier,
          ville: r.ville, statut: nouveau,
          dateInscription: r.dateInscription, nombreCommandes: r.nombreCommandes,
          chiffreAffaires: r.chiffreAffaires, categorie: r.categorie, note: r.note,
        );
        if (_selection?.id == r.id) {
          _selection = _restaurants[idx];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1100;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatCards(),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: _showForm
                ? _buildAjouterForm()
                : isLargeScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildListe()),
                          if (_selection != null) ...[
                            const SizedBox(width: 20),
                            SizedBox(width: 360, child: _buildDetailPanel(_selection!)),
                          ],
                        ],
                      )
                    : _selection != null
                        ? _buildDetailPanel(_selection!)
                        : _buildListe(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestion des Restaurants',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Text(
                '${_restaurants.length} partenaires enregistrés sur la plateforme',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => setState(() { _showForm = true; _selection = null; }),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Ajouter un restaurant', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final actifs = _restaurants.where((r) => r.statut == StatutRestaurant.actif).length;
    final enAttente = _restaurants.where((r) => r.statut == StatutRestaurant.enAttente).length;
    final totalCA = _restaurants.fold<int>(0, (sum, r) => sum + r.chiffreAffaires);
    final totalCmds = _restaurants.fold<int>(0, (sum, r) => sum + r.nombreCommandes);

    return Row(
      children: [
        _statCard(actifs.toString(), 'Restaurants actifs', Icons.store_rounded, AppColors.primary, const Color(0xFFE6F3F3)),
        const SizedBox(width: 16),
        _statCard('$enAttente', 'En attente validation', Icons.schedule_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
        const SizedBox(width: 16),
        _statCard(_formatFcfa(totalCA), 'Chiffre d\'affaires total', Icons.payments_rounded, const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
        const SizedBox(width: 16),
        _statCard(totalCmds.toString(), 'Commandes traitées', Icons.receipt_long_rounded, const Color(0xFF0891B2), const Color(0xFFE0F7FA)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDF2F3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDF2F3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Nom du restaurant, propriétaire, email...',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                    onPressed: () { _searchCtrl.clear(); setState(() {}); },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ...StatutRestaurant.values.map((s) {
          final isActive = _filtreStatut == s;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filtreStatut = isActive ? null : s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? s.fondCouleur : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? s.couleur.withValues(alpha: 0.4) : const Color(0xFFEDF2F3),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: s.couleur, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    Text(s.libelle, style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? s.couleur : AppColors.textSecondary,
                    )),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListe() {
    final liste = _filtered;
    if (liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucun restaurant trouvé', style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: Color(0xFFEDF2F3)),
          Expanded(
            child: ListView.separated(
              itemCount: liste.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
              itemBuilder: (context, i) => _buildRestaurantRow(liste[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text('RESTAURANT', style: _headerStyle)),
          Expanded(flex: 2, child: Text('VILLE', style: _headerStyle)),
          Expanded(flex: 2, child: Text('CATÉGORIE', style: _headerStyle)),
          Expanded(flex: 2, child: Text('COMMANDES', style: _headerStyle)),
          Expanded(flex: 3, child: Text('C.A.', style: _headerStyle)),
          Expanded(flex: 2, child: Text('STATUT', style: _headerStyle)),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5);

  Widget _buildRestaurantRow(RestaurantAdmin r) {
    final isSelected = _selection?.id == r.id;
    return InkWell(
      onTap: () => setState(() { _selection = r; _showForm = false; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
        child: Row(
          children: [
            // Nom & email
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        r.nom[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(r.proprietaire, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(r.ville, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)))),
            Expanded(flex: 2, child: Text(r.categorie, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Expanded(flex: 2, child: Text('${r.nombreCommandes}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
            Expanded(flex: 3, child: Text(r.chiffreAffaires > 0 ? _formatFcfa(r.chiffreAffaires) : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: r.statut.fondCouleur, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: r.statut.couleur, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Flexible(child: Text(r.statut.libelle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: r.statut.couleur))),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: PopupMenuButton<StatutRestaurant>(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => StatutRestaurant.values
                    .where((s) => s != r.statut)
                    .map((s) => PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: s.couleur, shape: BoxShape.circle)),
                              const SizedBox(width: 10),
                              Text('Passer à "${s.libelle}"', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ))
                    .toList(),
                onSelected: (s) => _changerStatut(r, s),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(RestaurantAdmin r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(r.nom[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)), maxLines: 2),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: r.statut.fondCouleur, borderRadius: BorderRadius.circular(20)),
                        child: Text(r.statut.libelle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: r.statut.couleur)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selection = null),
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Métriques
                  Row(
                    children: [
                      _miniMetric('${r.nombreCommandes}', 'Commandes', Icons.receipt_long_rounded, const Color(0xFF0891B2)),
                      const SizedBox(width: 12),
                      _miniMetric(r.note > 0 ? '${r.note}/5' : 'N/A', 'Note moy.', Icons.star_rounded, const Color(0xFFD97706)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (r.chiffreAffaires > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chiffre d\'affaires total', style: TextStyle(fontSize: 11, color: Color(0xFF7C3AED), fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(_formatFcfa(r.chiffreAffaires), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4C1D95))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  _section('Informations', [
                    _infoRow(Icons.person_outline_rounded, 'Propriétaire', r.proprietaire),
                    _infoRow(Icons.email_outlined, 'Email', r.email),
                    _infoRow(Icons.phone_outlined, 'Téléphone', r.telephone),
                    _infoRow(Icons.location_on_outlined, 'Adresse', '${r.quartier}, ${r.ville}'),
                    _infoRow(Icons.category_outlined, 'Catégorie', r.categorie),
                    _infoRow(Icons.calendar_today_outlined, 'Inscrit le', _formatDate(r.dateInscription)),
                  ]),
                  const SizedBox(height: 20),
                  const Text('Actions rapides', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  // Bouton activer/désactiver
                  if (r.statut == StatutRestaurant.actif)
                    _actionButton('Désactiver le restaurant', Icons.pause_circle_outline_rounded, const Color(0xFFDC2626), const Color(0xFFFEE2E2),
                        () => _changerStatut(r, StatutRestaurant.inactif))
                  else if (r.statut == StatutRestaurant.inactif || r.statut == StatutRestaurant.suspendu)
                    _actionButton('Réactiver le restaurant', Icons.play_circle_outline_rounded, const Color(0xFF16A34A), const Color(0xFFDCFCE7),
                        () => _changerStatut(r, StatutRestaurant.actif))
                  else if (r.statut == StatutRestaurant.enAttente)
                    _actionButton('Approuver & Activer', Icons.check_circle_outline_rounded, AppColors.primary, const Color(0xFFE6F3F3),
                        () => _changerStatut(r, StatutRestaurant.actif)),
                  const SizedBox(height: 10),
                  if (r.statut != StatutRestaurant.suspendu)
                    _actionButton('Suspendre le compte', Icons.block_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7),
                        () => _changerStatut(r, StatutRestaurant.suspendu)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDF2F3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String titre, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEDF2F3)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                Text(valeur, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, Color bg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ─── Formulaire d'ajout ────────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _propCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  String _villeForm = 'Cotonou';
  String _categorieForm = 'Cuisine Béninoise';

  static const _villes = ['Cotonou', 'Porto-Novo', 'Parakou', 'Abomey-Calavi', 'Bohicon', 'Natitingou'];
  static const _categories = ['Cuisine Béninoise', 'Cuisine Africaine', 'Fast Food', 'Grillades & Barbecue', 'Street Food', 'Pizzeria & Italien', 'Végétarien', 'Fruits de Mer'];

  Widget _buildAjouterForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDF2F3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header du formulaire
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_business_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nouveau restaurant partenaire', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                          Text('Créez le compte d\'accès au dashboard', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _showForm = false),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Annuler'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _formSection('Informations du restaurant', [
                      _formField('Nom du restaurant *', Icons.storefront_rounded, _nomCtrl,
                          hint: 'Ex: Restaurant Saveurs du Bénin',
                          validator: (v) => v == null || v.trim().length < 3 ? 'Le nom doit faire au moins 3 caractères.' : null),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _dropdownField('Ville *', _villes, _villeForm, (v) => setState(() => _villeForm = v!), Icons.location_city_rounded)),
                        const SizedBox(width: 16),
                        Expanded(child: _formField('Quartier *', Icons.location_on_rounded, _quartierCtrl, hint: 'Ex: Cadjèhoun',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Champ obligatoire.' : null)),
                      ]),
                      const SizedBox(height: 16),
                      _dropdownField('Catégorie culinaire *', _categories, _categorieForm, (v) => setState(() => _categorieForm = v!), Icons.category_rounded),
                    ]),
                    const SizedBox(height: 24),
                    _formSection('Informations du propriétaire / compte', [
                      _formField('Nom complet du propriétaire *', Icons.person_rounded, _propCtrl,
                          hint: 'Ex: Kofi Ahouansou',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Champ obligatoire.' : null),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _formField('Email professionnel *', Icons.email_rounded, _emailCtrl,
                            hint: 'restaurant@email.com',
                            keyboard: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Champ obligatoire.';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return 'Email invalide.';
                              return null;
                            })),
                        const SizedBox(width: 16),
                        Expanded(child: _formField('Téléphone *', Icons.phone_rounded, _telCtrl,
                            hint: '+229 97 ...',
                            keyboard: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Champ obligatoire.' : null)),
                      ]),
                    ]),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Un email sera envoyé au propriétaire avec ses identifiants de connexion. Le mot de passe temporaire devra être changé à la première connexion.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => setState(() => _showForm = false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: Color(0xFFEDF2F3)),
                            foregroundColor: AppColors.textSecondary,
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _soumettreForme,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                          ),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Créer le compte restaurant', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _soumettreForme() {
    if (!_formKey.currentState!.validate()) return;
    final nouveau = RestaurantAdmin(
      id: 'r${_restaurants.length + 1}',
      nom: _nomCtrl.text.trim(),
      proprietaire: _propCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telephone: _telCtrl.text.trim(),
      quartier: _quartierCtrl.text.trim(),
      ville: _villeForm,
      statut: StatutRestaurant.enAttente,
      dateInscription: DateTime.now(),
      nombreCommandes: 0,
      chiffreAffaires: 0,
      categorie: _categorieForm,
      note: 0.0,
    );
    setState(() {
      _restaurants.insert(0, nouveau);
      _showForm = false;
      _selection = nouveau;
      _nomCtrl.clear();
      _propCtrl.clear();
      _emailCtrl.clear();
      _telCtrl.clear();
      _quartierCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Restaurant ajouté avec succès ! Statut : En attente de validation.'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _formSection(String titre, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFFEDF2F3)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _formField(String label, IconData icon, TextEditingController ctrl,
      {String? hint, TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDF2F3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDF2F3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> items, String value, ValueChanged<String?> onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDF2F3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDF2F3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}
