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

  String get initials {
    final parts = nom.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.isNotEmpty ? p[0].toUpperCase() : '?';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final creditsRaw = json['soldeCredits'] ?? json['credits'] ?? json['walletBalance'] ?? json['balance'];
    int credits = 0;
    if (creditsRaw is num) {
      credits = creditsRaw.toInt();
    } else {
      credits = int.tryParse(creditsRaw?.toString() ?? '') ?? 0;
    }

    return UserModel(
      nom: (json['nom'] ?? json['fullName'] ?? json['name'] ?? '').toString(),
      telephone: (json['telephone'] ?? json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: (json['avatar'] ?? json['avatarUrl'] ?? json['photoUrl'] ?? '').toString(),
      soldeCredits: credits,
    );
  }
}
