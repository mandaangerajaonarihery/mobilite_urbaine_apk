// lib/services/licence_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:all_pnud/constantes/api.dart';
class LicenceService {
  final String baseUrl = Api.baseUrl;

  /// Création d'une licence simple (déjà existante)
  Future<bool> createLicenceSimple({
    required String immatriculation,
    required int municipalityId,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/licences/simple");

    final body = {
      "immatriculation": immatriculation,
      "municipality_id": municipalityId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "*/*",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      debugPrint("⬅️ Licence POST Status: ${response.statusCode}");
      debugPrint("⬅️ Response body: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Erreur réseau lors de la création de licence: $e");
      return false;
    }
  }

  /// Finalisation d'une licence
  Future<bool> finalizeLicence({
    required String immatriculation,
    required int municipalityId,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/licences/valide/$immatriculation/$municipalityId");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Erreur finalisation licence: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception finalisation licence: $e");
      return false;
    }
  }

  /// 🚀 Création d'une licence avec documents (Taxi)
  Future<bool> createLicenceWithDocs({
    required Map<String, dynamic> licenceData,
    required List<http.MultipartFile> files,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/licences/with-docs");

    try {
      var request = http.MultipartRequest('POST', url);

      // Ajout des headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Ajout des champs de données
      licenceData.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      // Ajout des fichiers
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("⬅️ Licence with-docs POST Status: ${response.statusCode}");
      debugPrint("⬅️ Response body: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Erreur réseau lors de la création de licence avec docs: $e");
      return false;
    }
  }
  Future<bool> createVignetteWithDocs({
    required String immatriculation,
    required int municipalityId,
    String idCitizen = 'unknown',
    int typetransportId = 1,
    String emailProp = 'unknown@example.com',
    XFile? factureMoto,
    XFile? factureMotoVerso,
    XFile? assurance,
    XFile? assuranceVerso,
    String? dateExpirationAssurance,
  }) async {
    final url = Uri.parse("$baseUrl/licences/vignette-with-docs");

    try {
      var request = http.MultipartRequest('POST', url);

      // Champs textuels
      request.fields['immatriculation'] = immatriculation;
      request.fields['municipality_id'] = municipalityId.toString();
      request.fields['id_citizen'] = idCitizen;
      request.fields['typetransport_id'] = typetransportId.toString();
      request.fields['email_prop'] = emailProp;
      if (dateExpirationAssurance != null) {
        request.fields['date_expiration_assurance'] = dateExpirationAssurance;
      }

      // Champs fichiers
      if (factureMoto != null) {
        request.files.add(await _prepareMultipartFile('facture_moto', factureMoto));
      }
      if (factureMotoVerso != null) {
        request.files.add(await _prepareMultipartFile('facture_moto_verso', factureMotoVerso));
      }
      if (assurance != null) {
        request.files.add(await _prepareMultipartFile('assurance', assurance));
      }
      if (assuranceVerso != null) {
        request.files.add(await _prepareMultipartFile('assurance_verso', assuranceVerso));
      }

      // Envoi
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("⬅️ Vignette POST Status: ${response.statusCode}");
      debugPrint("⬅️ Response body: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Erreur réseau lors de la création de vignette: $e");
      return false;
    }
  }  
  Future<http.MultipartFile> _prepareMultipartFile(String fieldName, XFile file) async {
    if (kIsWeb) {
      Uint8List bytes = await file.readAsBytes();
      return http.MultipartFile.fromBytes(fieldName, bytes, filename: file.name);
    } else {
      return await http.MultipartFile.fromPath(fieldName, file.path, filename: file.name);
    }
  }


  /// Helper pour convertir XFile en MultipartFile
  Future<http.MultipartFile> prepareMultipartFile(String fieldName, XFile file) async {
    if (kIsWeb) {
      Uint8List bytes = await file.readAsBytes();
      return http.MultipartFile.fromBytes(fieldName, bytes, filename: file.name);
    } else {
      return await http.MultipartFile.fromPath(fieldName, file.path, filename: file.name);
    }
  }
}
