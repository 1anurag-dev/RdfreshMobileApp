import '../../domain/entities/faq.dart';

abstract class FaqState {}

class FaqInitial extends FaqState {}

class FaqLoading extends FaqState {}

class FaqLoaded extends FaqState {
  final List<Faq> faqs;

  FaqLoaded(this.faqs);
}

class FaqError extends FaqState {
  final String message;

  FaqError(this.message);
}
