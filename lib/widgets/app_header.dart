import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:all_pnud/l10n/app_localizations.dart';
import 'package:all_pnud/providers/theme_provider.dart';
import 'package:all_pnud/providers/locale_provider.dart';
import 'package:all_pnud/providers/auth_provider.dart';
import 'package:all_pnud/providers/notification_provider.dart';
import 'package:badges/badges.dart' as badges; // ⚠️ ajouter le package badges: ^2.0.3

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final loc = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 40,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.apps),
          ),
          const SizedBox(width: 10),
          if (title != null) ...[
            const SizedBox(width: 12),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // 🌍 Sélecteur de langue
        PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          onSelected: (locale) => localeProvider.setLocale(locale),
          itemBuilder: (_) => [
            PopupMenuItem(value: const Locale('fr'), child: Text(loc.languageFr)),
            PopupMenuItem(value: const Locale('en'), child: Text(loc.languageMg)),
          ],
        ),

        // 🌙 Toggle thème
        IconButton(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: themeProvider.themeMode == ThemeMode.dark ? loc.lightMode : loc.darkMode,
        ),

        // 🔔 Notifications
        Consumer2<AuthProvider, NotificationProvider>(
          builder: (context, auth, notif, _) {
            if (!auth.isLoggedIn) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                showBadge: notif.count > 0,
                badgeContent: Text(
                  notif.count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                 onPressed: () {
  showDialog(
    context: context,
    builder: (_) {
      final notifications = notif.notifications;
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              if (notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucune notification"),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notifItem = notifications[index];
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(notifItem['type'] ?? "Notification"),
                        subtitle: Text(notifItem['data'].toString()),
                        trailing: notifItem['read'] == true
                            ? null
                            : const Icon(Icons.circle, color: Colors.red, size: 10),
                        onTap: () {
                          // Marquer comme lu ou autre action
                          notif.markAllAsRead();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
},

                ),
              ),
            );
          },
        ),

        // 👤 Bouton Connexion / Déconnexion
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isLoggedIn) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<int>(
                tooltip: "Profil",
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userPseudo ?? "Utilisateur",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.userEmail ?? "",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Se déconnecter"),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 1) {
                    FocusScope.of(context).unfocus();
                    await auth.logout();
                    if (context.mounted) {
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Déconnexion réussie"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      GoRouter.of(context).go('/apk_pnud');
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.black),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
