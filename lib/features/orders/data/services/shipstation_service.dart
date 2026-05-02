import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class ShipStationService {
  final FirebaseFirestore _firestore;
  static const String _settingsCollection = 'settings';
  static const String _configDocId = 'config';
  static const String _baseUrl = 'https://ssapi.shipstation.com';

  ShipStationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, String>> _getCredentials() async {
    final doc = await _firestore
        .collection(_settingsCollection)
        .doc(_configDocId)
        .get();

    if (!doc.exists) {
      throw Exception('ShipStation configuration not found in Firestore');
    }

    final data = doc.data()!;
    final apiKey = data['API_KEY'] as String?;
    final apiSecret = data['API_SK'] as String?;
    final storeId = data['SHIPSTATION_STORE_ID'] as String? ?? '';

    if (apiKey == null || apiSecret == null) {
      throw Exception('ShipStation API Key or Secret is missing in Firestore');
    }

    return {'apiKey': apiKey, 'apiSecret': apiSecret, 'storeId': storeId};
  }

  Future<String> createOrder(CheckoutOrderModel order) async {
    try {
      final credentials = await _getCredentials();

      final authHeader =
          'Basic ${base64Encode(utf8.encode('${credentials['apiKey']}:${credentials['apiSecret']}'))}';

      final shipStationOrder = {
        'orderNumber': order.id,
        'orderDate': order.createdAt.toIso8601String(),
        'orderStatus': 'awaiting_shipment',
        'customerEmail': order.billingInfo.email,
        'billTo': {
          'name':
              '${order.billingInfo.firstName} ${order.billingInfo.lastName}',
          'street1': order.billingInfo.address,
          'city': order.billingInfo.city,
          'state': order.billingInfo.state,
          'postalCode': order.billingInfo.zip,
          'country': 'US',
          'phone': order.billingInfo.phone,
        },
        'shipTo': {
          'name':
              '${order.billingInfo.firstName} ${order.billingInfo.lastName}',
          'street1': order.billingInfo.address,
          'city': order.billingInfo.city,
          'state': order.billingInfo.state,
          'postalCode': order.billingInfo.zip,
          'country': 'US',
          'phone': order.billingInfo.phone,
        },
        'items': order.items.map((item) {
          return {
            'name': item.name,
            'quantity': item.quantity,
            'unitPrice': item.price,
            'sku': item.sku,
          };
        }).toList(),
        'amountPaid': order.total,
        'taxAmount': order.tax,
        'shippingAmount': 0.0,
        'customerNotes': 'Order created via mobile app. Reference: ${order.id}',
        'advancedOptions': {
          'storeId': credentials['storeId'],
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/orders/createorder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
        body: json.encode(shipStationOrder),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['orderId'].toString();
      } else {
        throw Exception('Failed to create ShipStation order: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
