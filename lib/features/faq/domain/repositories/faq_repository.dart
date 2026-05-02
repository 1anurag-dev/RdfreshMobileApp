import '../entities/faq.dart';

abstract class FaqRepository {
  Stream<List<Faq>> getFaqs();
}
