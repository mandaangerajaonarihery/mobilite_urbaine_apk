import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:all_pnud/providers/auth_provider.dart';
import 'package:all_pnud/l10n/app_localizations.dart';
import 'package:all_pnud/widgets/app_scaffold.dart';
import 'package:all_pnud/widgets/criv_auth_webview.dart'; // Ajoutez cette ligne

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({Key? key}) : super(key: key);

  @override
  _ModernLoginScreenState createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // URL de redirection - adaptez selon votre configuration
  static const String _redirectUrl = 'myapp://auth';


  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success && mounted) {
        context.goNamed('mobilite_urbaine');
      } else if (mounted) {
        _showSnackBar(AppLocalizations.of(context)!.loginFailed,
            Theme.of(context).colorScheme.error);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("${AppLocalizations.of(context)!.error}: $e",
            Theme.of(context).colorScheme.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Nouvelle méthode pour ouvrir le formulaire d'inscription CRIV
  Future<void> _openRegister() async {
    final token = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrivAuthWebView(
          authType: 'register',
          redirectUrl: _redirectUrl,
        ),
      ),
    );

    if (token != null && mounted) {
      // L'utilisateur s'est inscrit avec succès
      _showSnackBar(
        'Inscription réussie ! Vous pouvez maintenant vous connecter.',
        Theme.of(context).colorScheme.primary,
      );
    }
  }

  // Nouvelle méthode pour ouvrir le formulaire mot de passe oublié
  Future<void> _openForgotPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrivAuthWebView(
          authType: 'forgot-password',
          redirectUrl: _redirectUrl,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == theme.colorScheme.primary
                  ? Icons.check_circle
                  : Icons.error,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppScaffold(
      body: Stack(
        children: [
          _buildMinimalBackground(isDarkMode, theme),
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLoginContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalBackground(bool isDarkMode, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [theme.colorScheme.background, theme.colorScheme.surface]
              : [theme.colorScheme.background, theme.colorScheme.surfaceVariant],
        ),
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginHeader(context),
            const SizedBox(height: 40),
            _buildEmailField(context),
            const SizedBox(height: 24),
            _buildPasswordField(context),
            const SizedBox(height: 16), // Réduit de 32 à 16
            _buildForgotPasswordButton(context), // Nouveau
            const SizedBox(height: 24), // Réduit de 32 à 24
            _buildLoginButton(context),
            const SizedBox(height: 24), // Nouveau
            _buildRegisterButton(context), // Nouveau
            const SizedBox(height: 32),
            _buildDemoInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginHeader(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8)
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Icon(Icons.directions_transit_filled,
              size: 40, color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(height: 32),
        Text(
          localizations.loginWelcome,
          style: theme.textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.loginSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return TextFormField(
      controller: _emailController,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: localizations.emailLabel,
        prefixIcon: Icon(Icons.alternate_email_rounded,
            color: theme.colorScheme.primary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          (value == null || value.isEmpty) ? localizations.emailValidation : null,
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: localizations.passwordLabel,
        prefixIcon: Icon(Icons.lock_outline_rounded,
            color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? localizations.passwordValidation : null,
    );
  }

  // Nouveau widget pour le bouton "Mot de passe oublié"
  Widget _buildForgotPasswordButton(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _openForgotPassword,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          'Mot de passe oublié ?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? CircularProgressIndicator(
                color: theme.colorScheme.onPrimary, strokeWidth: 2.5)
            : Text(localizations.loginButton,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }

  // Nouveau widget pour le bouton "S'inscrire"
  Widget _buildRegisterButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _openRegister,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Créer un compte',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoInfo(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.demoInfo,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
