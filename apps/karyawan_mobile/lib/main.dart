import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/supabase_service.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/utils/route_helper.dart';
import 'screen/login_page.dart';
import 'screen/teknisi/dashboard_page.dart';
import 'screen/teknisi/pages/mt_request.dart';
import 'screen/teknisi/pages/menu_assets/asset_list_page.dart';
import 'screen/teknisi/pages/maintenance_schedule_list_page.dart';
import 'screen/teknisi/pages/ceksheet_menu/cek_sheet_asset_list_page.dart';
import 'screen/teknisi/pages/ceksheet_menu/checksheet_history_page.dart';
import 'screen/teknisi/pages/work_order/work_order_page.dart';

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
      home:
          authState.isAuthenticated &&
                  RouteHelper.isTeknisiRole(authState.userRole)
              ? const TeknisiDashboardPage()
              : const LoginPage(),
      routes: {
        '/dashboard': (context) => const TeknisiDashboardPage(),
        '/permintaan-maintenance':
            (context) => const MaintenanceRequestListPage(),
        '/assets/mesin-produksi':
            (context) => const AssetListPage(
              title: 'Mesin Produksi',
              assetType: 'production_machine',
            ),
        '/assets/alat-berat':
            (context) => const AssetListPage(
              title: 'Alat Berat',
              assetType: 'heavy_equipment',
            ),
        '/assets/listrik':
            (context) =>
                const AssetListPage(title: 'Listrik', assetType: 'electrical'),
        '/jadwal/mesin-produksi':
            (context) => const MaintenanceScheduleListPage(
              title: 'Jadwal Mesin Produksi',
              assetType: 'production_machine',
            ),
        '/jadwal/alat-berat':
            (context) => const MaintenanceScheduleListPage(
              title: 'Jadwal Alat Berat',
              assetType: 'heavy_equipment',
            ),
        '/jadwal/listrik':
            (context) => const MaintenanceScheduleListPage(
              title: 'Jadwal Listrik',
              assetType: 'electrical',
            ),
        '/cek-sheet/mesin-produksi':
            (context) => const CekSheetAssetListPage(
              title: 'Mesin Produksi',
              assetType: 'production_machine',
            ),
        '/cek-sheet/alat-berat':
            (context) => const CekSheetAssetListPage(
              title: 'Alat Berat',
              assetType: 'heavy_equipment',
            ),
        '/cek-sheet/listrik':
            (context) => const CekSheetAssetListPage(
              title: 'Listrik',
              assetType: 'electrical',
            ),
        '/cek-sheet/history': (context) => const ChecksheetHistoryPage(),
        '/work-order': (context) => const WorkOrderPage(),
      },
    );
  }
}
