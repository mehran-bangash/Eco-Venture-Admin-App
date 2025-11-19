

class QuizModel {
  String? id;
  String category;
  String title;
  int order;
  int passingPercentage;
  String? imageUrl;
  List<QuestionModel> questions;
  String? adminId;

  QuizModel({
    this.id,
    required this.category,
    required this.title,
    required this.order,
    required this.passingPercentage,
    this.imageUrl,
    required this.questions,
    this.adminId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'order': order,
      'passing_percentage': passingPercentage,
      'image_url': imageUrl,
      'questions': questions.map((x) => x.toMap()).toList(),
      'admin_id': adminId,
    };
  }

  factory QuizModel.fromMap(String id, Map<String, dynamic> map) {
    return QuizModel(
      id: id,
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      order: map['order']?.toInt() ?? 0,
      passingPercentage: map['passing_percentage']?.toInt() ?? 60,
      imageUrl: map['image_url'],
      questions: List<QuestionModel>.from(
        (map['questions'] as List<dynamic>? ?? []).map<QuestionModel>(
              (x) {
            // FIX: Safely convert the generic Map to Map<String, dynamic>
            // "x as Map<String, dynamic>" causes the crash.
            return QuestionModel.fromMap(Map<String, dynamic>.from(x as Map));
          },
        ),
      ),
      adminId: map['admin_id'],
    );
  }

  QuizModel copyWith({
    String? id,
    String? category,
    String? title,
    int? order,
    int? passingPercentage,
    String? imageUrl,
    List<QuestionModel>? questions,
    String? adminId,
  }) {
    return QuizModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      order: order ?? this.order,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      questions: questions ?? this.questions,
      adminId: adminId ?? this.adminId,
    );
  }
}

class QuestionModel {
  String question;
  List<String> options;
  String answer;
  String? imageUrl;

  QuestionModel({
    required this.question,
    required this.options,
    required this.answer,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
      'image_url': imageUrl,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      answer: map['answer'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  QuestionModel copyWith({
    String? question,
    List<String>? options,
    String? answer,
    String? imageUrl,
  }) {
    return QuestionModel(
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}