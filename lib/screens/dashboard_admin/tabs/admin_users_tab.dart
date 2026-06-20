import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ─── Modèles mock ─────────────────────────────────────────────────────────────

enum TypeUtilisateur { client, livreur }

enum StatutCompte { actif, suspendu, enAttente }

extension StatutCompteX on StatutCompte {
  String get libelle => switch (this) {
        StatutCompte.actif => 'Actif',
        StatutCompte.suspendu => 'Suspendu',
        StatutCompte.enAttente => 'En attente',
      };

  Color get couleur => switch (this) {
        StatutCompte.actif => const Color(0xFF16A34A),
        StatutCompte.suspendu => const Color(0xFFDC2626),
        StatutCompte.enAttente => const Color(0xFFD97706),
      };

  Color get fondCouleur => switch (this) {
        StatutCompte.actif => const Color(0xFFDCFCE7),
        StatutCompte.suspendu => const Color(0xFFFEE2E2),
        StatutCompte.enAttente => const Color(0xFFFEF3C7),
      };
}

class UtilisateurAdmin {
  final String id;
  final String nom;
  final String email;
  final String telephone;
  final TypeUtilisateur type;
  final StatutCompte statut;
  final DateTime dateInscription;
  final int nombreCommandes;
  final String ville;
  // Champs spécifiques livreurs
  final String? vehicule;
  final double? noteMoyenne;
  final int? livraisonsEffectuees;

  const UtilisateurAdmin({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.type,
    required this.statut,
    required this.dateInscription,
    required this.nombreCommandes,
    required this.ville,
    this.vehicule,
    this.noteMoyenne,
    this.livraisonsEffectuees,
  });
}

final _mockUtilisateurs = <UtilisateurAdmin>[
  UtilisateurAdmin(id: 'u1', nom: 'Aïcha Bello', email: 'aicha.b@gmail.com', telephone: '+229 97 11 22 33', type: TypeUtilisateur.client, statut: StatutCompte.actif, dateInscription: DateTime(2024, 2, 10), nombreCommandes: 47, ville: 'Cotonou'),
  UtilisateurAdmin(id: 'u2', nom: 'Romaric Dossou', email: 'rom.dossou@yahoo.fr', telephone: '+229 96 44 55 66', type: TypeUtilisateur.client, statut: StatutCompte.actif, dateInscription: DateTime(2024, 5, 3), nombreCommandes: 22, ville: 'Porto-Novo'),
  UtilisateurAdmin(id: 'u3', nom: 'Fatou Sow', email: 'fatou.sow@hotmail.com', telephone: '+229 97 88 99 00', type: TypeUtilisateur.client, statut: StatutCompte.suspendu, dateInscription: DateTime(2023, 11, 15), nombreCommandes: 8, ville: 'Cotonou'),
  UtilisateurAdmin(id: 'u4', nom: 'Parfait Agossou', email: 'parfait.ago@fasteat.bj', telephone: '+229 95 00 11 22', type: TypeUtilisateur.client, statut: StatutCompte.actif, dateInscription: DateTime(2025, 1, 20), nombreCommandes: 3, ville: 'Abomey-Calavi'),
  UtilisateurAdmin(id: 'u5', nom: 'Sandra Kpêkê', email: 'sandra.k@gmail.com', telephone: '+229 97 33 44 55', type: TypeUtilisateur.client, statut: StatutCompte.actif, dateInscription: DateTime(2024, 8, 12), nombreCommandes: 61, ville: 'Cotonou'),
  UtilisateurAdmin(id: 'l1', nom: 'Marc Houinato', email: 'marc.h@fasteat.bj', telephone: '+229 96 77 88 99', type: TypeUtilisateur.livreur, statut: StatutCompte.actif, dateInscription: DateTime(2024, 1, 5), nombreCommandes: 842, ville: 'Cotonou', vehicule: 'Moto - BB-123-RB', noteMoyenne: 4.9, livraisonsEffectuees: 842),
  UtilisateurAdmin(id: 'l2', nom: 'Jules Adjovi', email: 'jules.adj@gmail.com', telephone: '+229 97 55 66 77', type: TypeUtilisateur.livreur, statut: StatutCompte.actif, dateInscription: DateTime(2024, 3, 18), nombreCommandes: 578, ville: 'Cotonou', vehicule: 'Moto - BC-456-RB', noteMoyenne: 4.7, livraisonsEffectuees: 578),
  UtilisateurAdmin(id: 'l3', nom: 'Ines Houessou', email: 'ines.h@fasteat.bj', telephone: '+229 95 22 33 44', type: TypeUtilisateur.livreur, statut: StatutCompte.enAttente, dateInscription: DateTime(2025, 2, 1), nombreCommandes: 0, ville: 'Porto-Novo', vehicule: 'Vélo électrique', noteMoyenne: 0, livraisonsEffectuees: 0),
  UtilisateurAdmin(id: 'l4', nom: 'Brice Tossou', email: 'brice.t@gmail.com', telephone: '+229 96 11 00 99', type: TypeUtilisateur.livreur, statut: StatutCompte.suspendu, dateInscription: DateTime(2023, 10, 20), nombreCommandes: 213, ville: 'Cotonou', vehicule: 'Moto - BD-789-RB', noteMoyenne: 3.4, livraisonsEffectuees: 213),
];

// ─── Widget principal ──────────────────────────────────────────────────────────

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _users = <UtilisateurAdmin>[..._mockUtilisateurs];
  UtilisateurAdmin? _selection;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() { _selection = null; }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UtilisateurAdmin> get _clients => _users.where((u) => u.type == TypeUtilisateur.client && _matchSearch(u)).toList();
  List<UtilisateurAdmin> get _livreurs => _users.where((u) => u.type == TypeUtilisateur.livreur && _matchSearch(u)).toList();

  bool _matchSearch(UtilisateurAdmin u) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return q.isEmpty || u.nom.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.telephone.contains(q);
  }

  void _changerStatut(UtilisateurAdmin u, StatutCompte s) {
    final idx = _users.indexWhere((x) => x.id == u.id);
    if (idx == -1) return;
    final updated = UtilisateurAdmin(
      id: u.id, nom: u.nom, email: u.email, telephone: u.telephone,
      type: u.type, statut: s, dateInscription: u.dateInscription,
      nombreCommandes: u.nombreCommandes, ville: u.ville,
      vehicule: u.vehicule, noteMoyenne: u.noteMoyenne, livraisonsEffectuees: u.livraisonsEffectuees,
    );
    setState(() {
      _users[idx] = updated;
      if (_selection?.id == u.id) _selection = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;
    final clients = _clients;
    final livreurs = _livreurs;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Utilisateurs & Livreurs', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                Text('Gérez les comptes clients et partenaires de livraison', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          // Stats rapides
          Row(
            children: [
              _statPill(Icons.people_alt_rounded, '${_users.where((u) => u.type == TypeUtilisateur.client).length} Clients', const Color(0xFF0891B2), const Color(0xFFE0F7FA)),
              const SizedBox(width: 12),
              _statPill(Icons.delivery_dining_rounded, '${_users.where((u) => u.type == TypeUtilisateur.livreur).length} Livreurs', const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
              const SizedBox(width: 12),
              _statPill(Icons.check_circle_rounded, '${_users.where((u) => u.statut == StatutCompte.actif).length} Comptes actifs', const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
              const SizedBox(width: 12),
              _statPill(Icons.schedule_rounded, '${_users.where((u) => u.statut == StatutCompte.enAttente).length} En attente', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              const Spacer(),
              // Barre de recherche
              Container(
                width: 260,
                height: 40,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEDF2F3))),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(hintText: 'Rechercher...', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tab bar
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEDF2F3)))),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Clients (${clients.length})'),
                Tab(text: 'Livreurs (${livreurs.length})'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Liste + détail
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListeAvecDetail(clients, isDesktop, TypeUtilisateur.client),
                _buildListeAvecDetail(livreurs, isDesktop, TypeUtilisateur.livreur),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildListeAvecDetail(List<UtilisateurAdmin> liste, bool isDesktop, TypeUtilisateur type) {
    if (liste.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(type == TypeUtilisateur.client ? Icons.people_outline : Icons.delivery_dining_rounded, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text('Aucun ${type == TypeUtilisateur.client ? "client" : "livreur"} trouvé', style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w600)),
      ]));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: isDesktop ? 3 : 1, child: _buildListe(liste, type)),
        if (isDesktop && _selection != null && _selection!.type == type) ...[
          const SizedBox(width: 20),
          SizedBox(width: 320, child: _buildDetailPanel(_selection!)),
        ],
      ],
    );
  }

  Widget _buildListe(List<UtilisateurAdmin> liste, TypeUtilisateur type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildTableHeader(type),
          const Divider(height: 1, color: Color(0xFFEDF2F3)),
          Expanded(
            child: ListView.separated(
              itemCount: liste.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
              itemBuilder: (ctx, i) => _buildRow(liste[i], type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(TypeUtilisateur type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Expanded(flex: 4, child: Text('UTILISATEUR', style: _hStyle)),
          const Expanded(flex: 2, child: Text('VILLE', style: _hStyle)),
          Expanded(flex: 2, child: Text(type == TypeUtilisateur.client ? 'COMMANDES' : 'LIVRAISONS', style: _hStyle)),
          const Expanded(flex: 2, child: Text('STATUT', style: _hStyle)),
          if (type == TypeUtilisateur.livreur) const Expanded(flex: 2, child: Text('NOTE', style: _hStyle)),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  static const _hStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5);

  Widget _buildRow(UtilisateurAdmin u, TypeUtilisateur type) {
    final isSelected = _selection?.id == u.id;
    return InkWell(
      onTap: () => setState(() => _selection = u),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: (type == TypeUtilisateur.livreur ? const Color(0xFF7C3AED) : const Color(0xFF0891B2)).withValues(alpha: 0.1),
                    child: Text(u.nom[0].toUpperCase(), style: TextStyle(color: type == TypeUtilisateur.livreur ? const Color(0xFF7C3AED) : const Color(0xFF0891B2), fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(u.email, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(u.ville, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)))),
            Expanded(
              flex: 2,
              child: Text(
                type == TypeUtilisateur.client ? u.nombreCommandes.toString() : (u.livraisonsEffectuees ?? 0).toString(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: u.statut.fondCouleur, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: u.statut.couleur, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Flexible(child: Text(u.statut.libelle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: u.statut.couleur))),
                ]),
              ),
            ),
            if (type == TypeUtilisateur.livreur)
              Expanded(
                flex: 2,
                child: u.noteMoyenne != null && (u.noteMoyenne ?? 0) > 0
                    ? Row(children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text('${u.noteMoyenne}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ])
                    : const Text('N/A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
            SizedBox(
              width: 40,
              child: PopupMenuButton<StatutCompte>(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => StatutCompte.values
                    .where((s) => s != u.statut)
                    .map((s) => PopupMenuItem(
                          value: s,
                          child: Row(children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: s.couleur, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text('Passer à "${s.libelle}"', style: const TextStyle(fontSize: 13)),
                          ]),
                        ))
                    .toList(),
                onSelected: (s) => _changerStatut(u, s),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(UtilisateurAdmin u) {
    final isLivreur = u.type == TypeUtilisateur.livreur;
    final color = isLivreur ? const Color(0xFF7C3AED) : const Color(0xFF0891B2);
    final bg = isLivreur ? const Color(0xFFF5F3FF) : const Color(0xFFE0F7FA);

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
                CircleAvatar(radius: 24, backgroundColor: bg, child: Text(u.nom[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)), maxLines: 1),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(isLivreur ? 'Livreur' : 'Client', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color))),
                        const SizedBox(width: 6),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: u.statut.fondCouleur, borderRadius: BorderRadius.circular(20)), child: Text(u.statut.libelle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: u.statut.couleur))),
                      ]),
                    ],
                  ),
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
                  if (isLivreur && (u.noteMoyenne ?? 0) > 0) ...[
                    Row(children: [
                      Expanded(child: _miniStat('${u.livraisonsEffectuees}', 'Livraisons', Icons.local_shipping_rounded, const Color(0xFF7C3AED))),
                      const SizedBox(width: 10),
                      Expanded(child: _miniStat('${u.noteMoyenne}/5', 'Note', Icons.star_rounded, const Color(0xFFD97706))),
                    ]),
                    const SizedBox(height: 16),
                  ] else if (!isLivreur) ...[
                    _miniStat('${u.nombreCommandes}', 'Commandes passées', Icons.receipt_long_rounded, const Color(0xFF0891B2)),
                    const SizedBox(height: 16),
                  ],
                  const Text('Coordonnées', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEDF2F3))),
                    child: Column(children: [
                      _infoRow(Icons.email_outlined, 'Email', u.email),
                      _infoRow(Icons.phone_outlined, 'Téléphone', u.telephone),
                      _infoRow(Icons.location_on_outlined, 'Ville', u.ville),
                      _infoRow(Icons.calendar_today_outlined, 'Inscrit le', _fDate(u.dateInscription)),
                      if (isLivreur && u.vehicule != null)
                        _infoRow(Icons.two_wheeler_rounded, 'Véhicule', u.vehicule!),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  const Text('Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  if (u.statut == StatutCompte.actif)
                    _actionBtn('Suspendre le compte', Icons.block_rounded, const Color(0xFFDC2626), const Color(0xFFFEE2E2), () => _changerStatut(u, StatutCompte.suspendu))
                  else if (u.statut == StatutCompte.suspendu || u.statut == StatutCompte.enAttente)
                    _actionBtn('Activer le compte', Icons.check_circle_outline_rounded, const Color(0xFF16A34A), const Color(0xFFDCFCE7), () => _changerStatut(u, StatutCompte.actif)),
                  if (u.statut == StatutCompte.enAttente) ...[
                    const SizedBox(height: 8),
                    _actionBtn('Refuser la demande', Icons.cancel_outlined, const Color(0xFFDC2626), const Color(0xFFFEE2E2), () => _changerStatut(u, StatutCompte.suspendu)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEDF2F3))),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          ]),
        ),
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

  String _fDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
