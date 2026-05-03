import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../app/theme/app_spacing.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Decorative circles ──────────────────────
              Positioned(
                top: -80,
                right: -100,
                child: _DecorativeCircle(size: 320, opacity: 0.06),
              ),
              Positioned(
                top: 60,
                right: -60,
                child: _DecorativeCircle(size: 200, opacity: 0.04),
              ),
              Positioned(
                bottom: -60,
                left: -80,
                child: _DecorativeCircle(size: 260, opacity: 0.06),
              ),
              Positioned(
                bottom: 120,
                left: -40,
                child: _DecorativeCircle(
                  size: 140,
                  opacity: 0.06,
                  color: const Color(0xFF64FFDA),
                ),
              ),
              Positioned(
                top: 160,
                left: 20,
                child: _DecorativeCircle(
                  size: 80,
                  opacity: 0.05,
                  color: const Color(0xFF64FFDA),
                ),
              ),

              // ── Main content ────────────────────────────
              SafeArea(
                child: _SplashContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SPLASH CONTENT — Lottie + coordinated slide-up animations
// ─────────────────────────────────────────────────────────────

class _SplashContent extends StatefulWidget {
  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _wordmarkFade;
  late final Animation<double> _wordmarkSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    // Wordmark slides up after DNA finishes (~1.3s = 59% of 2.2s)
    _wordmarkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.59, 0.78, curve: Curves.easeOut),
      ),
    );
    _wordmarkSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.59, 0.78, curve: Curves.easeOut),
      ),
    );

    // Tagline follows wordmark
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.68, 0.85, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.68, 0.85, curve: Curves.easeOut),
      ),
    );

    // Bottom elements fade in last
    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(flex: 3),

        // Lottie DNA — plays once, transparent bg
        Lottie.asset(
          'assets/animations/sihati_dna.json',
          width: 140,
          height: 140,
          fit: BoxFit.contain,
          repeat: false,
        ),

        const SizedBox(height: AppSpacing.lg),

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
                  fontFamily: 'Poppins',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 6,
                  height: 1,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

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
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.65),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const Spacer(flex: 3),

        // Spinner + version — fade in together last
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _bottomFade.value,
            child: Column(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.65),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DECORATIVE CIRCLE
// ─────────────────────────────────────────────────────────────

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _DecorativeCircle({
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
