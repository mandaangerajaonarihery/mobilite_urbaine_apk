import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart'; // 📦 Package pour le guide
import 'package:all_pnud/services/cooperative_service.dart';
import 'package:all_pnud/services/affectation_service.dart';
import 'package:all_pnud/models/affectation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:all_pnud/models/ligne.dart';
import 'package:all_pnud/services/ligne_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:all_pnud/models/cooperative.dart';
import 'package:provider/provider.dart';
import 'package:all_pnud/providers/auth_provider.dart';

class DashboardCooperativeScreen extends StatefulWidget {
  final int cooperativeId;
  const DashboardCooperativeScreen({Key? key, required this.cooperativeId})
      : super(key: key);

  @override
  State<DashboardCooperativeScreen> createState() =>
      _DashboardCooperativeScreenState();
}

class _DashboardCooperativeScreenState
    extends State<DashboardCooperativeScreen> {
  @override
  Widget build(BuildContext context) {
    // 1️⃣ On enveloppe tout l'écran dans ShowCaseWidget
    // ✅ CORRECTION
    return ShowCaseWidget(
      builder: (context) =>
          _DashboardContent(cooperativeId: widget.cooperativeId),
    );
  } 
}

class _DashboardContent extends StatefulWidget {
  final int cooperativeId;
  const _DashboardContent({Key? key, required this.cooperativeId})
      : super(key: key);

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  late Future<List<Affectation>> _affectationsFuture;
  late Future<List<Ligne>> _lignesFuture;

  final AffectationService _affectationService = AffectationService();
  final LigneService _ligneService = LigneService();
  final CooperativeService _cooperativeService = CooperativeService();
  final TextEditingController _searchController = TextEditingController();

  // 🔑 Clés pour le guide utilisateur
  final GlobalKey _oneKey = GlobalKey(); // Recherche
  final GlobalKey _twoKey = GlobalKey(); // Stats
  final GlobalKey _threeKey = GlobalKey(); // Vue Carte
  final GlobalKey _fourKey = GlobalKey(); // Filtre
  final GlobalKey _fiveKey = GlobalKey(); // Titre/Header

  Cooperative? cooperative;
  String _filtreStatus = 'all';
  String _searchQuery = '';
  bool _showMap = false;

  final Color _primaryGreen = const Color.fromARGB(255, 39, 176, 39);
  final Color _accentGreen = const Color(0xFF43A047);
  final Color _bgLight = const Color(0xFFF5F7F6);

  @override
  void initState() {
    super.initState();
    _refreshAllData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // 🚀 Lancer le guide automatiquement au premier démarrage (optionnel)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Decommentez pour lancer auto:
      // ShowCaseWidget.of(context).startShowCase([_fiveKey, _oneKey, _twoKey, _threeKey, _fourKey]);
    });
  }

  void _startUserGuide() {
    ShowCaseWidget.of(context).startShowCase([
      _fiveKey, // Bienvenue
      _oneKey, // Recherche
      _twoKey, // Stats
      _threeKey, // Toggle Map
      _fourKey // Filtre
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAllData() async {
    _fetchCooperativeName();
    setState(() {
      _affectationsFuture = _affectationService
          .getAffectationsByCooperative(widget.cooperativeId.toString());
      _lignesFuture =
          _ligneService.getLignesByCooperative(widget.cooperativeId.toString());
    });
  }

  void _fetchCooperativeName() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final citizenId = auth.citizenId;
    if (citizenId == null) return;

    if (cooperative == null) {
      cooperative =
          await _cooperativeService.getCooperativeByCitizenId(citizenId);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: _refreshAllData,
          color: _primaryGreen,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),

              SliverToBoxAdapter(child: _buildWelcomeHeader()),

              // 🔍 BARRE DE RECHERCHE AVEC GUIDE
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                sliver: SliverToBoxAdapter(
                  child: _buildShowcase(
                    key: _oneKey,
                    description:
                        "Recherchez rapidement un véhicule par immatriculation ou un chauffeur par téléphone.",
                    title: "Recherche Rapide",
                    child: _buildSearchBar(),
                  ),
                ),
              ),

              // 📊 STATS AVEC GUIDE
              SliverToBoxAdapter(
                child: _buildShowcase(
                  key: _twoKey,
                  title: "Vos Statistiques",
                  description:
                      "Un aperçu global : véhicules, chauffeurs, et demandes en attente.",
                  shapeBorder:
                      const CircleBorder(), // Juste pour l'exemple de style
                  child: FutureBuilder<List<Affectation>>(
                    future: _affectationsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const SizedBox(height: 100); // Placeholder
                      return _buildStatsGrid(snapshot.data!);
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(child: _buildSectionTitle()),

              _showMap ? _buildMapSliver() : _buildListSliver(),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
      ),
    );
  }

  // 🟢 WIDGET HELPER POUR LE GUIDE
  Widget _buildShowcase({
    required GlobalKey key,
    required String title,
    required String description,
    required Widget child,
    ShapeBorder? shapeBorder,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      targetBorderRadius: BorderRadius.circular(16),
      tooltipBackgroundColor: _primaryGreen,
      textColor: Colors.white,
      titleAlignment: TextAlign.center,
      descriptionAlignment: TextAlign.center,
      tooltipPadding: const EdgeInsets.all(12),
      targetPadding: const EdgeInsets.all(4),
      blurValue: 2, // Effet de flou sur le fond
      child: child,
    );
  }

  // 🟢 HEADER
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 70.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: _bgLight,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        // 💡 BOUTON GUIDE
        IconButton(
          onPressed: _startUserGuide,
          icon: Icon(Icons.help_outline_rounded, color: _primaryGreen),
          tooltip: "Guide utilisateur",
        ),
        const SizedBox(width: 4),

        _buildShowcase(
          key: _threeKey,
          title: "Vue Carte / Liste",
          description:
              "Basculez entre la liste des affectations et la carte GPS des lignes.",
          child: _buildActionButton(
            icon: _showMap ? Icons.list_alt_rounded : Icons.map_rounded,
            isActive: _showMap,
            onTap: () => setState(() => _showMap = !_showMap),
          ),
        ),
        const SizedBox(width: 8),
        _buildShowcase(
          key: _fourKey,
          title: "Filtres",
          description:
              "Affichez uniquement les demandes validées ou en attente.",
          child: _buildActionButton(
            icon: Icons.filter_list_rounded,
            isActive: _filtreStatus != 'all',
            onTap: _showFilterDialog,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.manrope(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Rechercher un véhicule, chauffeur...',
          hintStyle: GoogleFonts.manrope(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: _primaryGreen),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required bool isActive,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [_primaryGreen, _accentGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? _primaryGreen.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF1B5E20), size: 20),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Showcase(
      key: _fiveKey,
      title: "Bienvenue !",
      description:
          "Ceci est votre tableau de bord coopérative. Gérez votre flotte d'ici.",
      tooltipBackgroundColor: _primaryGreen,
      textColor: Colors.white,
      targetBorderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cooperative?.nameCooperative ?? "Coopérative",
              style: GoogleFonts.manrope(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B5E20),
                letterSpacing: -0.5,
              ),
            ),
            if (cooperative?.slogantCooperative != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  cooperative!.slogantCooperative!,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 📊 STATS
  Widget _buildStatsGrid(List<Affectation> affectations) {
    final uniqueVehicles =
        affectations.map((a) => a.vehicule?.immatriculation).toSet().length;
    final uniqueDrivers =
        affectations.map((a) => a.chauffeur?.id).toSet().length;
    final totalPending = affectations
        .where((a) => a.statusCoop?.toLowerCase() == 'en attente')
        .length;
    final totalValid = affectations.where((a) {
      final s = a.statusCoop?.toLowerCase() ?? '';
      return s == 'valide' || s == 'validepaye';
    }).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildHeroStatCard(
              "Véhicules",
              uniqueVehicles.toString(),
              Icons.directions_car_filled_rounded,
              [_primaryGreen, _accentGreen]),
          const SizedBox(width: 12),
          _buildHeroStatCard(
              "Chauffeurs",
              uniqueDrivers.toString(),
              Icons.people_alt_rounded,
              [const Color(0xFF00695C), const Color(0xFF26A69A)]),
          const SizedBox(width: 12),
          _buildHeroStatCard(
              "En attente",
              totalPending.toString(),
              Icons.hourglass_top_rounded,
              [const Color(0xFFEF6C00), const Color(0xFFFFA726)]),
          const SizedBox(width: 12),
          _buildHeroStatCard(
              "Validés",
              totalValid.toString(),
              Icons.check_circle_rounded,
              [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]),
        ],
      ),
    );
  }

  Widget _buildHeroStatCard(
      String label, String value, IconData icon, List<Color> colors) {
    return Container(
      width: 140,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _showMap ? 'Carte en direct' : 'Liste des affectations',
            style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5E20)),
          ),
          if (!_showMap && _filtreStatus != 'all')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _filtreStatus.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen),
              ),
            )
        ],
      ),
    );
  }

  // 📃 LISTE
  Widget _buildListSliver() {
    return FutureBuilder<List<Affectation>>(
      future: _affectationsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));

        var list = snapshot.data!;

        if (_filtreStatus != 'all') {
          if (_filtreStatus == 'valide') {
            list = list.where((a) {
              final s = a.statusCoop?.toLowerCase() ?? '';
              return s == 'valide' || s == 'validepaye';
            }).toList();
          } else {
            list = list
                .where((a) => a.statusCoop?.toLowerCase() == _filtreStatus)
                .toList();
          }
        }

        if (_searchQuery.isNotEmpty) {
          list = list.where((a) {
            final plate = a.vehicule?.immatriculation?.toLowerCase() ?? '';
            final phone = a.chauffeur?.numPhonChauffeur?.toLowerCase() ?? '';
            return plate.contains(_searchQuery) || phone.contains(_searchQuery);
          }).toList();
        }

        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Aucun résultat",
                      style: GoogleFonts.manrope(color: Colors.grey[500])),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final affectation = list[index];
              return _buildAffectationItem(affectation);
            },
            childCount: list.length,
          ),
        );
      },
    );
  }

  Widget _buildAffectationItem(Affectation affectation) {
    final status = affectation.statusCoop?.toLowerCase() ?? '';
    final bool isValid = status == 'valide' || status == 'validepaye';
    final bool isPending = status == 'en attente';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await context.pushNamed('affectation_detail',
                extra: affectation);
            if (result == true) _refreshAllData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Center(
                      child: Icon(Icons.directions_car_filled_rounded,
                          color: _primaryGreen)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        affectation.vehicule?.immatriculation ?? 'Inconnu',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: const Color(0xFF1B5E20)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_iphone_rounded,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            affectation.chauffeur?.numPhonChauffeur ?? "—",
                            style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFFFFF8E1)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPending
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF43A047),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    isPending ? 'En attente' : 'Validé',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPending
                          ? const Color(0xFFEF6C00)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSliver() {
    // ... (Code de la carte identique au précédent, mais pour le guide, on l'englobe dans _threeKey via le bouton)
    // Pour alléger la réponse, je conserve la logique existante.
    return SliverFillRemaining(
      hasScrollBody: true,
      child: FutureBuilder<List<Ligne>>(
        future: _lignesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final lignes = snapshot.data!;
          final initialCenter =
              lignes.isNotEmpty && lignes.first.trace.isNotEmpty
                  ? LatLng(lignes.first.trace[0][0], lignes.first.trace[0][1])
                  : LatLng(-18.8792, 47.5079);

          return Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FlutterMap(
                options:
                    MapOptions(initialCenter: initialCenter, initialZoom: 14),
                children: [
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                  PolylineLayer(
                    polylines: lignes
                        .map((l) => Polyline(
                              points: l.trace
                                  .map((c) => LatLng(c[0], c[1]))
                                  .toList(),
                              color: _primaryGreen,
                              strokeWidth: 5,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filtrer par statut",
                  style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _primaryGreen)),
              const SizedBox(height: 20),
              _buildFilterChip('Tous', 'all', Icons.grid_view_rounded),
              _buildFilterChip(
                  'En attente', 'en attente', Icons.hourglass_top_rounded),
              _buildFilterChip(
                  'Validés', 'valide', Icons.check_circle_outline_rounded),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filtreStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filtreStatus = value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? _primaryGreen : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? _primaryGreen : Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _primaryGreen : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: _primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
