import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Import pour debugPrint
import 'package:all_pnud/constantes/api.dart';
class AuthService {
  final String baseUrl = Api.Urlauth;

  Future<String?> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/serviceauth/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode({
          "user_email": email,
          "user_password": password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["access_token"];
      } else {
        // Le serveur a répondu, mais avec une erreur.
        // Cela signifie que les identifiants sont invalides (erreur 401).
        if (kDebugMode) {
          debugPrint("Erreur ${response.statusCode}: ${response.body}");
        }
        throw Exception("Erreur ${response.statusCode}: ${response.body}");
      }
    } on http.ClientException catch (e) {
      // Le navigateur a bloqué la requête (erreur CORS).
      // Le message d'erreur sera "Failed to fetch".
      if (kDebugMode) {
        debugPrint("Erreur login: $e");
      }
      rethrow;
    } catch (e) {
      // Gérer toutes les autres exceptions.
      if (kDebugMode) {
        debugPrint("Erreur login inattendue: $e");
      }
      rethrow;
    }
  }
}