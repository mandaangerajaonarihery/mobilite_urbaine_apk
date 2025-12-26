import 'package:flutter/material.dart';

/// Footer simple et réutilisable.
///
/// - [year] : année affichée (par défaut année courante)
/// - [companyName] : nom de la société / app
/// - [onPrivacyTap] : callback quand on clique "Politique de confidentialité"
/// - [onTermsTap] : callback quand on clique "Conditions d'utilisation"
class FooterWidget extends StatelessWidget {
  final int year;
  final String companyName;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onTermsTap;
  final TextStyle? textStyle;
  final double spacing;

  FooterWidget({ // ✅ retiré `const` ici
    Key? key,
    int? year,
    this.companyName = 'I-zotra',
    this.onPrivacyTap,
    this.onTermsTap,
    this.textStyle,
    this.spacing = 12.0,
  })  : year = year ?? DateTime.now().year,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = textStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        );

    return Semantics(
      container: true,
      label: 'Pied de page',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;
            return isNarrow
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '© $year $companyName. Tous droits réservés.',
                        textAlign: TextAlign.center,
                        style: defaultStyle,
                      ),
                      
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '© $year $companyName. Tous droits réservés.',
                          textAlign: TextAlign.center,
                          style: defaultStyle,
                        ),
                      ),
                    
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _linkButton(
    BuildContext context,
    String label,
    VoidCallback? onTap,
    TextStyle? style,
  ) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: style?.copyWith(
          color: style?.color?.withOpacity(0.9),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _separator() {
    return const SizedBox(
      width: 1,
      height: 16,
      child: VerticalDivider(thickness: 1, width: 1),
    );
  }
}
