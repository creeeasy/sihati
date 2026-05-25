import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({Key? key}) : super(key: key);

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
                    const Text(
                      'Créer un compte',
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
                      'Remplissez les informations ci-dessous',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Full name
                    _InputField(
                      controller: controller.fullNameController,
                      hint: 'Ex: Ahmed Benali',
                      prefixIcon: SvgPicture.asset(
                        AppIcons.profile,
                        width: AppSpacing.iconSizeSm,
                        height: AppSpacing.iconSizeSm,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Email
                    _InputField(
                      controller: controller.emailController,
                      hint: 'exemple@email.com',
                      prefixIcon: SvgPicture.asset(
                        AppIcons.notification,
                        width: AppSpacing.iconSizeSm,
                        height: AppSpacing.iconSizeSm,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Phone
                    _InputField(
                      controller: controller.phoneController,
                      hint: '0555123456',
                      prefixIcon: SvgPicture.asset(
                        AppIcons.phone,
                        width: AppSpacing.iconSizeSm,
                        height: AppSpacing.iconSizeSm,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 🆕 Carte Chifa Number
                    _ChifaInputField(controller: controller),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    Obx(() => _InputField(
                          controller: controller.passwordController,
                          hint: 'Au moins 8 caractères',
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
                    const SizedBox(height: AppSpacing.md),

                    // Confirm password
                    Obx(() => _InputField(
                          controller: controller.confirmPasswordController,
                          hint: 'Re-entrez votre mot de passe',
                          prefixIcon: SvgPicture.asset(
                            AppIcons.lock,
                            width: AppSpacing.iconSizeSm,
                            height: AppSpacing.iconSizeSm,
                            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          ),
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                        )),

                    // Terms checkbox
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: controller.acceptTerms.value,
                                onChanged: (value) {
                                  controller.acceptTerms.value = value ?? false;
                                },
                                activeColor: AppColors.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'J\'accepte les ',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Conditions d\'utilisation',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: ' et la '),
                                        TextSpan(
                                          text: 'Politique de confidentialité',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: AppSpacing.xl),

                    // Register button
                    Obx(() => _RegisterButton(
                          isLoading: controller.isLoading.value,
                          onPressed: controller.register,
                        )),

                    const SizedBox(height: AppSpacing.lg),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.goToLogin,
                          child: const Text(
                            'Se connecter',
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
// HEADER — wave + Lottie DNA + SIHATI wordmark
// ═══════════════════════════════════════════════════════════════

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _wordmarkFade;
  late final Animation<double> _wordmarkSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _wordmarkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.88, curve: Curves.easeOut),
      ),
    );
    _wordmarkSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.88, curve: Curves.easeOut),
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
      height: 180,
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
            top: -40,
            right: -30,
            child: _Circle(size: 140, opacity: 0.08),
          ),
          const Positioned(
            top: 60,
            left: -20,
            child: _Circle(size: 90, opacity: 0.06),
          ),
          const Positioned(
            bottom: 20,
            right: 60,
            child: _Circle(
                size: 60, opacity: 0.10, color: Color(0xFF64FFDA)),
          ),

          // Wave
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 30),
              painter: _WavePainter(),
            ),
          ),

          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.arrowBack,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Lottie DNA
                Lottie.asset(
                  'assets/animations/sihati_dna.json',
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  repeat: false,
                ),

                const SizedBox(height: 8),

                // SIHATI wordmark
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
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 5,
                          height: 1,
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
// CHIFA INPUT FIELD (New)
// ═══════════════════════════════════════════════════════════════

class _ChifaInputField extends StatelessWidget {
  final RegisterController controller;

  const _ChifaInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Numéro Carte Chifa',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Carte nationale de sécurité sociale (Optionnel)',
              child: SvgPicture.asset(
                AppIcons.info,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: AppColors.shadowSm,
          ),
          child: TextField(
            controller: controller.chifaNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
              _ChifaNumberFormatter(),
            ],
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '123 456 789 012 34',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textTertiary,
                fontSize: 15,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(9),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.qrCode,
                      width: 17,
                      height: 17,
                      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
              suffixIcon: Obx(() {
                if (controller.chifaText.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return controller.isChifaValid.value
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          AppIcons.verified,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(AppColors.success, BlendMode.srcIn),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          AppIcons.errorIcon,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
                        ),
                      );
              }),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          if (controller.chifaText.value.isEmpty) {
            return const Text(
              'Optionnel - Vous pourrez l\'ajouter plus tard',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            );
          }
          return controller.isChifaValid.value
              ? Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.verified,
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(AppColors.success, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Numéro valide',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.errorIcon,
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Format invalide (13-15 chiffres)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                );
        }),
      ],
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
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
            padding: const EdgeInsets.all(9),
            child: Container(
              width: 36,
              height: 36,
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
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REGISTER BUTTON
// ═══════════════════════════════════════════════════════════════

class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _RegisterButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17),
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
                      "S'inscrire",
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
// CHIFA NUMBER FORMATTER
// ═══════════════════════════════════════════════════════════════

class _ChifaNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.isEmpty) {
      return newValue;
    }

    // Add space every 3 digits
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += ' ';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
