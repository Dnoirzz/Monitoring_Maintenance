/// Helper class untuk manipulasi nama dan greeting
class NameHelper {
  static String getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'User';
    }
    
    final nameParts = fullName.trim().split(' ');
    return nameParts.first;
  }

  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 19) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  static String getGreetingWithName(String? fullName) {
    final greeting = getTimeGreeting();
    final firstName = getFirstName(fullName);
    return '$greeting, $firstName';
  }

  static String getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'U';
    }
    
    final nameParts = fullName.trim().split(' ').where((part) => part.isNotEmpty).toList();
    
    if (nameParts.isEmpty) {
      return 'U';
    } else if (nameParts.length == 1) {
      // Jika hanya satu kata, ambil 2 karakter pertama
      return nameParts.first.substring(0, nameParts.first.length > 2 ? 2 : nameParts.first.length).toUpperCase();
    } else {
      // Jika lebih dari satu kata, ambil inisial dari kata pertama dan terakhir
      return (nameParts.first[0] + nameParts.last[0]).toUpperCase();
    }
  }
}

