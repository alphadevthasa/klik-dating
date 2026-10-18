class DatingProfile {
  const DatingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.bio,
    required this.imageUrl,
    required this.distanceKm,
    required this.interests,
    required this.mutualMatch,
  });

  final String id;
  final String name;
  final int age;
  final String city;
  final String bio;
  final String imageUrl;
  final double distanceKm;
  final List<String> interests;
  final bool mutualMatch;

  DatingProfile copyWith({
    String? name,
    int? age,
    String? city,
    String? bio,
    String? imageUrl,
    List<String>? interests,
  }) => DatingProfile(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    city: city ?? this.city,
    bio: bio ?? this.bio,
    imageUrl: imageUrl ?? this.imageUrl,
    distanceKm: distanceKm,
    interests: interests ?? this.interests,
    mutualMatch: mutualMatch,
  );
}
