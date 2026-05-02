import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faq_model.dart';

abstract class FaqRemoteDataSource {
  Stream<List<FaqModel>> getFaqs();
}

class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  final FirebaseFirestore firestore;

  FaqRemoteDataSourceImpl({required this.firestore,});

  @override
  Stream<List<FaqModel>> getFaqs() {
    return firestore
        .collection('faqs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FaqModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
