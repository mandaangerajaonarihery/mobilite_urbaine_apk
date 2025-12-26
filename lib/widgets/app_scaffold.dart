import 'package:flutter/material.dart';
import 'app_header.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBackButton = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: title, showBackButton: showBackButton),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
