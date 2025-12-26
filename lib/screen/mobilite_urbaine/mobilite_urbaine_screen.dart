// lib/screen/mobilite_urbaine/mobilite_urbaine_screen.dart

import 'package:all_pnud/services/chauffeur_service.dart';
import 'package:all_pnud/widgets/app_scaffold.dart';
import 'package:all_pnud/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:all_pnud/providers/auth_provider.dart';
import 'package:all_pnud/services/cooperative_service.dart';
import 'package:all_pnud/services/vehicule_service.dart';
import 'package:all_pnud/l10n/app_localizations.dart';

class MobiliteUrbaineScreen extends StatefulWidget {
  const MobiliteUrbaineScreen({Key? key}) : super(key: key);

  @override
  State<MobiliteUrbaineScreen> createState() => _MobiliteUrbaineScreenState();
}

class _MobiliteUrbaineScreenState extends State<MobiliteUrbaineScreen>
    with TickerProviderStateMixin {
  final CooperativeService _cooperativeService = CooperativeService();
  final VehiculeService _vehiculeService = VehiculeService();

  // Animations
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _particleAnimationController;

  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _headerAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);

    _cardAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _floatingAnimationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat(reverse: true);

    _particleAnimationController =
        AnimationController(duration: const Duration(seconds: 8), vsync: this)
          ..repeat();

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.easeOut),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.elasticOut),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _cardAnimationController, curve: Curves.elasticOut),
    );

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(
          parent: _floatingAnimationController, curve: Curves.easeInOut),
    );

    _particleAnimation =
        Tween<double>(begin: 0, end: 1).animate(_particleAnimationController);
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _floatingAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------
  // SECTION: BUILD
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return AppScaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(theme),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSpectacularHeader(theme, localizations),
                  _buildFuturisticCard(
                    theme: theme,
                    localizations: localizations,
                    title: localizations.cooperativeSpace,
                    description: localizations.cooperativeDescription,
                    icon: Icons.business,
                    features: [
                      localizations.cooperativeFeature1,
                      localizations.cooperativeFeature2,
                      localizations.cooperativeFeature3,
                      localizations.cooperativeFeature4,
                    ],
                    imageUrl:
                        "assets/images/coope.png", // 🚖 image locale pour Coopérative
                    accentColor: theme.colorScheme.primary,
                    onTap: _navigateToCooperativeSection,
                    delayIndex: 0,
                  ),
                  _buildFuturisticCard(
                    theme: theme,
                    localizations: localizations,
                    title: localizations.proprietaireSpace,
                    description: localizations.proprietaireDescription,
                    icon: Icons.person,
                    features: [
                      localizations.proprietaireFeature1,
                      localizations.proprietaireFeature2,
                      localizations.proprietaireFeature3,
                      localizations.proprietaireFeature4,
                    ],
                    imageUrl:
                        "assets/images/proprietaire.png", // 🚗 image locale pour Propriétaire
                    accentColor: theme.colorScheme.primary,
                    onTap: _navigateToProprietaireSection,
                    delayIndex: 1,
                  ),
                  _buildFuturisticCard(
                    theme: theme,
                    localizations: localizations,
                    title: localizations.chauffeurSpace,
                    description: localizations.chauffeurDescription,
                    icon: Icons.drive_eta,
                    features: [
                      localizations.chauffeurFeature1,
                      localizations.chauffeurFeature2,
                      localizations.chauffeurFeature3,
                      localizations.chauffeurFeature4,
                    ],
                    imageUrl:
                        "assets/images/chauffeur.png", // 👨‍✈️ image locale pour Chauffeur
                    accentColor: theme.colorScheme.primary,
                    onTap: _navigateToChauffeurSection,
                    delayIndex: 2,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // BACKGROUND
  // ----------------------------------------------------------------------
  Widget _buildAnimatedBackground(ThemeData theme) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withOpacity(0.9),
                theme.colorScheme.background,
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _particleAnimationController,
          builder: (context, child) {
            return Stack(
              children: List.generate(15, (index) {
                final progress = (_particleAnimation.value + index * 0.1) % 1.0;
                final size = MediaQuery.of(context).size;

                return Positioned(
                  left: (index * 80.0 + progress * 100) % size.width,
                  top: 50 +
                      (index * 40.0 + progress * 200) % (size.height - 200),
                  child: Opacity(
                    opacity: (0.3 - (index * 0.02)).clamp(0.1, 0.3),
                    child: Container(
                      width: 3 + (index % 4),
                      height: 3 + (index % 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------------------
  Widget _buildSpectacularHeader(
      ThemeData theme, AppLocalizations localizations) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             
              ),
              const SizedBox(height: 24),
              Icon(Icons.location_city,
                  size: 60, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                localizations.mobiliteTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.mobiliteSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // CARD
  // ----------------------------------------------------------------------
  Widget _buildFuturisticCard({
    required ThemeData theme,
    required AppLocalizations localizations,
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
    required VoidCallback onTap,
    required String imageUrl,
    required Color accentColor,
    int delayIndex = 0,
  }) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: Offset(0, 0.5 + (delayIndex * 0.1)),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            (delayIndex * 0.2).clamp(0.0, 1.0),
            (0.8 + (delayIndex * 0.2)).clamp(0.0, 1.0),
            curve: Curves.elasticOut,
          ),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: _cardScaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 8,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        child: Image.asset(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                    color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 12),
                            Text(description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7))),
                            const SizedBox(height: 16),
                            ...features.map((f) => Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: accentColor, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(f)),
                                  ],
                                )),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: onTap,
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(localizations.accessButton),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // NAVIGATION
  // ----------------------------------------------------------------------
  void _navigateToCooperativeSection() async {
    final theme = Theme.of(context);

 showLoadingDialog(
    context,
    color: theme.colorScheme.tertiary, // obligatoire
    message: "Chargement de votre espace...",
  );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final citizenId = authProvider.decodedToken?['id_citizen'];
      final token = authProvider.token;

      if (citizenId != null && token != null) {
        final cooperative =
            await _cooperativeService.getCooperativeByCitizenId(citizenId);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();

          if (cooperative != null) {
            if (cooperative.status == 'VALIDE') {
              context.goNamed('cooperative',
                  extra: {'cooperativeId': cooperative.id});
            } else if (cooperative.status == 'EN_ATTENTE') {
              context.goNamed('cooperative_pending',
                  extra: cooperative.toJson());
            } else {
              context.goNamed('cooperative_rejected');
            }
          } else {
            context.goNamed('cooperative_register');
          }
        }
      } else {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          context.goNamed('dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        context.goNamed('dashboard');
      }
    }
  }

  void _navigateToProprietaireSection() async {
    final theme = Theme.of(context);

    
  showLoadingDialog(
    context,
    color: theme.colorScheme.tertiary, // obligatoire
    message: "Chargement de votre espace...",
  );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final citizenId = authProvider.decodedToken?['id_citizen'];
      final token = authProvider.token;

      if (citizenId != null && token != null) {
        final vehicules =
            await _vehiculeService.getVehiculesByCitizenId(citizenId, token);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          if (vehicules.isNotEmpty) {
            context.goNamed('proprietaire_dashboard');
          } else {
            context.goNamed('proprietaire_register_vehicule');
          }
        }
      } else {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          context.goNamed('dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        context.goNamed('dashboard');
      }
    }
  }

  void _navigateToChauffeurSection() async {
  final theme = Theme.of(context);

  showLoadingDialog(
    context,
    color: theme.colorScheme.tertiary, // obligatoire
    message: "Vérification de votre profil...",
  );

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final citizenId = authProvider.decodedToken?['id_citizen'];
    final token = authProvider.token;

    if (citizenId != null && token != null) {
      final chauffeurService = ChauffeurService();
      final chauffeur =
          await chauffeurService.getChauffeurByCitizenIdEnriched(citizenId);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // <-- ferme le dialog

        if (chauffeur != null) {
          context.goNamed('chauffeur_dashboard', extra: {'chauffeur': chauffeur});
        } else {
          context.goNamed('chauffeur_register');
        }
      }
    }
  } catch (e) {
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // <-- ferme le dialog
      context.goNamed('dashboard');
    }
  }
}


}
