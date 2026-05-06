import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/brief_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BriefProvider(),
      child: const ClientBriefApp(),
    ),
  );
}

class ClientBriefApp extends StatelessWidget {
  const ClientBriefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brief Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
