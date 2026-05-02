import '../entities/faq.dart';
import '../repositories/faq_repository.dart';

class GetFaqs {
  final FaqRepository repository;

  GetFaqs(this.repository);

  Stream<List<Faq>> call() {
    return repository.getFaqs();
  }
}
