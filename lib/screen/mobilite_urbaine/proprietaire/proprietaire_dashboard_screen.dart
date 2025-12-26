import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart'; // 📦 N'oubliez pas l'import
import 'package:all_pnud/providers/auth_provider.dart';
import 'package:all_pnud/services/vehicule_service.dart';
import 'package:all_pnud/models/vehicule.dart';

class ProprietaireDashboardScreen extends StatefulWidget {
  const ProprietaireDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProprietaireDashboardScreen> createState() =>
      _ProprietaireDashboardScreenState();
}

class _ProprietaireDashboardScreenState
    extends State<ProprietaireDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // 1️⃣ Enveloppe pour le guide utilisateur
    return ShowCaseWidget(
      builder: (context) => const _ProprietaireDashboardContent(),
    );
  }
}

class _ProprietaireDashboardContent extends StatefulWidget {
  const _ProprietaireDashboardContent({Key? key}) : super(key: key);

  @override
  State<_ProprietaireDashboardContent> createState() =>
      _ProprietaireDashboardContentState();
}

class _ProprietaireDashboardContentState
    extends State<_ProprietaireDashboardContent> with SingleTickerProviderStateMixin {
  late Future<List<Vehicule>> _vehiculesFuture;
  final VehiculeService _vehiculeService = VehiculeService();
  late AnimationController _animationController;

  // 🔑 Clés pour le guide
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _addFabKey = GlobalKey();

  // Couleurs du thème (Vert Pro pour matcher le header)
  final Color _showcaseColor = const Color.fromARGB(255, 39, 176, 39);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchVehicules();
    _animationController.forward();

    // 🚀 Lancement automatique du guide au premier démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Decommentez pour activer l'auto-start
      // ShowCaseWidget.of(context).startShowCase([_headerKey, _addFabKey]);
    });
  }

  void _startUserGuide() {
    ShowCaseWidget.of(context).startShowCase([_headerKey, _addFabKey]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicules() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final citizenId = authProvider.decodedToken?['id_citizen'];
    final token = authProvider.token;

    if (citizenId != null && token != null) {
      setState(() {
        _vehiculesFuture =
            _vehiculeService.getVehiculesByCitizenId(citizenId, token);
      });
    } else {
      setState(() {
        _vehiculesFuture = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchVehicules,
                  color: Colors.deepPurple,
                  child: FutureBuilder<List<Vehicule>>(
                    future: _vehiculesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      } else if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      } else {
                        return _buildVehicleList(snapshot.data!);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Showcase(
      key: _headerKey,
      title: "Tableau de Bord",
      description: "Bienvenue ! Retrouvez ici la liste de tous vos véhicules et leur statut.",
      tooltipBackgroundColor: _showcaseColor,
      textColor: Colors.white,
      targetBorderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 45, 168, 84),
              const Color.fromARGB(255, 39, 176, 39),
              const Color.fromARGB(255, 64, 236, 98),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 18, 190, 38).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Véhicules',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gérez votre flotte facilement',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Bouton Aide (point d'interrogation)
                GestureDetector(
                  onTap: _startUserGuide,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded, // Icône changée en '?' pour le guide
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(List<Vehicule> vehicules) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: vehicules.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index / vehicules.length) * 0.5,
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (index / vehicules.length) * 0.5,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: _VehiculeCard(vehicule: vehicules[index]),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des véhicules...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oups ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _fetchVehicules();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 207, 37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade100,
                      Colors.blue.shade100,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_bus_filled_rounded,
                  size: 80,
                  color: Colors.deepPurple.shade400,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Aucun véhicule enregistré',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Commencez par ajouter votre premier véhicule\npour gérer votre flotte efficacement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.goNamed('proprietaire_register_vehicule');
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Ajouter un véhicule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: const Color.fromARGB(255, 15, 190, 53).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Showcase(
      key: _addFabKey,
      title: "Ajouter un véhicule",
      description: "Appuyez ici pour enregistrer un nouveau véhicule dans votre flotte.",
      tooltipBackgroundColor: _showcaseColor,
      textColor: Colors.white,
      targetBorderRadius: BorderRadius.circular(20),
      tooltipPadding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 108, 194, 87),
              const Color.fromARGB(255, 39, 176, 44),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 84, 212, 45).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            context.goNamed('proprietaire_register_vehicule');
          },
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Nouveau véhicule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}

// Widget pour la carte d'un véhicule individuel avec design amélioré
class _VehiculeCard extends StatelessWidget {
  final Vehicule vehicule;
  const _VehiculeCard({Key? key, required this.vehicule}) : super(key: key);

  String getVehiculeStatusMessage(Vehicule vehicule) {
    final vehiculeStatus = vehicule.status?.toLowerCase() ?? '';
    if (vehiculeStatus == 'en_attente') {
      final affectationStatus =
          vehicule.affectation?.statusCoop?.toLowerCase() ?? '';
      switch (affectationStatus) {
        case 'en_attente':
          return 'En attente de validation';
        case 'validenonpaye':
          return 'Paiement requis';
        case 'rejete':
          return 'Rejeté par la coopérative';
        case 'validepaye':
          return 'Prêt pour la licence';
        default:
          return 'En attente';
      }
    } else {
      return vehicule.status ?? 'Inconnu';
    }
  }

  Color getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('rejeté')) return Colors.red.shade600;
    if (status.contains('paiement') || status.contains('requis'))
      return Colors.orange.shade600;
    if (status.contains('prêt') || status.contains('licence'))
      return Colors.blue.shade600;
    if (status.contains('attente')) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  IconData getStatusIcon(String status) {
    status = status.toLowerCase();
    if (status.contains('rejeté')) return Icons.cancel_outlined;
    if (status.contains('paiement') || status.contains('requis'))
      return Icons.payment_outlined;
    if (status.contains('prêt') || status.contains('licence'))
      return Icons.verified_outlined;
    if (status.contains('attente')) return Icons.schedule_outlined;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final statusMessage = getVehiculeStatusMessage(vehicule);
    final statusColor = getStatusColor(statusMessage);
    final statusIcon = getStatusIcon(statusMessage);
    final docCount = vehicule.documents?.length ?? 0;
    final validDocCount = vehicule.documents
            ?.where((d) => d.status?.toLowerCase() == 'validé')
            .length ??
        0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            context.goNamed('vehicule_detail', extra: vehicule);
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 72, 216, 129),
                            const Color.fromARGB(255, 21, 209, 30),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicule.immatriculation ?? 'N/A',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicule.typeTransport?.nom ?? 'Type inconnu',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Colors.grey.shade200,
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.business_rounded,
                        label: 'Coopérative',
                        value: vehicule.affectation?.cooperative
                                ?.nameCooperative ??
                            'Non affecté',
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.description_rounded,
                        label: 'Documents',
                        value: '$validDocCount / $docCount validés',
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Voir les détails',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 53, 177, 61),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color.fromARGB(255, 65, 187, 43),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}