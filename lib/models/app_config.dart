class AppConfig {
  final String baseUrl;
  final String projectName;
  final String developer;

  AppConfig({
    required this.baseUrl,
    required this.projectName,
    required this.developer,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      baseUrl: json['base_url'] ?? '',
      projectName: json['project_name'] ?? 'Agro-AHP Pro',
      developer: json['developer'] ?? 'Unknown',
    );
  }
}
