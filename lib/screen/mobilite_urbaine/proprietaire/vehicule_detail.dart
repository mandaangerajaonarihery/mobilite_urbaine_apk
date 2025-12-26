import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:all_pnud/models/vehicule.dart';
import 'package:all_pnud/services/file_service.dart';

class VehiculeDetailScreen extends StatefulWidget {
  final Vehicule vehicule;

  const VehiculeDetailScreen({Key? key, required this.vehicule})
      : super(key: key);

  @override
  State<VehiculeDetailScreen> createState() => _VehiculeDetailScreenState();
}

class _VehiculeDetailScreenState extends State<VehiculeDetailScreen> 
    with SingleTickerProviderStateMixin {
  
  // 🎨 PALETTE PRO (Cohérente avec le reste)
  final Color _primaryGreen = const Color(0xFF1B5E20);
  final Color _accentGreen = const Color(0xFF43A047);
  final Color _bgLight = const Color(0xFFF5F7F6);
  final Color _textDark = const Color(0xFF131313);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- LOGIQUE UI ---

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'valide':
      case 'validepaye':
        return const Color(0xFF2E7D32); // Vert succès
      case 'en_attente':
      case 'validenonpaye':
        return const Color(0xFFEF6C00); // Orange
      case 'refuse':
      case 'non_paye':
        return const Color(0xFFC62828); // Rouge
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'valide':
      case 'validepaye':
        return Icons.check_circle_rounded;
      case 'en_attente':
      case 'validenonpaye':
        return Icons.hourglass_top_rounded;
      case 'refuse':
        return Icons.cancel_rounded;
      case 'non_paye':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicule = widget.vehicule;
    final affectation = vehicule.affectation;
    final immatriculation = vehicule.immatriculation ?? 'Sans Plaque';
    final bool isBus = vehicule.typeTransport?.nom?.toLowerCase() == 'bus';

    // --- LOGIQUE MÉTIER CONSERVÉE ---
    final bool canPayAdhesion = isBus &&
        affectation != null &&
        (affectation.statusCoop?.toLowerCase() == 'validenonpaye');

    final bool canAskLicence = (isBus
            ? (affectation != null &&
                affectation.statusCoop?.toLowerCase() == 'validepaye')
            : true) &&
        (vehicule.licence == null);

    final bool canPayLicence = (isBus
            ? (affectation != null &&
                affectation.statusCoop?.toLowerCase() == 'validepaye')
            : true) &&
        vehicule.licence != null &&
        (vehicule.licence!.statusPaiement?.toLowerCase() == 'non_paye') &&
        (vehicule.statusDateDescente?.toLowerCase() == 'fait');

    final bool canPayAmende = vehicule.infraction != null &&
        (vehicule.infraction!.payee == false);

    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(immatriculation),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // 1. HEADER HERO (Plaque)
                      _buildHeroHeader(vehicule),
                      const SizedBox(height: 24),

                      // 2. ACTIONS PRIORITAIRES (Si disponibles)
                      if (canPayAdhesion || canAskLicence || canPayLicence || canPayAmende)
                        _buildActionsSection(
                          vehicule, 
                          canPayAdhesion, 
                          canAskLicence, 
                          canPayLicence, 
                          canPayAmende
                        ),

                      // 3. INFO GÉNÉRALES
                      _buildSectionTitle("Informations"),
                      _buildGeneralInfoCard(vehicule),
                      const SizedBox(height: 20),

                      // 4. COOPÉRATIVE (Si bus)
                      if (affectation != null && affectation.cooperative != null) ...[
                        _buildSectionTitle("Coopérative"),
                        _buildCoopCard(affectation),
                        const SizedBox(height: 20),
                      ],

                      // 5. LICENCE & INFRACTION
                      if (vehicule.licence != null || vehicule.infraction != null) ...[
                        _buildSectionTitle("Administratif"),
                        _buildAdminCard(vehicule),
                        const SizedBox(height: 20),
                      ],

                      // 6. DOCUMENTS
                      if (vehicule.documents != null && vehicule.documents!.isNotEmpty) ...[
                        _buildSectionTitle("Documents"),
                        _buildDocumentsList(vehicule.documents!),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 APP BAR
  Widget _buildSliverAppBar(String title) {
    return SliverAppBar(
      expandedHeight: 0, // AppBar simple
      floating: true,
      pinned: true,
      backgroundColor: _bgLight,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      centerTitle: true,
      title: Text(
        "Détail Véhicule",
        style: GoogleFonts.manrope(
          color: _textDark,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  // 🚙 HERO HEADER (PLAQUE)
  Widget _buildHeroHeader(Vehicule vehicule) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryGreen, _accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          // Simulation Plaque Immatriculation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Text(
              vehicule.immatriculation ?? 'INCONNU',
              style: GoogleFonts.robotoMono( // Police style "plaque"
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Badge Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(vehicule.status), color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  (vehicule.status ?? 'N/A').toUpperCase(),
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⚡ ACTIONS
  Widget _buildActionsSection(Vehicule vehicule, bool adhesion, bool askLicence, bool payLicence, bool amende) {
    return Column(
      children: [
        _buildSectionTitle("Actions Requises"),
        if (adhesion)
          _buildActionButton("Payer Adhésion", Icons.payment, const Color(0xFFEF6C00), () {
            context.pushNamed('page_paiement', extra: {
              'typePaiement': 'adhesion',
              'motif': 'Adhésion coopérative ${vehicule.immatriculation}',
              'vehicule': vehicule,
            });
          }),
        if (askLicence)
          _buildActionButton("Demander Licence", Icons.assignment_add, const Color(0xFF1565C0), () {
            context.pushNamed('demande_licence', extra: vehicule);
          }),
        if (payLicence)
          _buildActionButton("Payer Licence", Icons.credit_card, _primaryGreen, () {
            context.pushNamed('page_paiement', extra: {
              'typePaiement': 'licence',
              'motif': 'Paiement licence ${vehicule.immatriculation}',
              'vehicule': vehicule,
            });
          }),
        if (amende)
          _buildActionButton("Payer Amende", Icons.gavel, const Color(0xFFC62828), () {
            context.pushNamed('page_paiement', extra: {
              'typePaiement': 'amende',
              'motif': 'Paiement amende ${vehicule.immatriculation}',
              'vehicule': vehicule,
            });
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
      ),
    );
  }

  // 📝 INFO GENERALES
  Widget _buildGeneralInfoCard(Vehicule vehicule) {
    return _buildCard(
      children: [
        _buildInfoRow(Icons.category, "Type", vehicule.typeTransport?.nom),
        _buildDivider(),
        _buildInfoRow(Icons.flag, "Statut", vehicule.status, color: _getStatusColor(vehicule.status)),
        if (vehicule.dateDescente != null) ...[
          _buildDivider(),
          _buildInfoRow(Icons.calendar_today, "Inspection", 
            DateTime.parse(vehicule.dateDescente!).toLocal().toString().split(" ")[0]),
        ],
        if (vehicule.motifRefus?.isNotEmpty ?? false) ...[
          _buildDivider(),
          _buildInfoRow(Icons.error_outline, "Motif Refus", vehicule.motifRefus, color: const Color(0xFFC62828)),
        ],
      ],
    );
  }

  // 🏢 COOPERATIVE
  Widget _buildCoopCard(dynamic affectation) {
    return _buildCard(
      children: [
        _buildInfoRow(Icons.business, "Nom", affectation.cooperative!.nameCooperative),
        _buildDivider(),
        _buildInfoRow(Icons.verified_user, "Statut", affectation.statusCoop, color: _getStatusColor(affectation.statusCoop)),
        _buildDivider(),
        _buildInfoRow(Icons.monetization_on, "Droit", "${affectation.cooperative!.droitAdhesion} Ar", color: _primaryGreen, isBold: true),
      ],
    );
  }

  // ⚖️ ADMIN (Licence/Infraction)
  Widget _buildAdminCard(Vehicule vehicule) {
    List<Widget> rows = [];
    if (vehicule.licence != null) {
      rows.add(_buildInfoRow(Icons.card_membership, "Licence", vehicule.licence!.statusApprobation, color: _getStatusColor(vehicule.licence!.statusApprobation)));
      rows.add(_buildDivider());
      rows.add(_buildInfoRow(Icons.payment, "Paiement Lic.", vehicule.licence!.statusPaiement, color: _getStatusColor(vehicule.licence!.statusPaiement)));
    }
    if (vehicule.infraction != null) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      final bool paid = vehicule.infraction!.payee == true;
      rows.add(_buildInfoRow(Icons.warning, "Infraction", paid ? "Payée" : "Non Payée", color: paid ? _primaryGreen : const Color(0xFFC62828)));
    }
    return _buildCard(children: rows);
  }

  // 📂 DOCUMENTS
  Widget _buildDocumentsList(List<dynamic> docs) {
    return SizedBox(
      height: 140, // Hauteur fixe pour le scroll horizontal
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doc = docs[index];
          final url = FileService.getPreviewUrl(doc.fichierRecto ?? '');
          final statusColor = _getStatusColor(doc.status);

          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      url,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.description, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.type ?? 'Doc',
                        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: statusColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doc.status ?? '?',
                              style: GoogleFonts.manrope(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS UTILITAIRES ---

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _bgLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                Text(
                  value ?? 'N/A',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: color ?? _textDark,
                    fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[100], indent: 16, endIndent: 16);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}