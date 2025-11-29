import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/route_helper.dart';
import 'admin/dashboard_admin.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _gradientController;
  late AnimationController _waveController;
  late AnimationController _titleController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    // Animation for gradient (with reverse)
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.linear,
      ),
    );
    // Animation for wave (one direction only, no reverse)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.linear,
      ),
    );
    // Animation for title (fade in and slide up)
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _waveController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Login berhasil - navigasi ke dashboard admin
      if (mounted) {
        final authState = ref.read(authProvider);
        // Admin web hanya untuk role admin
        if (RouteHelper.isAdminRole(authState.userRole)) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminTemplate()),
          );
        } else {
          // Jika bukan admin, tampilkan error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akses ditolak. Aplikasi ini hanya untuk admin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      // Tampilkan error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(e.message, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Error umum
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Login gagal. Silakan coba lagi.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_gradientAnimation, _waveAnimation]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFF0A9C5D),
                    const Color(0xFF0D7A4A),
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF022415),
                    const Color(0xFF033A1F),
                    _gradientAnimation.value,
                  )!,
                ],
                begin: Alignment.lerp(
                  Alignment.topLeft,
                  Alignment.topRight,
                  _gradientAnimation.value,
                )!,
                end: Alignment.lerp(
                  Alignment.bottomRight,
                  Alignment.bottomLeft,
                  _gradientAnimation.value,
                )!,
              ),
            ),
            child: Stack(
              children: [
                // Animated wave effect (one direction only)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(_waveAnimation.value),
                  ),
                ),
                child!,
              ],
            ),
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Header - Icon and Company Name (Top Left)
              Positioned(
                top: 16,
                left: 24,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icon/NKP.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'PT. New Kalbar Processors',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Layout - Split Screen
              Row(
                children: [
                  // Left side - Title in center with animation
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: AnimatedBuilder(
                          animation: _titleController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _titleFadeAnimation,
                              child: SlideTransition(
                                position: _titleSlideAnimation,
                                child: const Text(
                                  'Aplikasi Monitoring\nMaintenance Mesin',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Right side - Login Form (White Layout - Half Screen)
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Welcome Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selamat Datang',
                                      style: TextStyle(
                                        color: Color(0xFF022415),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Masuk ke akun admin Anda',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 48),
                                // Email Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _LoginTextField(
                                      controller: _emailController,
                                      hintText: 'Masukkan email Anda',
                                      textInputType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email_outlined,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Email harus diisi';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Format email tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Password Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _LoginTextField(
                                      controller: _passwordController,
                                      hintText: 'Masukkan password Anda',
                                      obscureText: _obscurePassword,
                                      prefixIcon: Icons.lock_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password harus diisi';
                                        }
                                        if (value.length < 6) {
                                          return 'Password minimal 6 karakter';
                                        }
                                        return null;
                                      },
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                // Login Button
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A9C5D),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      shadowColor: const Color(0xFF0A9C5D).withOpacity(0.3),
                                    ),
                                    onPressed: isLoading ? null : _handleLogin,
                                    child: isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                        : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Masuk',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 20),
                                          ],
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Wave Animation
class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // First wave - smooth continuous animation
    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 1.2; // Longer wavelength for smoother movement
    final baseY = size.height * 0.7;
    // Wave moves from left to right continuously
    final waveOffset = animationValue * 2 * math.pi;

    // Start path from left edge
    final startY = baseY + waveHeight * math.sin(waveOffset);
    path.moveTo(0, startY);

    // Create smooth continuous wave with many points
    final segments = 120; // More segments for smoother curve
    for (int i = 1; i <= segments; i++) {
      final x = (size.width / segments) * i;
      final y = baseY + waveHeight * math.sin((x / waveLength * 2 * math.pi) + waveOffset);
      path.lineTo(x, y);
    }

    // Close path to bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave - same calculation as first wave (no gap on loop)
    final path2 = Path();
    final baseY2 = size.height * 0.8;
    // Use same wavelength as first wave for seamless animation
    final waveLength2 = size.width / 1.2; // Same as first wave
    // Use same offset calculation, but opposite direction for visual interest
    final waveOffset2 = -animationValue * 2 * math.pi; // Opposite direction, same calculation

    // Start path from left edge
    final startY2 = baseY2 + waveHeight * 0.7 * math.sin(waveOffset2);
    path2.moveTo(0, startY2);

    final segments2 = 120; // Same number of segments
    for (int i = 1; i <= segments2; i++) {
      final x = (size.width / segments2) * i;
      // Same phase calculation as first wave
      final y = baseY2 + 
          waveHeight * 0.7 * 
          math.sin((x / waveLength2 * 2 * math.pi) + waveOffset2);
      path2.lineTo(x, y);
    }

    // Close path to bottom
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    this.textInputType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? textInputType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.grey.shade600,
                size: 20,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A9C5D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF022415),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

