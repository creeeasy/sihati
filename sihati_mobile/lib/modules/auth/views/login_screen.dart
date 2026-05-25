import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome text
                    const Text(
                      'Bienvenue',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Connectez-vous pour continuer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Email field
                    _InputField(
                      controller: controller.emailController,
                      hint: 'votre@email.com',
                      prefixIcon: SvgPicture.asset(
                          AppIcons.notification,
                          width: AppSpacing.iconSizeSm,
                          height: AppSpacing.iconSizeSm,
                          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                        ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password field
                    Obx(() => _InputField(
                          controller: controller.passwordController,
                          hint: '••••••••',
                          prefixIcon: SvgPicture.asset(
                            AppIcons.lock,
                            width: AppSpacing.iconSizeSm,
                            height: AppSpacing.iconSizeSm,
                            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          ),
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        )),

                    const SizedBox(height: AppSpacing.xl),

                    // Login button
                    Obx(() => _LoginButton(
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        )),

                    const SizedBox(height: AppSpacing.lg),

                    // 🆕 GUEST MODE BUTTON
                    _GuestButton(
                      onPressed: controller.continueAsGuest,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pas de compte ? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.goToRegister,
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HEADER — gradient + animated DNA + wordmark slide-up
// ═══════════════════════════════════════════════════════════════

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _wordmarkSlide;
  late final Animation<double> _wordmarkFade;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    // Wordmark slides up after DNA finishes (~1.3s mark)
    _wordmarkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );
    _wordmarkSlide = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );

    // Tagline slides up slightly after wordmark
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 0.95, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 0.95, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // Gradient bg
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E7BF6),
                    Color(0xFF1E5BC6),
                    Color(0xFF0D2460),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Decorative circles
          const Positioned(
            top: -50,
            right: -40,
            child: _Circle(size: 160, opacity: 0.08),
          ),
          const Positioned(
            top: 80,
            left: -30,
            child: _Circle(size: 100, opacity: 0.06),
          ),
          const Positioned(
            bottom: 35,
            right: 50,
            child: _Circle(size: 70, opacity: 0.10, color: Color(0xFF64FFDA)),
          ),

          // Wave at bottom
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 30),
              painter: _WavePainter(),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Lottie DNA animation — plays once, no bg
                Lottie.asset(
                  'assets/animations/sihati_dna.json',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  repeat: false,
                  delegates: LottieDelegates(
                    values: [
                      // Tint white strand to white (already white, safety)
                      ValueDelegate.color(
                        const ['strand_white', '**'],
                        value: Colors.white,
                      ),
                      // Tint teal strand
                      ValueDelegate.color(
                        const ['strand_teal', '**'],
                        value: const Color(0xFF00BFA5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // SIHATI wordmark — slides up after DNA
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => Opacity(
                    opacity: _wordmarkFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _wordmarkSlide.value),
                      child: const Text(
                        'SIHATI',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 5,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Tagline
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => Opacity(
                    opacity: _taglineFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _taglineSlide.value),
                      child: Text(
                        'Votre santé, notre priorité',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.70),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INPUT FIELD
// ═══════════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textTertiary,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: prefixIcon),
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md + 2,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LOGIN BUTTON
// ═══════════════════════════════════════════════════════════════

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Se connecter',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🆕 GUEST BUTTON
// ═══════════════════════════════════════════════════════════════

class _GuestButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GuestButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.search,
                  width: AppSpacing.iconSizeMd,
                  height: AppSpacing.iconSizeMd,
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continuer en tant qu\'invité',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TEST CREDENTIALS
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _Circle({
    required this.size,
    required this.opacity,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF9FAFB)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.8,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
