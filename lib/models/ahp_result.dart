class AHPResult {
  final bool success;
  final List<double>? criteriaWeights;
  final double? criteriaCr;
  final List<List<double>>? alternativesWeights;
  final List<double>? alternativesCrs;
  final List<double>? globalScores;
  final List<int>? ranking;
  final List<String>? criteriaNames;
  final List<String>? alternativeNames;
  final String? error;
  final String? message;

  AHPResult({
    required this.success,
    this.criteriaWeights,
    this.criteriaCr,
    this.alternativesWeights,
    this.alternativesCrs,
    this.globalScores,
    this.ranking,
    this.criteriaNames,
    this.alternativeNames,
    this.error,
    this.message,
  });

  factory AHPResult.fromJson(Map<String, dynamic> json) {
    return AHPResult(
      success: json['success'] ?? false,
      criteriaWeights: json['criteria_weights'] != null
          ? List<double>.from(json['criteria_weights'].map((x) => x.toDouble()))
          : null,
      criteriaCr: json['criteria_cr']?.toDouble(),
      alternativesWeights: json['alternatives_weights'] != null
          ? List<List<double>>.from(json['alternatives_weights']
              .map((x) => List<double>.from(x.map((y) => y.toDouble()))))
          : null,
      alternativesCrs: json['alternatives_crs'] != null
          ? List<double>.from(json['alternatives_crs'].map((x) => x.toDouble()))
          : null,
      globalScores: json['global_scores'] != null
          ? List<double>.from(json['global_scores'].map((x) => x.toDouble()))
          : null,
      ranking: json['ranking'] != null
          ? List<int>.from(json['ranking'].map((x) => x))
          : null,
      criteriaNames: json['criteria_names'] != null
          ? List<String>.from(json['criteria_names'])
          : null,
      alternativeNames: json['alternative_names'] != null
          ? List<String>.from(json['alternative_names'])
          : null,
      error: json['error'],
      message: json['message'],
    );
  }
}
