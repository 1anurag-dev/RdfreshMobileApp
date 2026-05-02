import '../../domain/entities/faq.dart';
import '../../domain/repositories/faq_repository.dart';
import '../datasources/faq_remote_data_source.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FaqRemoteDataSource remoteDataSource;

  FaqRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Faq>> getFaqs() {
    return remoteDataSource.getFaqs();
  }
}
