import 'package:all_pnud/services/file_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:all_pnud/providers/auth_provider.dart';
import 'package:all_pnud/models/chauffeur.dart';
import 'package:all_pnud/services/affectation_service.dart';
import 'package:all_pnud/services/vehicule_service.dart';
import 'package:all_pnud/services/cooperative_service.dart';
import 'package:all_pnud/models/cooperative.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:all_pnud/services/chauffeur_service.dart';
import 'package:all_pnud/services/licence_service.dart';
import 'package:all_pnud/services/affectation_nonbus__service.dart'as nonBusService;
// Couleurs de la charte graphique
class AppColors {
  static const Color primary = Color(0xFF098E00);
  static const Color secondary = Color(0xFF00C21C);
  static const Color darkText = Color(0xFF131313);
  static const Color mediumText = Color(0xFF5D5D5D);
  static const Color tertiary = Color(0xFFE98C21);
  static const Color error = Color(0xFFDF3434);
  static const Color purple = Color(0xFF442EDF);
  static const Color background = Color(0xFFF8F8F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF00C21C);
  static const Color errorAction = Color(0xFFFF1313);
  static const Color info = Color(0xFF6653E5);
  static const Color warning = Color(0xFFE8B018);
  static const Color linkColor = Color(0xFF1d70b8);
  static const Color linkHover = Color(0xFF003078);
  static const Color buttonHover = Color(0xFF008713);
  static const Color buttonDisabled = Color(0xFF003078);
}

class DemandeVehiculeScreen extends StatefulWidget {
  const DemandeVehiculeScreen({super.key});

  @override
  State<DemandeVehiculeScreen> createState() => _DemandeVehiculeScreenState();
}

class _DemandeVehiculeScreenState extends State<DemandeVehiculeScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehiculeService _vehiculeService = VehiculeService();
  final TransportTypeService _transportTypeService = TransportTypeService();
  final CooperativeService _cooperativeService = CooperativeService();
  final ChauffeurService _chauffeurService = ChauffeurService();
  final licenceService = LicenceService();
  final dateAssuranceController = TextEditingController();
  final dateVisiteController = TextEditingController();
  final chauffeurCinController = TextEditingController();

  String? _selectedTypeVehicule;
  String? _selectedImmatriculation;
  Cooperative? _selectedCooperative;
  Chauffeur? _selectedChauffeur;

  late Future<List<TransportType>> _transportTypesFuture;
  late Future<List<Cooperative>> _cooperativesFuture;

  Map<String, XFile?> selectedFiles = {};

  final Map<String, List<String>> transportDocuments = {
    "Bus": [
      "Assurance recto",
      "Assurance verso",
      "Carte grise recto",
      "Carte grise verso",
      "Visite technique recto",
      "Visite technique verso",
      "Demande manuscrite recto",
      "Demande manuscrite verso",
      "Patente recto",
      "Patente verso",
    ],
    "Taxi": [
      "Assurance recto",
      "Assurance verso",
      "Carte grise recto",
      "Carte grise verso",
      "Visite technique recto",
      "Visite technique verso",
      "Demande manuscrite recto",
      "Demande manuscrite verso",
      "Patente recto",
      "Patente verso",
    ],
    "Bajaj": [
      "Assurance recto",
      "Assurance verso",
      "Carte grise recto",
      "Carte grise verso",
      "Visite technique recto",
      "Visite technique verso",
      "Demande manuscrite recto",
      "Demande manuscrite verso",
      "Patente recto",
      "Patente verso",
    ],
    "Moto": [
      "Facture moto recto",
      "Facture moto verso",
      "Assurance recto",
      "Assurance verso",
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }

  @override
  void dispose() {
    dateAssuranceController.dispose();
    dateVisiteController.dispose();
    chauffeurCinController.dispose();
    super.dispose();
  }

  void _fetchFormData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final municipalityId =
        int.tryParse(authProvider.decodedToken?['municipality_id'] ?? '');
    if (municipalityId != null) {
      _transportTypesFuture =
          _transportTypeService.getTransportTypesByMunicipality(municipalityId);
      _cooperativesFuture =
          _cooperativeService.getCooperativesByStatus("VALIDE", municipalityId);
    } else {
      _transportTypesFuture = Future.value([]);
      _cooperativesFuture = Future.value([]);
    }
  }

  Future<void> _checkChauffeurByCIN() async {
    final cinText = chauffeurCinController.text;
    if (cinText.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final municipalityId =
        int.tryParse(authProvider.decodedToken?['municipality_id'] ?? '');
    if (municipalityId == null) return;

    final chauffeur =
        await _chauffeurService.getChauffeurByCIN( cinText);

    setState(() => _selectedChauffeur = chauffeur);

    if (chauffeur != null) {
      _showSuccessSnackBar(
          'Chauffeur trouvé : ${chauffeur.nom ?? ''} ${chauffeur.prenom ?? ''}');
    } else {
      _showErrorSnackBar('Aucun chauffeur trouvé avec ce CIN.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.errorAction,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickFile(Function(XFile) onPicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) onPicked(pickedFile);
  }

  Future<http.MultipartFile> _prepareMultipartFile(
      String fieldName, XFile? file) async {
    if (file == null) throw Exception("File $fieldName is null");
    if (kIsWeb) {
      Uint8List bytes = await file.readAsBytes();
      return http.MultipartFile.fromBytes(fieldName, bytes,
          filename: file.name);
    } else {
      return await http.MultipartFile.fromPath(fieldName, file.path,
          filename: file.name);
    }
  }
  Future<void> _submitDemande() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    _showLoadingDialog();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final citizenId = authProvider.decodedToken?['id_citizen'] ?? 'unknown';
    final emailProp =
        authProvider.decodedToken?['user_email'] ?? 'unknown@example.com';
    final municipalityId =
        int.tryParse(authProvider.decodedToken?['municipality_id'] ?? '1') ?? 1;

    final transportTypes = await _transportTypesFuture;
    final selectedTransportType = transportTypes.firstWhere(
      (type) => type.name == _selectedTypeVehicule,
      orElse: () => TransportType(id: 1, name: 'Erreur'),
    );

    // ✅ Mapping pour correspondre aux noms attendus par l’API
    final Map<String, String> apiFieldMapping = {
      "Assurance recto": "assurance",
      "Assurance verso": "assurance_verso",
      "Carte grise recto": "cartegrise",
      "Carte grise verso": "cartegrise_verso",
      "Visite technique recto": "visite_technique",
      "Visite technique verso": "visite_technique_verso",
      "Demande manuscrite recto": "demandemanuscrit",
      "Demande manuscrite verso": "demandemanuscrit_verso",
      "Patente recto": "patente",
      "Patente verso": "patente_verso",
      "Facture moto recto": "facture_moto",
      "Facture moto verso": "facture_moto_verso",
    };

    List<http.MultipartFile> multipartFiles = [];
    for (var entry in selectedFiles.entries) {
      if (entry.value != null) {
        // On applique le mapping sinon fallback à la transformation par défaut
        final fieldName = apiFieldMapping[entry.key] ??
            entry.key.toLowerCase().replaceAll(' ', '_');
        multipartFiles.add(
          await _prepareMultipartFile(fieldName, entry.value),
        );
      }
    }

    bool success = false;

    try {
      if (_selectedTypeVehicule == "Moto") {
        XFile? factureMoto = selectedFiles["Facture moto recto"];
        XFile? factureMotoVerso = selectedFiles["Facture moto verso"];
        XFile? assurance = selectedFiles["Assurance recto"];
        XFile? assuranceVerso = selectedFiles["Assurance verso"];

        success = await licenceService.createVignetteWithDocs(
          immatriculation: _selectedImmatriculation!,
          idCitizen: citizenId,
          emailProp: emailProp,
          municipalityId: municipalityId,
          typetransportId: selectedTransportType.id,
          factureMoto: factureMoto,
          factureMotoVerso: factureMotoVerso,
          assurance: assurance,
          assuranceVerso: assuranceVerso,
          dateExpirationAssurance: dateAssuranceController.text,
        );
      } else if (_selectedTypeVehicule == "Taxi" || _selectedTypeVehicule == "Bajaj") {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token ?? '';

        success = await licenceService.createLicenceWithDocs(
          licenceData: {
            "immatriculation": _selectedImmatriculation,
            "id_citizen": citizenId,
            "email_prop": emailProp,
            "typetransport_id": selectedTransportType.id,
            "municipality_id": municipalityId,
            "date_expiration_assurance": dateAssuranceController.text,
            "date_expiration_visite_technique": dateVisiteController.text,
          },
          files: multipartFiles,
          token: token,
        );
        if (success && _selectedChauffeur != null) {
      print("✅ Licence créée. Tentative de création de l'affectation...");

      // On crée une instance du service
     final affectationService = nonBusService.AffectationService();

      // On appelle la méthode pour créer l'affectation
      // Note : On ne vérifie pas le retour ici, car le succès principal est la création de la licence.
      // On pourrait ajouter une gestion d'erreur plus fine si nécessaire.
 final bool affectationSuccess = await affectationService.createAffectationNonBus(
  // On peut maintenant utiliser '!' en toute sécurité car on a vérifié que l'id n'est pas null
  idChauffeur: _selectedChauffeur!.id!, 
  immatriculation: _selectedImmatriculation!,
  token: token,
);


// Maintenant, on peut afficher le résultat
print("📄 Résultat de la création de l'affectation : $affectationSuccess");

// BONUS : Tu peux même ajouter une logique en fonction de ce résultat
if (affectationSuccess) {
  print("✅ L'affectation a bien été enregistrée.");
} else {
  print("⚠️ La création de la licence a réussi, mais l'affectation a échoué.");
}
    }
      } else if (_selectedTypeVehicule == "Bus") {
        success = await _vehiculeService.createVehiculeWithDocs(
          vehiculeData: {
            "immatriculation": _selectedImmatriculation,
            "id_citizen": citizenId,
            "email_prop": emailProp,
            "typetransport_id": selectedTransportType.id,
            "municipality_id": municipalityId,
            "id_cooperative": _selectedCooperative?.id,
            "id_chauffeur": _selectedChauffeur?.id,
            "date_expiration_assurance": dateAssuranceController.text,
            "date_expiration_visite_technique": dateVisiteController.text,
          },
          files: multipartFiles,
        );

        if (success &&
            _selectedChauffeur != null &&
            _selectedCooperative != null) {
          final affectationService = AffectationService();
          await affectationService.createAffectation(
            idChauffeur: _selectedChauffeur!.id,
            immatriculation: _selectedImmatriculation!,
            idCooperative: _selectedCooperative!.id.toString(),
          );
        }
      }
    } catch (e) {
      success = false;
    }

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog();
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Votre demande est en cours d\'envoi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCustomDialog(
        icon: Icons.check_circle,
        iconColor: AppColors.success,
        title: 'Votre demande a été envoyée avec succès !',
        message: 'Notre équipe prendra soin de votre demande et vous répondra à toutes vos questions.',
        buttonText: 'D\'accord, c\'est compris',
        onPressed: () {
          Navigator.of(context).pop();
          context.goNamed('mobilite_urbaine');
        },
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCustomDialog(
        icon: Icons.error,
        iconColor: AppColors.errorAction,
        title: 'Votre demande n\'a pas pu être envoyée !',
        message: 'Une erreur s\'est produite lors de l\'envoi. Veuillez réessayer.',
        buttonText: 'D\'accord, c\'est compris',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildCustomDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.mediumText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFile(String label, XFile file) {
    setState(() {
      selectedFiles[label] = file;
    });
  }

  Widget _buildDocumentUploadCard(String label) {
    final file = selectedFiles[label];
    final isSelected = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.success : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.mediumText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.upload_file,
                    color: isSelected ? AppColors.success : AppColors.mediumText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.mediumText,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Aucun fichier sélectionné',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumText,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _pickFile((file) => _setFile(label, file)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isSelected ? 'Modifier le fichier' : 'Choisir un fichier',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocumentsForTransport(String transportType) {
    final docs = transportDocuments[transportType] ?? [];
    return docs.map((label) => _buildDocumentUploadCard(label)).toList();
  }

  Widget _buildCustomTextField({
    required String label,
    required String hint,
    String? initialValue,
    TextEditingController? controller,
    Function(String?)? onChanged,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            initialValue: initialValue,
            onChanged: onChanged,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.darkText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.mediumText.withOpacity(0.7),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.errorAction, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.errorAction, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.darkText,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.errorAction, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.errorAction, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            dropdownColor: AppColors.cardBackground,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mediumText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: const Text(
          'Demande de véhicule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Nouveau Véhicule",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Remplissez les informations ci-dessous pour enregistrer votre véhicule",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.mediumText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Section Informations générales
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Informations générales",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Champ immatriculation
                    _buildCustomTextField(
                      label: "Immatriculation",
                      hint: "Entrez votre immatriculation",
                      initialValue: _selectedImmatriculation,
                      onChanged: (val) => setState(() => _selectedImmatriculation = val),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer une immatriculation'
                          : null,
                    ),

                    // Dropdown type de véhicule
                    FutureBuilder<List<TransportType>>(
                      future: _transportTypesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            child: const Center(child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            )),
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.errorAction.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: AppColors.errorAction),
                                const SizedBox(width: 8),
                                Text("Erreur: ${snapshot.error}"),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning, color: AppColors.warning),
                                SizedBox(width: 8),
                                Text("Aucun type de transport disponible."),
                              ],
                            ),
                          );
                        } else {
                          return _buildCustomDropdown<String>(
                            label: "Type de véhicule",
                            value: _selectedTypeVehicule,
                            items: snapshot.data!
                                .map((type) => DropdownMenuItem(
                                      value: type.name,
                                      child: Text(type.name!),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() {
                              _selectedTypeVehicule = val;
                              selectedFiles.clear(); // reset fichiers
                            }),
                            validator: (value) => value == null
                                ? 'Veuillez sélectionner un type de véhicule'
                                : null,
                          );
                        }
                      },
                    ),

                    // Dates d'expiration
                    if (_selectedTypeVehicule != null && _selectedTypeVehicule != "Moto") ...[
                      _buildCustomTextField(
                        label: "Date d'expiration de l'assurance",
                        hint: "Sélectionnez une date",
                        controller: dateAssuranceController,
                        readOnly: true,
                        onTap: () => _selectDate(dateAssuranceController),
                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez sélectionner une date'
                            : null,
                      ),
                      _buildCustomTextField(
                        label: "Date d'expiration de la visite technique",
                        hint: "Sélectionnez une date",
                        controller: dateVisiteController,
                        readOnly: true,
                        onTap: () => _selectDate(dateVisiteController),
                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez sélectionner une date'
                            : null,
                      ),
                    ] else if (_selectedTypeVehicule == "Moto") ...[
                      _buildCustomTextField(
                        label: "Date d'expiration de l'assurance",
                        hint: "Sélectionnez une date",
                        controller: dateAssuranceController,
                        readOnly: true,
                        onTap: () => _selectDate(dateAssuranceController),
                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez sélectionner une date'
                            : null,
                      ),
                    ],
                  ],
                ),
              ),

              // Section Chauffeur (si pas moto)
              if (_selectedTypeVehicule != null && _selectedTypeVehicule != "Moto") ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.tertiary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Informations du chauffeur",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildCustomTextField(
                        label: 'CIN du chauffeur',
                        hint: 'Entrez le CIN du chauffeur',
                        controller: chauffeurCinController,
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          child: ElevatedButton(
                            onPressed: _checkChauffeurByCIN,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              minimumSize: const Size(80, 40),
                            ),
                            child: const Text(
                              'Rechercher',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Carte du chauffeur trouvé
                      if (_selectedChauffeur != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.success.withOpacity(0.2),
                              backgroundImage: _selectedChauffeur?.photo != null
                              ? NetworkImage(FileService.getPreviewUrl(_selectedChauffeur!.photo!))
                              : null,
                                child: _selectedChauffeur!.photo == null
                                    ? const Icon(Icons.person, color: AppColors.success, size: 30)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_selectedChauffeur!.nom ?? ''} ${_selectedChauffeur!.prenom ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'CIN: ${_selectedChauffeur!.cin}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.mediumText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Section Coopérative (si bus)
              if (_selectedTypeVehicule == "Bus") ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: AppColors.purple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Coopérative",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      FutureBuilder<List<Cooperative>>(
                        future: _cooperativesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              child: const Center(child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              )),
                            );
                          }
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.errorAction.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: AppColors.errorAction),
                                  const SizedBox(width: 8),
                                  Text("Erreur: ${snapshot.error}"),
                                ],
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning, color: AppColors.warning),
                                  SizedBox(width: 8),
                                  Text("Aucune coopérative disponible."),
                                ],
                              ),
                            );
                          }
                          return _buildCustomDropdown<Cooperative>(
                            label: "Choisir la coopérative",
                            value: _selectedCooperative,
                            items: snapshot.data!
                                .map((coop) => DropdownMenuItem(
                                      value: coop,
                                      child: Text(coop.nameCooperative ?? "Inconnu"),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedCooperative = val),
                            validator: (value) => value == null
                                ? 'Veuillez sélectionner une coopérative'
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Section Documents
              if (_selectedTypeVehicule != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.folder_open,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Documents du véhicule",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Téléchargez tous les documents requis pour votre véhicule",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumText,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ..._buildDocumentsForTransport(_selectedTypeVehicule!),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Bouton de soumission
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitDemande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return AppColors.buttonHover;
                        }
                        return null;
                      },
                    ),
                  ),
                  child: const Text(
                    "Enregistrer le véhicule",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}