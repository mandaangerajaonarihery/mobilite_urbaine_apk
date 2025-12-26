import 'package:flutter/material.dart';
import 'package:all_pnud/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:all_pnud/widgets/app_scaffold.dart';
import 'package:all_pnud/widgets/footer_widget.dart'; // ✅ ajoute le point-virgule ici

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();

  void _scrollToFeatures() {
    Scrollable.ensureVisible(
      _featuresKey.currentContext!,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    localizations.landingTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.rocket_launch_rounded, size: 22),
                    label: Text(
                      localizations.startButton, // ✅ traduction ici
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    localizations.featuresTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  key: _featuresKey,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.directions_bus_filled,
                        title: localizations.feature1Title,
                        description: localizations.feature1Desc,
                        imagePath: 'assets/images/ARRET.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.location_city,
                        title: localizations.feature2Title,
                        description: localizations.feature2Desc,
                        imagePath: 'assets/images/Antananarivo.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.payments,
                        title: localizations.feature3Title,
                        description: localizations.feature3Desc,
                        imagePath: 'assets/images/agent.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.pin_drop_outlined,
                        title: localizations.feature4Title,
                        description: localizations.feature4Desc,
                        imagePath: 'assets/images/carte.jpg',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // ✅ Footer ajouté ici
                FooterWidget(
                  companyName: 'I-zotra',
                  onPrivacyTap: () => context.go('/privacy'),
                  onTermsTap: () => context.go('/terms'),
                ),
              ],
            ),
          ),
           Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              // Action sur clic : aller sur la page de la carte
              context.go('/apk_pnud/map');
            },
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.map),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String imagePath,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint("⚠️ Erreur de chargement d'image : $imagePath");
              return Container(
                height: 150,
                color: theme.colorScheme.surfaceVariant,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 50,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 30, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium,
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
}
