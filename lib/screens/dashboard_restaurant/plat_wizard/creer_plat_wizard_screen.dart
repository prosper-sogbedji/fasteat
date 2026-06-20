import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/mock/mock_restaurants.dart';
import '../../../models/menu_catalogue.dart';
import '../../../providers/restaurant_menu_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/platform_image_picker.dart';

class CreerPlatWizardScreen extends StatefulWidget {
  const CreerPlatWizardScreen({super.key, required this.restaurantId, this.platId});

  final String restaurantId;
  final String? platId;

  @override
  State<CreerPlatWizardScreen> createState() => _CreerPlatWizardScreenState();
}

class _CreerPlatWizardScreenState extends State<CreerPlatWizardScreen> {
  final _draft = PlatWizardDraft();

  String fcfa(num amount) {
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  late final TextEditingController _nom;
  late final TextEditingController _sousTitre;
  late final TextEditingController _descCourte;
  late final TextEditingController _descLongue;
  late final TextEditingController _prix;
  late final TextEditingController _prixPromo;
  late final TextEditingController _labelPromo;
  late final TextEditingController _ordre;
  late final TextEditingController _tagField;
  late final TextEditingController _creneau;
  late final TextEditingController _stockPortions;
  late final TextEditingController _motsCle;
  late final TextEditingController _optNom;
  late final TextEditingController _optSupp;
  late final TextEditingController _tempsPrep;
  late final TextEditingController _portions;
  late final TextEditingController _calories;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController();
    _sousTitre = TextEditingController();
    _descCourte = TextEditingController();
    _descLongue = TextEditingController();
    _prix = TextEditingController();
    _prixPromo = TextEditingController();
    _labelPromo = TextEditingController();
    _ordre = TextEditingController(text: '0');
    _tagField = TextEditingController();
    _creneau = TextEditingController(text: _draft.creneauHoraire);
    _stockPortions = TextEditingController();
    _motsCle = TextEditingController();
    _optNom = TextEditingController();
    _optSupp = TextEditingController();
    _tempsPrep = TextEditingController(text: '${_draft.tempsPreparationMin}');
    _portions = TextEditingController(text: '${_draft.portionsDefaut}');
    _calories = TextEditingController();

    if (widget.platId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<RestaurantMenuProvider>();
        final entry = provider.entreeParPlatId(widget.platId!);
        if (entry != null) {
          final plat = entry.plat;
          setState(() {
            _nom.text = plat.nom;
            _descLongue.text = plat.description;
            _prix.text = '${plat.prix}';
            _draft.categorie = plat.categorie;
            _draft.nom = plat.nom;
            _draft.prixFcfa = plat.prix;
            _draft.descriptionLongue = plat.description;
            _draft.imagesSelection = plat.images;
          });
        }
      });
    }
  }

  // ─── Gestion des images ──────────────────────────────────────────────────────
  Uint8List? _imagePrincipaleBytes;
  final List<Uint8List> _imagesSupplementairesBytes = [];

  Future<void> _pickImage({bool isPrincipal = true}) async {
    try {
      final bytes = await pickImageAsBytes();
      if (bytes == null) return;
      setState(() {
        if (isPrincipal) {
          _imagePrincipaleBytes = bytes;
        } else if (_imagesSupplementairesBytes.length < 2) {
          _imagesSupplementairesBytes.add(bytes);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection : $e')),
        );
      }
    }
  }

  bool get _hasPrincipalImage => _imagePrincipaleBytes != null;


  @override
  void dispose() {
    _nom.dispose();
    _sousTitre.dispose();
    _descCourte.dispose();
    _descLongue.dispose();
    _prix.dispose();
    _prixPromo.dispose();
    _labelPromo.dispose();
    _ordre.dispose();
    _tagField.dispose();
    _creneau.dispose();
    _stockPortions.dispose();
    _motsCle.dispose();
    _optNom.dispose();
    _optSupp.dispose();
    _tempsPrep.dispose();
    _portions.dispose();
    _calories.dispose();
    super.dispose();
  }

  void _flushVersDraft() {
    _draft.nom = _nom.text;
    _draft.sousTitre = _sousTitre.text;
    _draft.descriptionCourte = _descCourte.text;
    _draft.descriptionLongue = _descLongue.text;
    _draft.prixFcfa = int.tryParse(_prix.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final pp = int.tryParse(_prixPromo.text.replaceAll(RegExp(r'\D'), ''));
    _draft.prixPromoFcfa = (pp != null && pp > 0) ? pp : null;
    _draft.labelPromo = _labelPromo.text;
    _draft.ordreAffichage = int.tryParse(_ordre.text) ?? 0;
    _draft.creneauHoraire = _creneau.text;
    _draft.motsCleRecherche = _motsCle.text;
    _draft.tempsPreparationMin = int.tryParse(_tempsPrep.text) ?? _draft.tempsPreparationMin;
    _draft.portionsDefaut = int.tryParse(_portions.text) ?? _draft.portionsDefaut;
    final cal = int.tryParse(_calories.text.replaceAll(RegExp(r'\D'), ''));
    _draft.caloriesApprox = cal;
    if (!_draft.stockIllimite) {
      _draft.stockPortions = int.tryParse(_stockPortions.text);
    }
    
    // Mettre à jour imagesSelection pour la validation
    if (_imagePrincipaleBytes != null) {
      final base64Img = base64Encode(_imagePrincipaleBytes!);
      _draft.imagesSelection = [
        'data:image/png;base64,$base64Img',
        for (var i = 0; i < _imagesSupplementairesBytes.length; i++)
          'data:image/png;base64,${base64Encode(_imagesSupplementairesBytes[i]!)}'
      ];
    }
  }

  // Navigation helpers removed for single page

  Future<void> _sauverBrouillon() async {
    _flushVersDraft();
    if (!_draft.etapeValide(1) || !_draft.etapeValide(4)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Au minimum : nom (3 car.) et un prix valide pour enregistrer un brouillon.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enregistrement en cours...')));
    final ok = await context.read<RestaurantMenuProvider>().enregistrerDepuisAssistant(
          restoId: widget.restaurantId,
          draft: _draft,
          publier: false,
          platId: widget.platId,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brouillon enregistré dans le catalogue pro.')));
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'enregistrement.')));
      }
    }
  }

  Future<void> _publier() async {
    _flushVersDraft();
    bool isValid = true;
    int? failedStep;
    for (int i = 1; i <= 12; i++) {
      if (i != 11 && !_draft.etapeValide(i)) {
        failedStep = i;
        isValid = false;
        break;
      }
    }
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Étape $failedStep incomplète. Veuillez remplir tous les champs obligatoires (*) et cocher les cases de conformité.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publication en cours...')));
    final ok = await context.read<RestaurantMenuProvider>().enregistrerDepuisAssistant(
          restoId: widget.restaurantId,
          draft: _draft,
          publier: true,
          platId: widget.platId,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plat publié : visible sur la fiche restaurant.')));
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la publication du plat.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resto = mockRestaurants.firstWhere(
      (r) => r.id == widget.restaurantId,
      orElse: () => mockRestaurants.first,
    );
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nouveau plat', style: TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.bold)),
            Text(resto.nom, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 24, wide ? 32 : 16, 40),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: wide ? _buildDesktopLayout(wide) : _buildMobileLayout(wide),
                ),
              ),
            ),
          ),
          _barreActionsBottom(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _etapeInformationsGenerales(),
                  const SizedBox(height: 20),
                  _etapePhotosEtMedias(),
                  const SizedBox(height: 20),
                  _etapeOptionsEtSupplements(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _etapeTarifsEtStock(),
                  const SizedBox(height: 20),
                  _etapeCategorieEtVisibilite(),
                  const SizedBox(height: 20),
                  _etapeServiceEtModes(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _etapeConformite(wide),
      ],
    );
  }

  Widget _buildMobileLayout(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _etapeInformationsGenerales(),
        const SizedBox(height: 20),
        _etapePhotosEtMedias(),
        const SizedBox(height: 20),
        _etapeTarifsEtStock(),
        const SizedBox(height: 20),
        _etapeCategorieEtVisibilite(),
        const SizedBox(height: 20),
        _etapeServiceEtModes(),
        const SizedBox(height: 20),
        _etapeOptionsEtSupplements(),
        const SizedBox(height: 20),
        _etapeConformite(wide),
      ],
    );
  }

  Widget _barreActionsBottom() {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _sauverBrouillon,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Enregistrer brouillon'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _publier,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Publier le plat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carte({required String titre, required IconData icone, required List<Widget> enfants}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icone, color: const Color(0xFFFF7700), size: 20),
              const SizedBox(width: 12),
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...enfants,
        ],
      ),
    );
  }

  Widget _textFieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _etapeInformationsGenerales() {
    return _carte(
      titre: 'Informations Générales',
      icone: Icons.edit_note_rounded,
      enfants: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Nom du plat *'),
                  TextField(controller: _nom, decoration: _inputDeco(hint: 'Ex: Garba Royal')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Accroche courte'),
                  TextField(controller: _sousTitre, decoration: _inputDeco(hint: 'Le classique ivoirien revisité')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _textFieldTitle('Résumé carte (min. 10 car.) *'),
        TextField(controller: _descCourte, decoration: _inputDeco(hint: 'Attiéké, thon frit, piment...')),
        const SizedBox(height: 16),
        _textFieldTitle('Description détaillée (min. 20 car.) *'),
        TextField(
          controller: _descLongue,
          maxLines: 4,
          decoration: _inputDeco(hint: 'Plongez dans l\'authenticité...'),
        ),
      ],
    );
  }

  Widget _etapePhotosEtMedias() {
    return _carte(
      titre: 'Photos & Médias',
      icone: Icons.photo_library_outlined,
      enfants: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Photo Principale ───────────────────────────────────────────
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _pickImage(isPrincipal: true),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasPrincipalImage ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: _hasPrincipalImage ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _hasPrincipalImage
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(_imagePrincipaleBytes!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _imagePrincipaleBytes = null;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.primary),
                              SizedBox(height: 12),
                              Text(
                                'Ajouter la photo principale',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Appuyer pour choisir',
                                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // ─── Photos Supplémentaires ────────────────────────────────────
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _miniPhotoSlot(0),
                  const SizedBox(height: 16),
                  _miniPhotoSlot(1),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.tips_and_updates_outlined, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Conseil : de belles photos augmentent les ventes de 30%.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniPhotoSlot(int index) {
    final bool hasImage = index < _imagesSupplementairesBytes.length;
    return GestureDetector(
      onTap: () => _pickImage(isPrincipal: false),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage ? AppColors.primary : const Color(0xFFE2E8F0),
              width: hasImage ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_imagesSupplementairesBytes[index], fit: BoxFit.cover),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagesSupplementairesBytes.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF94A3B8), size: 28),
                ),
        ),
      ),
    );
  }

  Widget _etapeOptionsEtSupplements() {
    return _carte(
      titre: 'Options & Suppléments',
      icone: Icons.playlist_add_rounded,
      enfants: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Libellé option'),
                  TextField(controller: _optNom, decoration: _inputDeco(hint: 'Ex: Supplément fromage')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Prix (+ FCFA)'),
                  TextField(controller: _optSupp, keyboardType: TextInputType.number, decoration: _inputDeco(hint: '0')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: FilledButton.icon(
                onPressed: () {
                  final n = _optNom.text.trim();
                  final s = int.tryParse(_optSupp.text) ?? 0;
                  if (n.isEmpty) return;
                  setState(() {
                    _draft.optionsSupplement.add((nom: n, supplementFcfa: s));
                    _optNom.clear();
                    _optSupp.clear();
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
              ),
            ),
          ],
        ),
        if (_draft.optionsSupplement.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (var i = 0; i < _draft.optionsSupplement.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                title: Text(_draft.optionsSupplement[i].nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('+ ${fcfa(_draft.optionsSupplement[i].supplementFcfa)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () => setState(() => _draft.optionsSupplement.removeAt(i)),
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: const Text('Ces options permettent de personnaliser le plat.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ),
        ]
      ],
    );
  }

  Widget _etapeTarifsEtStock() {
    return _carte(
      titre: 'Tarifs & Stock',
      icone: Icons.payments_outlined,
      enfants: [
        _textFieldTitle('Prix client standard (FCFA) *'),
        TextField(controller: _prix, keyboardType: TextInputType.number, decoration: _inputDeco(hint: '0')),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Prix promo'),
                  TextField(controller: _prixPromo, keyboardType: TextInputType.number, decoration: _inputDeco(hint: 'Optionnel')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Libellé promo'),
                  TextField(controller: _labelPromo, decoration: _inputDeco(hint: 'Ex: Happy Hour')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestion du stock', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Si activé, les commandes sont ouvertes sans limite.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Switch(
              value: _draft.stockIllimite,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() {
                _draft.stockIllimite = v;
                if (v) _draft.stockPortions = null;
              }),
            ),
          ],
        ),
        if (!_draft.stockIllimite) ...[
          const SizedBox(height: 16),
          _textFieldTitle('Nombre de portions dispo'),
          TextField(controller: _stockPortions, keyboardType: TextInputType.number, decoration: _inputDeco(hint: 'Ex: 20')),
        ]
      ],
    );
  }

  Widget _etapeCategorieEtVisibilite() {
    return _carte(
      titre: 'Catégorie & Visibilité',
      icone: Icons.category_outlined,
      enfants: [
        _textFieldTitle('Rayon du menu *'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in PlatWizardDraft.categoriesSuggestion)
              ChoiceChip(
                label: Text(c),
                selected: _draft.categorie == c,
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _draft.categorie == c ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
                labelStyle: TextStyle(
                  color: _draft.categorie == c ? AppColors.primary : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _draft.categorie = c),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Ordre d\'affichage'),
                  TextField(controller: _ordre, keyboardType: TextInputType.number, decoration: _inputDeco(hint: '0')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textFieldTitle('Publication directe'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Oui', style: TextStyle(fontSize: 14)),
                    value: _draft.publierImmediatement,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _draft.publierImmediatement = v),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _textFieldTitle('Mots-clés de recherche'),
        TextField(controller: _motsCle, decoration: _inputDeco(hint: 'ivoirien, poisson, déjeuner...')),
      ],
    );
  }

  Widget _etapeServiceEtModes() {
    return _carte(
      titre: 'Service & Modes',
      icone: Icons.access_time_outlined,
      enfants: [
        _textFieldTitle('Jours de service :'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in PlatWizardDraft.joursLabels.entries)
              FilterChip(
                label: Text(e.value),
                selected: _draft.joursDisponibilite.contains(e.key),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundColor: Colors.white,
                checkmarkColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: _draft.joursDisponibilite.contains(e.key) ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
                labelStyle: TextStyle(
                  color: _draft.joursDisponibilite.contains(e.key) ? AppColors.primary : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _draft.joursDisponibilite.add(e.key);
                    } else {
                      _draft.joursDisponibilite.remove(e.key);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        _textFieldTitle('Activation par canal'),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Livraison à domicile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _draft.modeLivraison,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _draft.modeLivraison = v),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              SwitchListTile(
                title: const Text('Sur place / Emporter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _draft.modeSurPlace,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _draft.modeSurPlace = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _etapeConformite(bool wide) {
    Widget checkboxList(String title, String sub, bool val, Function(bool?) onChanged) {
       return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          value: val,
          onChanged: onChanged,
          title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
       );
    }
    
    return _carte(
      titre: 'Conformité & Légal',
      icone: Icons.verified_user_outlined,
      enfants: [
        wide 
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: checkboxList('Exactitude des infos', 'Ingrédients, allergènes et prix.', _draft.accepteCharteQualite, (v) => setState(() => _draft.accepteCharteQualite = v ?? false))),
              Expanded(child: checkboxList('Respect de la charte', 'Photos réelles et conformes.', _draft.accepteConformitePhotos, (v) => setState(() => _draft.accepteConformitePhotos = v ?? false))),
              Expanded(child: checkboxList('Conditions Pro', 'Acceptation de la responsabilité.', _draft.accepteMentionsLegales, (v) => setState(() => _draft.accepteMentionsLegales = v ?? false))),
            ],
          )
        : Column(
            children: [
              checkboxList('Exactitude des infos', 'Ingrédients, allergènes et prix.', _draft.accepteCharteQualite, (v) => setState(() => _draft.accepteCharteQualite = v ?? false)),
              const SizedBox(height: 8),
              checkboxList('Respect de la charte', 'Photos réelles et conformes.', _draft.accepteConformitePhotos, (v) => setState(() => _draft.accepteConformitePhotos = v ?? false)),
              const SizedBox(height: 8),
              checkboxList('Conditions Pro', 'Acceptation de la responsabilité.', _draft.accepteMentionsLegales, (v) => setState(() => _draft.accepteMentionsLegales = v ?? false)),
            ],
          ),
      ],
    );
  }
}
