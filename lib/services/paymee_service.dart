import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymeeService {
  static const String apiKey = "9034cf8dfbd8aa3b88376aed80fd5c7928257a76";
  static const String baseUrl = "https://sandbox.paymee.tn/api/v2";

  static const String returnURL = "https://myapp.com/paymee-success";
  static const String cancelURL = "https://myapp.com/paymee-cancel";

  // 🚀 CREATE PAYMENT
  static Future<Map<String, dynamic>?> initiatePayment({
    required double amount,
    required String note,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String orderId,
  }) async {
    final body = {
      "amount": amount.toInt(),
      "note": note,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "return_url": returnURL,
      "cancel_url": cancelURL,

      // 🔥 OBLIGATOIRE POUR TON COMPTE PAYMEE
      "webhook_url": "https://webhook.site/a3d5cbb2-131f-4543-a12a-628abfa09e7a",

      "order_id": orderId,
    };


    final response = await http.post(
      Uri.parse("$baseUrl/payments/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $apiKey",
      },
      body: jsonEncode(body),
    );

    print("======= PAYMEE CREATE RESPONSE =======");
    print(response.body);
    print("======================================");

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // ✔️ Garder l'URL Paymee originale (/gateway)
    } else {
      print("Erreur Paymee: ${response.body}");
      return null;
    }
  }

  // 🚀 CHECK PAYMENT STATUS
  static Future<Map<String, dynamic>?> checkPayment(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/payments/$token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $apiKey",
      },
    );

    print("======= PAYMEE CHECK RESPONSE =======");
    print(response.body);
    print("====================================");

    if (response.statusCode == 200) {

      // ❗ Empêcher le crash si Paymee renvoie du HTML
      if (!response.body.trim().startsWith("{")) {
        print("❌ ERREUR : Paymee a renvoyé du HTML au lieu du JSON !");
        print(response.body);
        return null;
      }

      return jsonDecode(response.body);
    }


  }
}
