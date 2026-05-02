import '../../domain/entities/faq.dart';

class FaqModel extends Faq {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
  });

  factory FaqModel.fromFirestore(Map<String, dynamic> json, String id) {
    return FaqModel(
      id: id,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}
