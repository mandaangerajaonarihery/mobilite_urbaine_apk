import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../providers/notification_provider.dart';
import '../main.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  Map<String, dynamic>? _pendingRole;

  bool get isConnected => socket?.connected ?? false;

  void _connect() {
    // Déconnecter l'ancien socket s'il existe
    if (socket != null) {
      if (socket!.connected) {
        print("⚡ Socket déjà connecté");
        if (_pendingRole != null) {
          socket!.emit("register_role", _pendingRole);
          print("🟢 Rôle enregistré après reconnexion: $_pendingRole");
          _pendingRole = null;
        }
        return;
      }
      // Nettoyer l'ancien socket déconnecté
      socket!.dispose();
      socket = null;
    }

    // URL avec port explicite
    const socketUrl = 'https://gateway.agvm.mg:443';
    print("🔌 DEBUG SOCKET URL: $socketUrl");
    
    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['polling'])  // Polling uniquement
          .setPath('/serviceflotte/socket.io')
          .disableAutoConnect()
          .setExtraHeaders({
            "Origin": "https://gateway.agvm.mg",
          })
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    socket!.onConnect((_) {
      print("✅ Socket connecté avec succès");
      if (_pendingRole != null) {
        socket!.emit("register_role", _pendingRole);
        print("🟢 Rôle enregistré: $_pendingRole");
        _pendingRole = null;
      }
    });

    socket!.onDisconnect((_) {
      print("❌ Socket déconnecté");
    });

    socket!.onConnectError((err) {
      print("❌ Erreur connexion socket: $err");
    });

    socket!.onError((err) {
      print("❌ Erreur socket: $err");
    });

    _listenEvents();
    
    print("🚀 Tentative de connexion socket...");
    socket!.connect();
  }

  void connectOwner(String idCitizen) {
    _pendingRole = {"role": "owner", "id_citizen": idCitizen};
    print("🔄 Connexion socket pour Owner: $idCitizen");
    _connect();
  }

  void connectCoopAdmin(int idCoop) {
    _pendingRole = {"role": "coop_admin", "id_cooperative": idCoop};
    print("🔄 Connexion socket pour Coop Admin: $idCoop");
    _connect();
  }

  void disconnect() {
    if (socket != null) {
      print("🔌 Déconnexion socket");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      _pendingRole = null;
    }
  }

  void _listenEvents() {
    if (socket == null) return;

    final context = rootScaffoldMessengerKey.currentContext;
    if (context == null) {
      print("⚠️ Contexte rootScaffoldMessengerKey non disponible");
      return;
    }

    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

    void pushNotif(String event, dynamic data) {
      notifProvider.addNotification(event, data);
      print("🔔 Notification reçue: $event -> $data");
    }

    final events = [
      "owner_request_validated",
      "new_affectation",
      "coop_new_affectation",
      "new_affectation_nonbus",
      "new_cooperative",
      "new_infraction",
      "new_historique_parking",
      "new_paiement",
      "pay_historique_parking",
      "notifRecetteLocaleReceived",
    ];

    for (var event in events) {
      socket!.on(event, (data) => pushNotif(event, data));
    }
  }
}