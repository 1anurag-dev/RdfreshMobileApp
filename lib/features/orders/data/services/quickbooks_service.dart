import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quickbooks_settings.dart';
import '../models/order_model.dart';

class QuickBooksService {
  final FirebaseFirestore _firestore;
  static const String _settingsCollection = 'settings';
  static const String _quickbooksDocId = 'quickbooks';

  QuickBooksService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<QuickBooksSettings> _getSettings() async {
    final configDoc = await _firestore
        .collection(_settingsCollection)
        .doc('config')
        .get();

    final qbDoc = await _firestore
        .collection(_settingsCollection)
        .doc(_quickbooksDocId)
        .get();

    if (!configDoc.exists || !qbDoc.exists) {
      throw Exception('QuickBooks settings or config not found in Firestore');
    }

    return QuickBooksSettings.fromFirestore(
      configData: configDoc.data()!,
      qbData: qbDoc.data()!,
    );
  }

  Future<void> _saveSettings(QuickBooksSettings settings) async {
    await _firestore
        .collection(_settingsCollection)
        .doc(_quickbooksDocId)
        .update(settings.toTokenUpdateMap());
  }

  Future<QuickBooksSettings> _ensureValidToken(
    QuickBooksSettings settings,
  ) async {
    if (!settings.isTokenExpired) {
      return settings;
    }

    const baseUrl = 'https://oauth.platform.intuit.com';

    final response = await http.post(
      Uri.parse('$baseUrl/oauth2/v1/tokens/bearer'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${settings.clientId}:${settings.clientSecret}'))}',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': settings.refreshToken,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to refresh QuickBooks token: ${response.body}');
    }

    final data = json.decode(response.body);
    final newSettings = settings.copyWith(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      tokenExpiresAt: DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      ),
    );

    await _saveSettings(newSettings);

    return newSettings;
  }

  String _getBaseUrl(bool isProduction) {
    return isProduction
        ? 'https://quickbooks.api.intuit.com'
        : 'https://sandbox-quickbooks.api.intuit.com';
  }

  Future<String> _createOrGetCustomer(
    QuickBooksSettings settings,
    CheckoutBillingInfoModel billingInfo,
  ) async {
    final baseUrl = _getBaseUrl(settings.isProduction);

    final queryResponse = await http.get(
      Uri.parse(
        '$baseUrl/v3/company/${settings.realmId}/query?query=SELECT * FROM Customer WHERE PrimaryEmailAddr = \'${billingInfo.email}\' MAXRESULTS 1',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${settings.accessToken}',
      },
    );

    if (queryResponse.statusCode == 200) {
      final queryData = json.decode(queryResponse.body);
      final customers = queryData['QueryResponse']?['Customer'] as List?;

      if (customers != null && customers.isNotEmpty) {
        return customers[0]['Id'] as String;
      }
    }

    final customerData = {
      'GivenName': billingInfo.firstName,
      'FamilyName': billingInfo.lastName,
      'DisplayName': billingInfo.fullName,
      'PrimaryEmailAddr': {'Address': billingInfo.email},
      'PrimaryPhone': {'FreeFormNumber': billingInfo.phone},
      'BillAddr': {
        'Line1': billingInfo.address,
        'City': billingInfo.city,
        'CountrySubDivisionCode': billingInfo.state,
        'PostalCode': billingInfo.zip,
        'Country': 'USA',
      },
    };

    final createResponse = await http.post(
      Uri.parse('$baseUrl/v3/company/${settings.realmId}/customer'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.accessToken}',
      },
      body: json.encode(customerData),
    );

    if (createResponse.statusCode != 200) {
      throw Exception(
        'Failed to create QuickBooks customer: ${createResponse.body}',
      );
    }

    final responseData = json.decode(createResponse.body);
    return responseData['Customer']['Id'] as String;
  }

  Future<Map<String, String>> createInvoice(CheckoutOrderModel order) async {
    try {
      var settings = await _getSettings();
      settings = await _ensureValidToken(settings);

      final customerId = await _createOrGetCustomer(
        settings,
        order.billingInfo as CheckoutBillingInfoModel,
      );

      final baseUrl = _getBaseUrl(settings.isProduction);

      final lineItems = order.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return {
          'LineNum': index + 1,
          'Amount': item.price * item.quantity,
          'DetailType': 'SalesItemLineDetail',
          'SalesItemLineDetail': {
            'Qty': item.quantity,
            'UnitPrice': item.price,
            'ItemRef': {
              'name': item.name,
              'value': '1',
            },
          },
          'Description': item.name,
        };
      }).toList();

      if (order.tax > 0) {
        lineItems.add({
          'LineNum': lineItems.length + 1,
          'Amount': order.tax,
          'DetailType': 'SalesItemLineDetail',
          'SalesItemLineDetail': {
            'Qty': 1,
            'UnitPrice': order.tax,
            'ItemRef': {'name': 'Tax', 'value': '1'},
          },
          'Description': 'Sales Tax (8%)',
        });
      }

      final invoiceData = {
        'CustomerRef': {'value': customerId},
        'Line': lineItems,
        'TxnDate': order.createdAt.toIso8601String().split('T')[0],
        'DueDate': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        'BillEmail': {'Address': order.billingInfo.email},
        'BillAddr': {
          'Line1': order.billingInfo.address,
          'City': order.billingInfo.city,
          'CountrySubDivisionCode': order.billingInfo.state,
          'PostalCode': order.billingInfo.zip,
          'Country': 'USA',
        },
        'CustomerMemo': {'value': 'Order #${order.id}'},
      };

      final response = await http.post(
        Uri.parse('$baseUrl/v3/company/${settings.realmId}/invoice'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${settings.accessToken}',
        },
        body: json.encode(invoiceData),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to create QuickBooks invoice: ${response.body}',
        );
      }

      final responseData = json.decode(response.body);
      final invoiceId = responseData['Invoice']['Id'] as String;

      return {'invoiceId': invoiceId, 'customerId': customerId};
    } catch (e) {
      throw Exception('QuickBooks integration error: $e');
    }
  }

  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    var settings = await _getSettings();
    settings = await _ensureValidToken(settings);

    final baseUrl = _getBaseUrl(settings.isProduction);

    final response = await http.get(
      Uri.parse('$baseUrl/v3/company/${settings.realmId}/invoice/$invoiceId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${settings.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get QuickBooks invoice: ${response.body}');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
