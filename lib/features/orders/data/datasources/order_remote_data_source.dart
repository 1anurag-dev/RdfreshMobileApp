import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../services/quickbooks_service.dart';
import '../services/shipstation_service.dart';

abstract class CheckoutOrderRemoteDataSource {
  Future<CheckoutOrderModel> createOrder(CheckoutOrderModel order);
  Future<CheckoutOrderModel> getOrder(String orderId);
  Future<void> updateOrder(CheckoutOrderModel order);
}

class CheckoutOrderRemoteDataSourceImpl
    implements CheckoutOrderRemoteDataSource {
  final FirebaseFirestore firestore;
  final QuickBooksService quickBooksService;
  final ShipStationService shipStationService;

  CheckoutOrderRemoteDataSourceImpl({
    required this.firestore,
    required this.quickBooksService,
    required this.shipStationService,
  });

  @override
  Future<CheckoutOrderModel> createOrder(CheckoutOrderModel order) async {
    try {
      String? shipStationInternalId;
      try {
        shipStationInternalId = await shipStationService.createOrder(order);
      } catch (_) {}

      Map<String, String>? qbAuthData;
      CheckoutOrderModel workingOrder = order;

      try {
        qbAuthData = await quickBooksService.createInvoice(order);
      } catch (_) {}

      if (qbAuthData != null) {
        final invoiceId = qbAuthData['invoiceId'];
        final customerId = qbAuthData['customerId'];

        workingOrder = workingOrder.copyWith(
          quickbooksInvoiceId: invoiceId,
          status: 'processing',
        );

        try {
          await firestore.collection('users').doc(order.userId).update({
            'quickbooksCustomerId': customerId,
          });
        } catch (_) {}
      }

      return workingOrder.copyWith(shipstationOrderId: shipStationInternalId);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<CheckoutOrderModel> getOrder(String orderId) async {
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        throw Exception('Order not found');
      }

      return CheckoutOrderModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<void> updateOrder(CheckoutOrderModel order) async {
    try {
      await firestore.collection('orders').doc(order.id).update(order.toJson());
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }
}
