// lib/screen/mobilite_urbaine/cooperative/affectation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:all_pnud/models/affectation.dart';
import 'package:all_pnud/services/affectation_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:all_pnud/services/file_service.dart';

class AffectationDetailScreen extends StatefulWidget {
  final Affectation affectation;

  const AffectationDetailScreen({Key? key, required this.affectation})
      : super(key: key);

  @override
  _AffectationDetailScreenState createState() =>
      _AffectationDetailScreenState();
}

class _AffectationDetailScreenState extends State<AffectationDetailScreen>
    with TickerProviderStateMixin {
  final AffectationService _affectationService = AffectationService();
  late Affectation _currentAffectation;
  bool _isUpdating = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentAffectation = widget.affectation;
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color get _statusColor {
  final status = _currentAffectation.statusCoop?.toLowerCase() ?? '';
  switch (status) {
    case 'valide':
    case 'validepaye': // 👈 AJOUT ICI : On considère que c'est vert aussi
      return const Color.fromARGB(255, 39, 176, 39); // Ou un vert un peu différent si tu veux distinguer
    case 'en attente':
      return const Color(0xFFE8B018);
    case 'rejete':
      return const Color(0xFFE53935);
    default:
      return const Color(0xFF5D5D5D);
  }
}

  LinearGradient get _statusGradient {
    final status = _currentAffectation.statusCoop?.toLowerCase() ?? '';
    switch (status) {
      case 'valide':
    case 'validepaye':
        return const LinearGradient(
          colors: [Color.fromARGB(255, 3, 132, 22), Color(0xFF00D620)],
        );
      case 'en attente':
        return const LinearGradient(
          colors: [Color(0xFFE8B018), Color(0xFFF5C542)],
        );
      case 'rejete':
        return const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFEF5350)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF5D5D5D), Color(0xFF757575)],
        );
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        _buildVehicleCard(),
                        const SizedBox(height: 16),
                        _buildDriverCard(),
                        const SizedBox(height: 16),
                        _buildDatesCard(),
                        if (_currentAffectation.chauffeur?.permisImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildImageCard(),
                          ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_currentAffectation.statusCoop == 'en attente')
            _buildFloatingActionButtons(),
          if (_isUpdating) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF131313),
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: _statusGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getStatusIcon(_currentAffectation.statusCoop ?? ''),
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
                              'Affectation',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentAffectation.vehicule?.immatriculation ??
                                  'N/A',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _currentAffectation.statusCoop ?? 'Non renseigné';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _statusGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(status),
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
                  'Statut actuel',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return _modernCard(
      title: 'Véhicule',
      icon: Icons.directions_car_rounded,
      color: const Color.fromARGB(255, 12, 124, 4),
      children: [
        _buildInfoRow(
          icon: Icons.confirmation_number_rounded,
          label: 'Immatriculation',
          value: _currentAffectation.vehicule?.immatriculation ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.email_rounded,
          label: 'Email Propriétaire',
          value: _currentAffectation.vehicule?.emailProprietaire ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.info_rounded,
          label: 'Statut',
          value: _currentAffectation.vehicule?.status ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildDriverCard() {
    return _modernCard(
      title: 'Chauffeur',
      icon: Icons.person_rounded,
      color: const Color(0xFF098E00),
      children: [
        _buildInfoRow(
          icon: Icons.phone_rounded,
          label: 'Téléphone',
          value: _currentAffectation.chauffeur?.numPhonChauffeur ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.badge_rounded,
          label: 'Numéro Permis',
          value: _currentAffectation.chauffeur?.numPermisChauffeur ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.category_rounded,
          label: 'Catégorie',
          value: _currentAffectation.chauffeur?.categoriPermis ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildDatesCard() {
    return _modernCard(
      title: 'Informations',
      icon: Icons.calendar_today_rounded,
      color: const Color(0xFF098E00),
      children: [
        _buildInfoRow(
          icon: Icons.calendar_month_rounded,
          label: 'Date de création',
          value: _currentAffectation.createdAt?.substring(0, 10) ?? 'N/A',
        ),
        if (_currentAffectation.updatedAt != null) ...[
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.update_rounded,
            label: 'Dernière mise à jour',
            value: _currentAffectation.updatedAt?.substring(0, 10) ?? 'N/A',
          ),
        ],
      ],
    );
  }

  Widget _modernCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131313),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF098E00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF098E00),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5D5D5D),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF131313),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard() {
  // Utilisation du service pour générer l'URL
  final fullImageUrl = FileService.getPreviewUrl(
      _currentAffectation.chauffeur?.permisImage ?? '');

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF098E00), Color(0xFF00C21C)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF098E00).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.card_membership_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              'Permis de conduire',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF131313),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            fullImageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 250,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF098E00),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF098E00).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_rounded,
                      size: 60, color: Color(0xFF5D5D5D)),
                  SizedBox(height: 12),
                  Text(
                    'Image non disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5D5D5D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

      
  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Rejeter',
                icon: Icons.close_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                ),
                onPressed: () async {
                  final confirm = await _showConfirmDialog(
                    title: 'Rejeter l\'affectation',
                    message: 'Êtes-vous sûr de vouloir rejeter cette affectation ?',
                    confirmText: 'Rejeter',
                    isDestructive: true,
                  );
                  
                  if (confirm == true) {
                    setState(() => _isUpdating = true);
                    final success = await _affectationService
                        .rejeterAffectation(_currentAffectation.id!);
                    setState(() => _isUpdating = false);
                    
                    if (success) {
                      setState(() => _currentAffectation =
                          _currentAffectation.copyWith(statusCoop: 'rejete'));
                      _showCustomSnackBar('Affectation rejetée avec succès',
                          const Color(0xFFE53935), Icons.cancel_rounded);
                    } else {
                      _showCustomSnackBar('Erreur lors du rejet',
                          const Color(0xFFE53935), Icons.error_rounded);
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                label: 'Valider',
                icon: Icons.check_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C21C), Color(0xFF00D620)],
                ),
                onPressed: () async {
                  final confirm = await _showConfirmDialog(
                    title: 'Valider l\'affectation',
                    message: 'Êtes-vous sûr de vouloir valider cette affectation ?',
                    confirmText: 'Valider',
                    isDestructive: false,
                  );
                  
                  if (confirm == true) {
                    setState(() => _isUpdating = true);
                    final success = await _affectationService
                        .validerAffectation(_currentAffectation.id!);
                    setState(() => _isUpdating = false);
                    
                    if (success) {
                      setState(() => _currentAffectation =
                          _currentAffectation.copyWith(statusCoop: 'valide'));
                      _showCustomSnackBar('Affectation validée avec succès',
                          const Color(0xFF00C21C), Icons.check_circle_rounded);
                    } else {
                      _showCustomSnackBar('Erreur lors de la validation',
                          const Color(0xFFE53935), Icons.error_rounded);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDestructive
                          ? const Color(0xFFE53935)
                          : const Color(0xFF00C21C))
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDestructive ? Icons.warning_rounded : Icons.help_rounded,
                  size: 40,
                  color: isDestructive
                      ? const Color(0xFFE53935)
                      : const Color(0xFF00C21C),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131313),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5D5D5D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D5D5D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? const Color(0xFFE53935)
                            : const Color(0xFF00C21C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF098E00),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Traitement en cours...',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF131313),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 IconData _getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'valide':
      return Icons.check_circle_outline_rounded;
    case 'validepaye': // 👈 AJOUT ICI : Une icône spéciale "Validé + Payé"
      return Icons.verified_rounded; // Ou Icons.price_check_rounded
    case 'en attente':
      return Icons.schedule_rounded;
    case 'rejete':
      return Icons.cancel_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}
}