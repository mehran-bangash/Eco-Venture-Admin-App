class StemChallengeModel {
  String? id;
  String? adminId; // Track creator
  final String title;
  final String category; // Science, Technology, Engineering, Mathematics
  final String difficulty; // Easy, Medium, Hard
  final int points;
  final String? imageUrl;
  final List<String> materials;
  final List<String> steps;

  StemChallengeModel({
    this.id,
    this.adminId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.points,
    this.imageUrl,
    required this.materials,
    required this.steps,
  });

  // Convert to Map for Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'points': points,
      'imageUrl': imageUrl,
      'materials': materials,
      'steps': steps,
    };
  }

  // Create from Firebase Map
  factory StemChallengeModel.fromMap(String id, Map<String, dynamic> map) {
    return StemChallengeModel(
      id: id,
      adminId: map['adminId'],
      title: map['title'] ?? '',
      category: map['category'] ?? 'Science',
      difficulty: map['difficulty'] ?? 'Easy',
      points: map['points']?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
      // Safely parse lists from dynamic maps
      materials: List<String>.from(map['materials'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
    );
  }

  // CopyWith for immutable updates (e.g., adding image URL after upload)
  StemChallengeModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? category,
    String? difficulty,
    int? points,
    String? imageUrl,
    List<String>? materials,
    List<String>? steps,
  }) {
    return StemChallengeModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      materials: materials ?? this.materials,
      steps: steps ?? this.steps,
    );
  }
}