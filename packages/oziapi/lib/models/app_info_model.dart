class AppInfo {
  final String name;
  final String packageName;
  final List<SocialMedia> socialMedias;

  AppInfo({
    required this.name,
    required this.packageName,
    required this.socialMedias,
  });
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    var socialList = json['social'] as List<dynamic>? ?? [];
    List<SocialMedia> socialMedias = socialList
        .map((social) => SocialMedia.fromJson(social))
        .toList();

    return AppInfo(
      name: json['name'] ?? '',
      packageName: json['package'] ?? '',
      socialMedias: socialMedias,
    );
  }
}

class SocialMedia {
  final String name;
  final String logo;
  final String url;

  SocialMedia({
    required this.name,
    required this.logo,
    required this.url,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
