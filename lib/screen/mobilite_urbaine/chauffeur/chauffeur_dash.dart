import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:all_pnud/services/file_service.dart';
import 'package:all_pnud/theme/theme.dart';
import 'dart:convert';
import 'dart:math' as math;

class ChauffeurDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> chauffeurData;

  const ChauffeurDashboardScreen({
    Key? key,
    required this.chauffeurData,
  }) : super(key: key);

  @override
  State<ChauffeurDashboardScreen> createState() =>
      _ChauffeurDashboardScreenState();
}

class _ChauffeurDashboardScreenState extends State<ChauffeurDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedVehicleIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simplement accéder à 'chauffeur' directement
    final chauffeurWrapper = widget.chauffeurData['chauffeur'] ?? {};
    final chauffeur = chauffeurWrapper['chauffeur'] ?? {};
    final citizen = chauffeur['citizen'] ?? {};

    // On récupère la liste INCOMPLÈTE depuis l'objet 'chauffeur'
    final affectationsFromChauffeur =
        (chauffeur['affectations'] as List<dynamic>? ?? []);

    // ========================= LA CORRECTION EST ICI =========================
    // On récupère la liste COMPLÈTE (celle avec les propriétaires).
    // Le bon chemin est depuis `chauffeurWrapper`, qui contient l'objet "data" de l'API.
    final affectationsFromRoot =
        (chauffeurWrapper['affectations'] as List<dynamic>? ?? []);
    // =======================================================================
    print("----------- DÉBUT DEBUG AFFECTATIONS -----------");
    print(
        "1. Contenu de affectationsFromChauffeur: $affectationsFromChauffeur");
    print("2. Contenu de affectationsFromRoot: $affectationsFromRoot");
    print("----------- FIN DEBUG AFFECTATIONS -----------");
    // Ta logique de fusion qui va maintenant fonctionner
    final affectations = {
      for (var aff in [...affectationsFromChauffeur, ...affectationsFromRoot])
        aff['id_affectation'] ?? aff['id']: aff
    }.values.toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, citizen),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildDriverProfileCard(context, chauffeur, citizen),
                    _buildStatsCards(context, affectations),
                    _buildVehiclesSection(context, affectations),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic citizen) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.buttonNormal,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppThemes.madagascarGradient,
            color: AppThemes.lightGreen.withOpacity(0.05),
          ),
          child: Stack(
            children: [
              // Motifs décoratifs
              Positioned(
                top: 20,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: const Text(
          'Espace Chauffeur',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.settings_outlined, color: Colors.white),
      //     onPressed: () {},
      //   ),
      //   const SizedBox(width: 8),
      // ],
    );
  }

  Widget _buildDriverProfileCard(
      BuildContext context, dynamic chauffeur, dynamic citizen) {
         final String? fullPhotoUrl = citizen?['citizen_photo'];
  String finalImageUrl = ''; // Une URL vide par défaut

  if (fullPhotoUrl != null && fullPhotoUrl.isNotEmpty) {
    const String baseUrlToRemove = 'https://gateway.tsirylab.com/serviceupload/file/';
    String photoFilename = fullPhotoUrl;

    if (fullPhotoUrl.startsWith(baseUrlToRemove)) {
      photoFilename = fullPhotoUrl.replaceFirst(baseUrlToRemove, '');
    }
    finalImageUrl = FileService.getPreviewUrl(photoFilename);
  }
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Photo avec badge
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.buttonNormal,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.buttonNormal.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                       child: CircleAvatar(
                    backgroundImage: NetworkImage(finalImageUrl), // On utilise la variable préparée
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: finalImageUrl.isEmpty 
                        ? const Icon(Icons.person, size: 40) 
                        : null,
                  ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.buttonNormal,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${citizen['citizen_name'] ?? ''} ${citizen['citizen_lastname'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chauffeur['numPhon_chauffeur'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: AppColors.buttonNormal,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Actif',
                      style: TextStyle(
                        color: AppColors.buttonNormal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          // Infos du permis
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.badge_outlined,
                  label: 'N° Permis',
                  value: chauffeur['numPermis_chauffeur'] ?? 'N/A',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.category_outlined,
                  label: 'Catégorie',
                  value: chauffeur['categori_permis'] ?? 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.buttonNormal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, List affectations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.directions_car,
              label: 'Véhicules',
              value: '${affectations.length}',
              color: AppColors.buttonNormal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.verified_outlined,
              label: 'Actifs',
              value:
                  '${affectations.where((a) => a['vehicule']?['status'] == 'active').length}',
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.schedule,
              label: 'En attente',
              value:
                  '${affectations.where((a) => a['vehicule']?['status'] == 'pending').length}',
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection(BuildContext context, List affectations) {
    if (affectations.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun véhicule affecté',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos véhicules apparaîtront ici une fois affectés',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              const Text(
                'Mes Véhicules',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${affectations.length} véhicule${affectations.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.buttonNormal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...affectations.asMap().entries.map((entry) {
          final index = entry.key;
          final aff = entry.value;
          return _buildVehicleCard(context, aff, index);
        }).toList(),
      ],
    );
  }

  Widget _buildVehicleCard(BuildContext context, dynamic aff, int index) {
    final vehicule = aff['vehicule'];
    final docs = vehicule?['documents'] as List<dynamic>? ?? [];
    final proprietaire = vehicule?['proprietaire'];
    final citizen = proprietaire?['citizen'] ?? {};
final String? fullPhotoUrl = citizen['citizen_photo'];
    String finalOwnerImageUrl = ''; // Une URL vide par défaut

    if (fullPhotoUrl != null && fullPhotoUrl.isNotEmpty) {
      const String baseUrlToRemove =
          'https://gateway.tsirylab.com/serviceupload/file/';
      String photoFilename = fullPhotoUrl;

      if (fullPhotoUrl.startsWith(baseUrlToRemove)) {
        photoFilename = fullPhotoUrl.replaceFirst(baseUrlToRemove, '');
      }
      finalOwnerImageUrl = FileService.getPreviewUrl(photoFilename);
    }
    
    // Ajoute ce print pour vérifier
    // if (proprietaire != null) {
    //   print("✅ Propriétaire trouvé pour le véhicule ${vehicule?['immatriculation']}");
    // } else {
    //   print("❌ PAS de propriétaire pour le véhicule ${vehicule?['immatriculation']}");
    // }
    final qrData = {
      "immatriculation": vehicule?['immatriculation'],
      "municipality_id":
          proprietaire?['municipality_id'] ?? proprietaire?['municipalityId'],
    };
    debugPrint(
        "QR Data for vehicle ${vehicule?['immatriculation']}: ${jsonEncode(qrData)}");
    // debugPrint("Vehicule: ${vehicule}");
    // debugPrint("Proprietaire: ${proprietaire}");
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du véhicule
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonNormal.withOpacity(0.1),
                  AppThemes.lightGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AppColors.buttonNormal,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicule?['immatriculation'] ?? 'Inconnu',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicule?['typeTransport']?['nom'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(vehicule?['status'] ?? 'N/A'),
              ],
            ),
          ),

          // Corps du véhicule
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Propriétaire
                if (proprietaire != null) ...[
                  const Text(
                    'Propriétaire',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
            backgroundImage: NetworkImage(finalOwnerImageUrl),
            radius: 24,
            child: finalOwnerImageUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${citizen['citizen_name'] ?? ''} ${citizen['citizen_lastname'] ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    citizen['citizen_city'] ??
                                        'Ville non renseignée',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Documents
                if (docs.isNotEmpty) ...[
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...docs.map((doc) => _buildDocumentItem(doc)).toList(),
                  const SizedBox(height: 20),
                ],

                // QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.buttonNormal.withOpacity(0.05),
                        AppThemes.lightGreen.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.buttonNormal.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'QR Code de vérification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: jsonEncode(qrData),
                          version: QrVersions.auto,
                          size: 180.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Scannez pour vérifier le véhicule et son propriétaire',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
      case 'actif':
        color = AppColors.buttonNormal;
        label = 'Actif';
        icon = Icons.check_circle;
        break;
      case 'pending':
      case 'en attente':
        color = const Color(0xFFFF9800);
        label = 'En attente';
        icon = Icons.pending;
        break;
      case 'inactive':
      case 'inactif':
        color = const Color(0xFFF44336);
        label = 'Inactif';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(dynamic doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icône du document
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: AppColors.buttonNormal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Infos du document
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['type'] ?? 'Document',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Statut: ${doc['status']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (doc['date_expiration'] != null)
                      Text(
                        'Expire: ${doc['date_expiration'].toString().substring(0, 10)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Aperçu
              if (doc['fichier_recto'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    FileService.getPreviewUrl(doc['fichier_recto']),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          // Verso si disponible
          if (doc['fichier_verso'] != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flip,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Verso disponible',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    FileService.getPreviewUrl(doc['fichier_verso']),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
