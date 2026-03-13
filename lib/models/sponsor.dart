class Sponsor {
  final String id;
  final String name;
  final String logoUrl;
  final String websiteUrl;
  final String tier; // e.g., Gold, Silver, Bronze

  Sponsor({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.websiteUrl,
    required this.tier,
  });
}
