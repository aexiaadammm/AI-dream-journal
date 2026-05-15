class UserProfile {
  const UserProfile({
    this.id = 1,
    required this.name,
    required this.age,
    required this.nationality,
    required this.culturalBackground,
    required this.professionOrInterest,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String age;
  final String nationality;
  final String culturalBackground;
  final String professionOrInterest;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'nationality': nationality,
      'cultural_background': culturalBackground,
      'profession_or_interest': professionOrInterest,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, Object?> map) {
    return UserProfile(
      id: map['id'] as int,
      name: map['name'] as String,
      age: map['age'] as String,
      nationality: map['nationality'] as String,
      culturalBackground: map['cultural_background'] as String,
      professionOrInterest: map['profession_or_interest'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
