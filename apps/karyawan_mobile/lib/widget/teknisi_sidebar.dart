import 'package:flutter/material.dart';
import 'package:shared/utils/name_helper.dart';

/// Sidebar widget untuk aplikasi teknisi
///
/// Widget ini dapat digunakan di berbagai halaman untuk menampilkan
/// navigation drawer dengan menu-menu aplikasi teknisi.
class TeknisiSidebar extends StatelessWidget {
  /// Warna primary untuk tema aplikasi
  final Color primaryColor;

  /// Warna background card
  final Color cardColor;

  /// Warna text primary
  final Color textPrimary;

  /// Warna text secondary
  final Color textSecondary;

  /// Nama lengkap user
  final String? userFullName;

  /// Role/jabatan user (default: 'Teknisi')
  final String userRole;

  /// Callback ketika menu item diklik
  final Function(String menuTitle)? onMenuTap;

  /// Callback ketika logout diklik
  final VoidCallback? onLogout;

  const TeknisiSidebar({
    super.key,
    required this.primaryColor,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    this.userFullName,
    this.userRole = 'Teknisi',
    this.onMenuTap,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: cardColor,
      child: Column(
        children: [
          // User Profile Header
          _buildUserHeader(context),

          // Navigation Menu
          Expanded(child: _buildMenuList(context)),

          // Logout Button
          _buildLogoutButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build user profile header di bagian atas drawer
  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryColor,
              child: Text(
                NameHelper.getInitials(userFullName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userFullName ?? 'User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    userRole,
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build list menu navigasi
  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      _MenuItemData(
        icon: Icons.dashboard,
        title: 'Dashboard',
        route: '/dashboard',
      ),
      _MenuItemData(
        icon: Icons.checklist,
        title: 'Cek Sheet',
        route: '/cek-sheet',
        children: [
          _MenuItemData(
            icon: Icons.factory,
            title: 'Mesin Produksi',
            route: '/cek-sheet/mesin-produksi',
          ),
          _MenuItemData(
            icon: Icons.construction,
            title: 'Alat Berat',
            route: '/cek-sheet/alat-berat',
          ),
          _MenuItemData(
            icon: Icons.electric_bolt,
            title: 'Listrik',
            route: '/cek-sheet/listrik',
          ),
        ],
      ),
      _MenuItemData(
        icon: Icons.calendar_month,
        title: 'Jadwal Maintenance',
        route: '/jadwal-maintenance',
        children: [
          _MenuItemData(
            icon: Icons.factory,
            title: 'Mesin Produksi',
            route: '/jadwal/mesin-produksi',
          ),
          _MenuItemData(
            icon: Icons.construction,
            title: 'Alat Berat',
            route: '/jadwal/alat-berat',
          ),
          _MenuItemData(
            icon: Icons.electric_bolt,
            title: 'Listrik',
            route: '/jadwal/listrik',
          ),
        ],
      ),
      _MenuItemData(
        icon: Icons.build,
        title: 'Maintenance Request',
        route: '/permintaan-maintenance',
      ),
      _MenuItemData(
        icon: Icons.precision_manufacturing,
        title: 'Assets List',
        route: '/detail-mesin',
        children: [
          _MenuItemData(
            icon: Icons.factory,
            title: 'Mesin Produksi',
            route: '/assets/mesin-produksi',
          ),
          _MenuItemData(
            icon: Icons.construction,
            title: 'Alat Berat',
            route: '/assets/alat-berat',
          ),
          _MenuItemData(
            icon: Icons.electric_bolt,
            title: 'Listrik',
            route: '/assets/listrik',
          ),
        ],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children:
          menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == 0; // Dashboard aktif by default

            if (item.children != null && item.children!.isNotEmpty) {
              return _buildExpandableMenuItem(context, item);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < menuItems.length - 1 ? 4 : 0,
              ),
              child: _MenuItem(
                icon: item.icon,
                title: item.title,
                isActive: isActive,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryColor: primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  if (item.route.isNotEmpty && !isActive) {
                    Navigator.pushNamed(context, item.route);
                  }
                  if (onMenuTap != null) {
                    onMenuTap!(item.title);
                  }
                },
              ),
            );
          }).toList(),
    );
  }

  Widget _buildExpandableMenuItem(BuildContext context, _MenuItemData item) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(item.icon, color: textSecondary),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        iconColor: primaryColor,
        collapsedIconColor: textSecondary,
        childrenPadding: const EdgeInsets.only(left: 16),
        children:
            item.children!.map((child) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _MenuItem(
                  icon: child.icon,
                  title: child.title,
                  isActive: false,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    if (child.route.isNotEmpty) {
                      Navigator.pushNamed(context, child.route);
                    }
                    if (onMenuTap != null) {
                      onMenuTap!(child.title);
                    }
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  /// Build logout button di bagian bawah drawer
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (onLogout != null) {
            onLogout!();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.red.withOpacity(0.1),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class untuk menu item
class _MenuItemData {
  final IconData icon;
  final String title;
  final String route;
  final List<_MenuItemData>? children;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.route,
    this.children,
  });
}

/// Widget untuk individual menu item
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive ? primaryColor.withOpacity(0.15) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? primaryColor : textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? primaryColor : textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
