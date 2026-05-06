class Club {
  final String id;
  final String name;
  final String city;
  final String address;
  final String description;
  final String shortDescription;
  final List<String> musicGenres;
  final String? ticketsUrl;
  final String? websiteUrl;
  final String? instagramUrl;
  final String schedule;
  final String priceRange;
  final int capacity;
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final String gradientKey;

  const Club({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.description,
    required this.shortDescription,
    required this.musicGenres,
    this.ticketsUrl,
    this.websiteUrl,
    this.instagramUrl,
    required this.schedule,
    required this.priceRange,
    required this.capacity,
    this.latitude,
    this.longitude,
    this.tags = const [],
    this.gradientKey = 'purple',
  });
}
