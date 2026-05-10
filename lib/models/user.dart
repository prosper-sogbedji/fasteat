class UserModel {
  const UserModel({
    required this.nom,
    required this.telephone,
    required this.email,
    required this.avatar,
    required this.soldeCredits,
  });

  final String nom;
  final String telephone;
  final String email;
  final String avatar;
  final int soldeCredits;
}
