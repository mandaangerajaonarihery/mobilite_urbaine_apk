import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrivAuthWebView extends StatefulWidget {
  final String authType; // 'login', 'register', 'forgot-password', 'reset-password'
  final String redirectUrl;

  const CrivAuthWebView({
    Key? key,
    required this.authType,
    required this.redirectUrl,
  }) : super(key: key);

  @override
  State<CrivAuthWebView> createState() => _CrivAuthWebViewState();
}

class _CrivAuthWebViewState extends State<CrivAuthWebView> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    String baseUrl = 'https://criv.tsirylab.com/${widget.authType}';
    String fullUrl = '$baseUrl?redirect=${Uri.encodeComponent(widget.redirectUrl)}';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(fullUrl)),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              await _checkForToken(url.toString());
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              String url = navigationAction.request.url.toString();
              
              if (url.startsWith(widget.redirectUrl)) {
                await _checkForToken(url);
                return NavigationActionPolicy.CANCEL;
              }
              
              return NavigationActionPolicy.ALLOW;
            },
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              javaScriptEnabled: true,
              supportZoom: false,
            ),
          ),
          if (_isLoading)
            Container(
              color: theme.colorScheme.background,
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkForToken(String url) async {
    Uri uri = Uri.parse(url);
    String? token = uri.queryParameters['token'];
    
    if (token != null && token.isNotEmpty) {
      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      
      // Retourner à l'écran précédent avec le token
      if (mounted) {
        Navigator.pop(context, token);
      }
    }
  }

  String _getTitle() {
    switch (widget.authType) {
      case 'login':
        return 'Connexion';
      case 'register':
        return 'Inscription';
      case 'forgot-password':
        return 'Mot de passe oublié';
      case 'reset-password':
        return 'Réinitialisation';
      default:
        return 'Authentification';
    }
  }
}
