import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monitoring_maintenance/screen/login_page.dart';
import 'package:monitoring_maintenance/services/supabase_service.dart';
import 'package:monitoring_maintenance/providers/auth_provider.dart';
import 'package:monitoring_maintenance/utils/route_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Monitoring Maintenance Mesin',
      // Konfigurasi locale untuk mendukung MaterialLocalizations
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris (fallback)
      ],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A9C5D),
          secondary: Color(0xFF022415),
        ),
        useMaterial3: true,
      ),
      home: authState.isAuthenticated
          ? RouteHelper.getDashboardByRole(authState.userRole)
          : const LoginPage(),
    );
  }
}