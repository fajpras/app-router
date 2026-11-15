/// Model hasil generate UI dari Google Stitch.
class StitchGeneration {
  final String id;
  final String prompt;
  final String flutterCode;
  final String? imageUrl;
  final DateTime createdAt;

  const StitchGeneration({
    required this.id,
    required this.prompt,
    required this.flutterCode,
    this.imageUrl,
    required this.createdAt,
  });

  factory StitchGeneration.fromJson(Map<String, dynamic> json) {
    return StitchGeneration(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      flutterCode: json['flutter_code'] as String? ??
          json['code'] as String? ??
          '',
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'flutter_code': flutterCode,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
