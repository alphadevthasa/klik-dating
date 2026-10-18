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
}
