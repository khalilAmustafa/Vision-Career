class QuizQuestion {
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;
  final String explanation;
  final String difficultyTag;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficultyTag,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawChoices = (json['choices'] as List<dynamic>? ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (rawChoices.length != 4) {
      throw const FormatException('Each question must contain exactly 4 choices.');
    }

    final correctIndex = json['correct_answer_index'];

    return QuizQuestion(
      question: (json['question'] ?? '').toString().trim(),
      choices: rawChoices,
      correctAnswerIndex: correctIndex is int
          ? correctIndex
          : int.tryParse(correctIndex.toString()) ?? -1,
      explanation: (json['explanation'] ?? '').toString().trim(),
      difficultyTag: (json['difficulty_tag'] ?? 'hard').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'choices': choices,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'difficulty_tag': difficultyTag,
    };
  }
}
