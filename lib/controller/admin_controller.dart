class AdminController {
  int selectedIndex = 0;
  int? selectedScheduleSubMenu; // null, 31 (Maintenance), 32 (Cek Sheet)
  bool isSidebarOpen = false;
  bool isScheduleExpanded = false;

  void toggleSidebar() {
    isSidebarOpen = !isSidebarOpen;
  }

  void handleMenuSelected(int index) {
    selectedIndex = index;
    if (index == 3) {
      // Untuk Schedule, expand dropdown
      isScheduleExpanded = true;
      selectedScheduleSubMenu = null;
    } else if (index == 4) {
      // Logout action - handled in dashboard_admin.dart
    } else {
      toggleSidebar();
    }
  }

  void handleSubMenuSelected(int index) {
    selectedIndex = 3;
    selectedScheduleSubMenu = index;
    toggleSidebar();
  }

  void toggleSchedule() {
    isScheduleExpanded = !isScheduleExpanded;
  }

  void navigateToDataMesin() {
    selectedIndex = 1;
  }

  void navigateToKaryawan() {
    selectedIndex = 2;
  }

  void navigateToMaintenanceSchedule() {
    selectedIndex = 3;
    selectedScheduleSubMenu = 31;
  }

  void navigateToCekSheetSchedule() {
    selectedIndex = 3;
    selectedScheduleSubMenu = 32;
  }
}

