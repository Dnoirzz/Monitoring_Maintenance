import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/screen/login_page.dart';
import 'package:monitoring_maintenance/services/supabase_service.dart';
import 'package:monitoring_maintenance/screen/admin/dashboard_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Monitoring Maintenance Mesin',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A9C5D),
          secondary: Color(0xFF022415),
        ),
        useMaterial3: true,
      ),

      // home: SplashScreen(),
      // home: LoginPage(),
      home: AdminTemplate(),
    );
  }
}
