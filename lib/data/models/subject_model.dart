class Subject {
  final String college;
  final String specialization;
  final int phase;
  final String code;
  final String name;
  final int credits;
  final List<String> prerequisites;
  final String description;
  final List<String> resources;
  final List<String> skills;

  Subject({
    this.college = '',
    required this.specialization,
    required this.phase,
    required this.code,
    required this.name,
    required this.credits,
    required this.prerequisites,
    this.description = '',
    this.resources = const [],
    this.skills = const [],
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      college: (json['college'] ?? '').toString().trim(),
      specialization: (json['specialization'] ?? '').toString().trim(),
      phase: (json['phase'] as num).toInt(),
      code: (json['code'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      prerequisites: (json['prerequisites'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      description: (json['description'] ?? '').toString(),
      resources: (json['resources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      skills: (json['skills'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'college': college,
      'specialization': specialization,
      'phase': phase,
      'code': code,
      'name': name,
      'credits': credits,
      'prerequisites': prerequisites,
      'description': description,
      'resources': resources,
      'skills': skills,
    };
  }

  Subject copyWith({
    String? college,
    String? specialization,
    int? phase,
    String? code,
    String? name,
    int? credits,
    List<String>? prerequisites,
    String? description,
    List<String>? resources,
    List<String>? skills,
  }) {
    return Subject(
      college: college ?? this.college,
      specialization: specialization ?? this.specialization,
      phase: phase ?? this.phase,
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      prerequisites: prerequisites ?? this.prerequisites,
      description: description ?? this.description,
      resources: resources ?? this.resources,
      skills: skills ?? this.skills,
    );
  }
}
