import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/faq.dart';
import '../../domain/usecases/get_faqs.dart';
import 'faq_event.dart';
import 'faq_state.dart';
class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final GetFaqs getFaqs;

  FaqBloc(this.getFaqs) : super(FaqInitial()) {
    on<FetchFaqs>(_onFetchFaqs);
  }

  Future<void> _onFetchFaqs(
      FetchFaqs event,
      Emitter<FaqState> emit,
      ) async {
    emit(FaqLoading());

    try {
      await emit.forEach<List<Faq>>(
        getFaqs(),
        onData: (faqs) => FaqLoaded(faqs),
        onError: (_, __) => FaqError('Failed to load FAQs'),
      );
    } catch (e) {
      emit(FaqError('Unexpected error occurred'));
    }
  }
}

