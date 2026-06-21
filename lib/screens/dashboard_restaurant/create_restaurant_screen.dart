import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/api/auth_service.dart';
import '../../widgets/common/auth_left_panel.dart';

const _kDarkBg = Color(0xFF0F1923);
const _kTeal = Color(0xFFFF7700);
const _kAccent = Color(0xFFFF9100);

class CreateRestaurantScreen extends StatefulWidget {
  const CreateRestaurantScreen({super.key});
  @override
  State<CreateRestaurantScreen> createState() => _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState extends State<CreateRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Champs Établissement
  final _restoNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
  // Localisation
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  
  // Propriétaire
  final _ownerFullNameController = TextEditingController();
  final _ownerPhoneNumberController = TextEditingController();

  String _cuisineType = 'Beninoise';
  bool _deliveryEnabled = true;
  bool _scheduledPickupEnabled = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Beninoise',
    'Africaine',
    'Européenne',
    'Fast Food',
    'Boulangerie / Desserts',
    'Boissons / Jus locaux',
  ];

  @override
  void dispose() {
    _restoNameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _ownerFullNameController.dispose();
    _ownerPhoneNumberController.dispose();
    super.dispose();
  }

  String _formatPhone(String phone) {
    phone = phone.trim();
    if (phone.isEmpty) return phone;
    // Si le numéro ne commence pas par '+', on ajoute l'indicatif du Bénin (+229) par défaut
    if (!phone.startsWith('+')) {
      return '+229$phone';
    }
    return phone;
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.createRestaurant({
        'name': _restoNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'cuisineType': _cuisineType,
        'phoneNumber': _formatPhone(_phoneNumberController.text),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'ownerFullName': _ownerFullNameController.text.trim(),
        'ownerPhoneNumber': _formatPhone(_ownerPhoneNumberController.text),
        'deliveryEnabled': _deliveryEnabled,
        'scheduledPickupEnabled': _scheduledPickupEnabled,
      });

      if (!mounted) return;

      if (result.success) {
        // Redirection vers nextAction ou dashboard
        if (result.nextAction == 'add_menu_categories') {
          // Si on veut faire une étape spéciale, pour l'instant go dashboard
          context.go('/');
        } else {
          context.go('/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? "Erreur lors de la création"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: _kDarkBg,
      body: isDesktop ? _buildDesktop(size) : _buildMobile(size),
    );
  }

  Widget _buildDesktop(Size size) {
    return Row(
      children: [
        Expanded(flex: 6, child: _buildLeftPanel(size)),
        Expanded(flex: 4, child: _buildRightPanel()),
      ],
    );
  }

  Widget _buildMobile(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDarkBg, Color(0xFF132130)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogoMobile(),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildFormCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMobile() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kTeal, _kAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kTeal.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'FASTEAT BÉNIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Création du restaurant',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(Size size) {
    return const AuthLeftPanel(
      title: 'Créez votre\nrestaurant.',
      subtitle: 'Finalisez votre inscription et commencez à recevoir des commandes.',
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: const Color(0xFFF7F7F7),
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildFormCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bienvenue !',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pour finaliser votre inscription, veuillez renseigner les informations de votre établissement.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          _sectionTitle("Informations de l'établissement"),
          TextFormField(
            controller: _restoNameController,
            decoration: InputDecoration(
              labelText: 'Nom du restaurant',
              prefixIcon: const Icon(Icons.storefront_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _cuisineType,
            decoration: InputDecoration(
              labelText: 'Spécialité / Catégorie',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _cuisineType = v!),
          ),

          const SizedBox(height: 24),
          _sectionTitle("Contact & Localisation"),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Adresse physique',
              prefixIcon: const Icon(Icons.map_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _neighborhoodController,
                  decoration: InputDecoration(
                    labelText: 'Quartier',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _sectionTitle("Propriétaire"),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ownerFullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _ownerPhoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _sectionTitle("Services"),
          SwitchListTile(
            title: const Text('Livraison activée', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Accepter les commandes à livrer'),
            value: _deliveryEnabled,
            activeColor: _kTeal,
            onChanged: (v) => setState(() => _deliveryEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Retrait programmé', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Les clients peuvent venir chercher leur commande'),
            value: _scheduledPickupEnabled,
            activeColor: _kTeal,
            onChanged: (v) => setState(() => _scheduledPickupEnabled = v),
          ),

          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleCreate,
              style: FilledButton.styleFrom(
                backgroundColor: _kTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'FINALISER LA CRÉATION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
