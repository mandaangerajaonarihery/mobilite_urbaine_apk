import 'package:flutter/material.dart';
import 'package:all_pnud/widgets/bubble_background.dart';

import 'dart:math' as math;

class OnboardingPage extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPagePresenter(
        pages: [
          OnboardingPageModel(
            title: 'Tanàna voalamina kokoa',
            description:
                'Ataovy nomerika ny fitantanana ny fitateram-bahoaka, ny fiantsonana ary ny fiara eto Madagasikara.',
            imagePath: 'assets/images/villemieuxorganise.jpg',
            bgColor: const Color(0xFF0A4D68),
            accentColor: const Color(0xFF00D9FF),
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Fanaraha-maso marani-tsaina ny fiara',
            description:
                'Ataovy mora ny fisoratana anarana, fanaraha-maso ary fanarahana ny fiara ampiasaina ho an’ny daholobe.',
            imagePath: 'assets/images/transport_commun.jpg',
            bgColor: const Color(0xFF0C7C59),
            accentColor: const Color(0xFF00E5A0),
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Fitantanana fiantsonana vonjimaika',
            description:
                'Fantaro, araho ary fehezo ny toerana fiantsonana mba hahatonga ny fivezivezen’ny tanàna ho milamina kokoa.',
            imagePath: 'assets/images/parkingtaxi.jpg',
            bgColor: const Color(0xFF2E8B57),
            accentColor: const Color(0xFF7FFF00),
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Ady amin’ny hosoka',
            description:
                'Ataovy nomerika ny fandoavam-bola, fehezo ny fahazoan-dalana ary ahena ny kolikoly amin’ny rafitra azo antoka.',
            imagePath: 'assets/images/payementsecure.jpg',
            bgColor: const Color(0xFF0C7C59),
            accentColor: const Color(0xFF00E5A0),
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Ampifandraiso ny olom-pirenena sy ny kaominina',
            description:
                'Ataovy tsotra ny fifandraisana eo amin’ny mpitatitra, ny olom-pirenena ary ny manampahefana amin’ny sehatra iray.',
            imagePath: 'assets/images/connectcommune.jpg',
            bgColor: const Color(0xFFF4F4F4),
            accentColor: const Color(0xFF6C5CE7),
            textColor: const Color(0xFF1B1B1B),
          ),
        ],
        onFinish: onFinished,
      ),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

  const OnboardingPagePresenter({
    super.key,
    required this.pages,
    this.onSkip,
    this.onFinish,
  });

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPagePresenter>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Animation principale pour le contenu
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animation flottante continue
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Animation de pulsation pour les accents
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() {
      _currentPage = idx;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLastPage = _currentPage == widget.pages.length - 1;

    return Scaffold(
      body: BubbleBackground( // 🎈 AJOUT DU BUBBLE ICI
      baseColor: widget.pages[_currentPage].bgColor, // couleur dominante
      bubbleCount: 10, // nombre de bulles décoratives
      child: Stack(
      
        children: [
          // Fond avec gradient animé
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.pages[_currentPage].bgColor,
                  widget.pages[_currentPage].bgColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Particules décoratives animées
          ...List.generate(8, (index) {
            return AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final offset =
                    math.sin(_floatingController.value * 2 * math.pi + index) *
                        20;
                return Positioned(
                  left: (index % 4) * screenWidth / 4 + offset,
                  top: (index ~/ 4) * screenHeight / 2 + offset * 2,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: 80 + (index * 10).toDouble(),
                      height: 80 + (index * 10).toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.pages[_currentPage].accentColor
                                .withOpacity(0.3),
                            widget.pages[_currentPage].accentColor
                                .withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header avec bouton Skip
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Plusieurs logos alignés
                      Row(
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              "assets/images/app_logo.png",
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10), // espace entre logos
                          Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              "assets/images/univ-fianara.png",
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              "assets/images/agvm.jpg",
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              "assets/images/pnud.png",
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),

                      // Bouton Skip moderne
                      if (!isLastPage)
                        _ModernSkipButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              widget.pages.length - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          textColor: widget.pages[_currentPage].textColor,
                          accentColor: widget.pages[_currentPage].accentColor,
                        ),
                    ],
                  ),
                ),

                // PageView avec contenu
                Flexible(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, idx) {
                      final item = widget.pages[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20), // remplace Spacer

                              // Image avec effet glassmorphism et animations complexes
                              SizedBox(
                                height:
                                    screenHeight * 0.45, // hauteur contrôlée
                                child: AnimatedBuilder(
                                  animation: Listenable.merge([
                                    _scaleAnimation,
                                    _rotateAnimation,
                                    _floatingController,
                                  ]),
                                  builder: (context, child) {
                                    final floatValue = math.sin(
                                            _floatingController.value *
                                                2 *
                                                math.pi) *
                                        10;
                                    return Transform.translate(
                                      offset: Offset(0, floatValue),
                                      child: Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: Transform.rotate(
                                          angle: _rotateAnimation.value,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Cercles décoratifs pulsants
                                              AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  final pulse = 1.0 +
                                                      (_pulseController.value *
                                                          0.1);
                                                  return Transform.scale(
                                                    scale: pulse,
                                                    child: Container(
                                                      width: screenWidth * 0.7,
                                                      height: screenWidth * 0.7,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                            RadialGradient(
                                                          colors: [
                                                            item.accentColor
                                                                .withOpacity(
                                                                    0.2),
                                                            item.accentColor
                                                                .withOpacity(
                                                                    0.0),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              // Container glassmorphism
                                              Container(
                                                width: screenWidth * 0.65,
                                                height: screenWidth * 0.65,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      item.textColor
                                                          .withOpacity(0.15),
                                                      item.textColor
                                                          .withOpacity(0.05),
                                                    ],
                                                  ),
                                                  border: Border.all(
                                                    color: item.textColor
                                                        .withOpacity(0.2),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: item.accentColor
                                                          .withOpacity(0.3),
                                                      blurRadius: 60,
                                                      spreadRadius: -10,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      Image.asset(
                                                        item.imagePath,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      // Overlay gradient subtil
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              item.bgColor
                                                                  .withOpacity(
                                                                      0.1),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Accent décoratif
                                              Positioned(
                                                bottom: 20,
                                                right: 20,
                                                child: AnimatedBuilder(
                                                  animation: _pulseController,
                                                  builder: (context, child) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      decoration: BoxDecoration(
                                                        color: item.accentColor,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: item
                                                                .accentColor
                                                                .withOpacity(
                                                                    0.6),
                                                            blurRadius: 20 *
                                                                _pulseController
                                                                    .value,
                                                            spreadRadius: 5 *
                                                                _pulseController
                                                                    .value,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        _getIconForPage(idx),
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Textes avec animations
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Titre avec effet de surbrillance
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              item.accentColor
                                                  .withOpacity(0.15),
                                              item.accentColor
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: screenHeight * 0.03,
                                            fontWeight: FontWeight.w900,
                                            color: item.textColor,
                                            height: 1.2,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Description
                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 340),
                                        child: Text(
                                          item.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: screenHeight * 0.0185,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                item.textColor.withOpacity(0.8),
                                            height: 1.6,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicateurs personnalisés avec animations
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.pages.asMap().entries.map((entry) {
                      final isActive = _currentPage == entry.key;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        width: isActive ? 40 : 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(
                                  colors: [
                                    widget.pages[_currentPage].accentColor,
                                    widget.pages[_currentPage].accentColor
                                        .withOpacity(0.6),
                                  ],
                                )
                              : null,
                          color: !isActive
                              ? widget.pages[_currentPage].textColor
                                  .withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: widget
                                        .pages[_currentPage].accentColor
                                        .withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Boutons d'action modernes
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: isLastPage
                      ? _PremiumStartButton(
                          onPressed: () {
                            widget.onFinish?.call();
                          },
                          bgColor: widget.pages[_currentPage].accentColor,
                          textColor: Colors.white,
                        )
                      : _PremiumNextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _currentPage + 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          textColor: widget.pages[_currentPage].textColor,
                          accentColor: widget.pages[_currentPage].accentColor,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.location_city_rounded;
      case 1:
        return Icons.directions_car_rounded;
      case 2:
        return Icons.local_parking_rounded;
      case 3:
        return Icons.shield_rounded;
      case 4:
        return Icons.people_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}

// Bouton Skip moderne
class _ModernSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color textColor;
  final Color accentColor;

  const _ModernSkipButton({
    required this.onPressed,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: textColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aloha',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                color: textColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bouton Suivant premium
class _PremiumNextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color textColor;
  final Color accentColor;

  const _PremiumNextButton({
    required this.onPressed,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<_PremiumNextButton> createState() => _PremiumNextButtonState();
}

class _PremiumNextButtonState extends State<_PremiumNextButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor.withOpacity(0.2),
                widget.accentColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Manaraka',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: widget.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.textColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bouton Commencer premium
class _PremiumStartButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color bgColor;
  final Color textColor;

  const _PremiumStartButton({
    required this.onPressed,
    required this.bgColor,
    required this.textColor,
  });

  @override
  State<_PremiumStartButton> createState() => _PremiumStartButtonState();
}

class _PremiumStartButtonState extends State<_PremiumStartButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = 1.0 + (_pulseController.value * 0.03);
          return Transform.scale(
            scale: _isPressed ? 0.96 : pulse,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.bgColor,
                    widget.bgColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.bgColor.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: widget.bgColor.withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 10,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Anomboka',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: widget.textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.textColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                    Icons.play_arrow_rounded,

                      color: widget.textColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String imagePath;
  final Color bgColor;
  final Color accentColor;
  final Color textColor;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.bgColor,
    required this.accentColor,
    this.textColor = Colors.white,
  });
}
