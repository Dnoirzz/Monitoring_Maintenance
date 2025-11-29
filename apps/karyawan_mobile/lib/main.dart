import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/supabase_service.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/utils/route_helper.dart';
import 'screen/login_page.dart';
import 'screen/teknisi/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const ProviderScope(child: KaryawanMobileApp()));
}

class KaryawanMobileApp extends ConsumerWidget {
  const KaryawanMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Maintenance',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
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
      home: authState.isAuthenticated && RouteHelper.isTeknisiRole(authState.userRole)
          ? const TeknisiDashboardPage()
          : const LoginPage(),
    );
  }
}


