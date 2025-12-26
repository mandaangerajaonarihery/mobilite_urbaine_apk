  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:jwt_decoder/jwt_decoder.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:all_pnud/services/auth_service.dart';
  import 'package:all_pnud/services/socket_service.dart';
  //import 'main.dart'; // Pour navigatorKey

  class AuthProvider with ChangeNotifier {
    String? _token;
    bool _isLoggedIn = false;
    bool _isLoading = true;
    Map<String, dynamic>? _decodedToken;
    final AuthService _authService = AuthService();

    // --- Getters ---
    String? get token => _token;
    bool get isLoggedIn => _isLoggedIn;
    bool get isLoading => _isLoading;
    Map<String, dynamic>? get decodedToken => _decodedToken;

    String? get userId => _decodedToken?['user_id'];
    String? get userEmail => _decodedToken?['user_email'];
    String? get userPseudo => _decodedToken?['user_pseudo'];
    String? get userPhone => _decodedToken?['user_phone'];
    String? get municipalityId => _decodedToken?['municipality_id'];
    String? get citizenId => _decodedToken?['id_citizen'];
    String? get userPhoto => null; // Pas dans le token

    // --- Rôles ---
    bool get isAgentRoutiere {
      final roles = _decodedToken?['roles'] as List<dynamic>? ?? [];
      return roles.any((role) => role['role_id'] == 88);
    }

    bool get isAgentParking {
      final roles = _decodedToken?['roles'] as List<dynamic>? ?? [];
      return roles.any((role) => role['role_id'] == 87);
    }

    AuthProvider() {
      _loadToken();
    }

    /// Charger le token depuis SharedPreferences
    Future<void> _loadToken() async {
      debugPrint("🔄 [AuthProvider] Début du chargement du token...");
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');

      if (savedToken != null && !JwtDecoder.isExpired(savedToken)) {
        _token = savedToken;
        _isLoggedIn = true;
        _decodedToken = JwtDecoder.decode(_token!);
        debugPrint("✅ [AuthProvider] Token valide trouvé, user connecté");

        // ⚡ Connexion automatique au socket
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final citizenId = _decodedToken?['id_citizen'];
          if (citizenId != null) {
            SocketService().connectOwner(citizenId); // <-- plus besoin de context
          }
        });

      } else {
        _token = null;
        _isLoggedIn = false;
        _decodedToken = null;
        debugPrint("❌ [AuthProvider] Pas de token ou token expiré, user NON connecté");
      }

      _isLoading = false;
      debugPrint("🏁 [AuthProvider] Chargement terminé -> isLoggedIn=$_isLoggedIn");
      notifyListeners();
    }

    /// Login utilisateur
    Future<bool> login(String email, String password) async {
      try {
        final token = await _authService.login(email, password);
        if (token != null) {
          _token = token;
          _isLoggedIn = true;
          _decodedToken = JwtDecoder.decode(_token!);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);

          notifyListeners();

          // ⚡ Connexion socket après login
          final citizenId = _decodedToken?['id_citizen'];
          if (citizenId != null) {
            SocketService().connectOwner(citizenId); // <-- plus besoin de context
          }

          return true;
        } else {
          return false;
        }
      } catch (e) {
        debugPrint("Erreur login: $e");
        return false;
      }
    }

    /// Logout utilisateur
    Future<void> logout() async {
      _token = null;
      _isLoggedIn = false;
      _decodedToken = null;

      // ⚡ Déconnecter le socket
      SocketService().disconnect();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      notifyListeners();
    }
  }
