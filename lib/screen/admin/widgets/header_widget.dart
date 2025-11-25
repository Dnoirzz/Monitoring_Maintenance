import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final Widget? trailing;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.onMenuPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A9C5D), Color(0xFF022415)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left side - Menu and Title
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: onMenuPressed,
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Center - Company Name
          Text(
            "PT. NEW KALBAR PROCESSORS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          // Right side - Avatar
          Align(
            alignment: Alignment.centerRight,
            child:
                trailing ??
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF0A9C5D)),
                ),
          ),
        ],
      ),
    );
  }
}