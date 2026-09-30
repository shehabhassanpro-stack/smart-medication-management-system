import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';


// ═══════════════════════════════════════════════════════════════════════════════
// 🏠 WELCOME SCREEN — Enterprise Grade Landing Page
// ═══════════════════════════════════════════════════════════════════════════════
//
// Design: Glassmorphism + layered animations + RTL Arabic
// Animations: Staggered entrance, floating particles, pulse CTA
// Navigation: → /login  |  → /register
//
// ═══════════════════════════════════════════════════════════════════════════════

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🎬 ANIMATION CONTROLLERS
  // ─────────────────────────────────────────────────────────────────────────

  late final AnimationController _masterController;
  late final AnimationController _particlesController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;

  // Staggered entrance animations
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _featuresFade;
  late final Animation<Offset> _featuresSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;

  // Continuous animations
  late final Animation<double> _particleAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _startAnimations();
  }

  void _initControllers() {
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void _initAnimations() {
    // ── Logo (0ms → 500ms)
    _logoFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOutCubic),
    ));

    // ── Title (250ms → 750ms)
    _titleFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.14, 0.42, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.14, 0.42, curve: Curves.easeOutCubic),
    ));

    // ── Features (600ms → 1200ms)
    _featuresFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.33, 0.67, curve: Curves.easeOut),
    );
    _featuresSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.33, 0.67, curve: Curves.easeOutCubic),
    ));

    // ── Buttons (900ms → 1500ms)
    _buttonsFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.5, 0.83, curve: Curves.easeOut),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.5, 0.83, curve: Curves.easeOutCubic),
    ));

    // ── Continuous
    _particleAnim = _particlesController;
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _masterController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Layer 1: Gradient background
            _buildBackground(),
            // Layer 2: Animated particles
            _buildParticles(),
            // Layer 3: Content
            _buildContent(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🌈 BACKGROUND
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D47A1), // deep navy
            Color(0xFF1565C0),
            Color(0xFF1976D2),
            Color(0xFF1E88E5),
            Color(0xFF42A5F5), // light blue
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✨ PARTICLES
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleAnim,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(_particleAnim.value),
          size: Size.infinite,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📄 CONTENT
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildFeaturesCard(),
                const SizedBox(height: 48),
                _buildButtons(),
                const SizedBox(height: 32),
                _buildFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏥 LOGO
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _logoFade,
      child: SlideTransition(
        position: _logoSlide,
        child: AnimatedBuilder(
          animation: _floatAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: child,
          ),
          child: Column(
            children: [
              // Glow ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // App name badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'MediCare Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 TITLE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _titleFade,
      child: SlideTransition(
        position: _titleSlide,
        child: Column(
          children: [
            const Text(
              'رعايتك\nأولويتنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'منصة طبية متكاملة تضع صحتك في مقدمة اهتماماتها\nمن المتابعة إلى التشخيص في مكان واحد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🃏 FEATURES GLASS CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFeaturesCard() {
    return FadeTransition(
      opacity: _featuresFade,
      child: SlideTransition(
        position: _featuresSlide,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: const [
              _FeatureRow(
                icon: Icons.monitor_heart_rounded,
                title: 'متابعة القراءات الصحية',
                subtitle: 'ضغط الدم، السكر، ودرجة الحرارة في لحظتها',
                delay: 0,
              ),
              SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.medication_rounded,
                title: 'إدارة الأدوية بذكاء',
                subtitle: 'جدولة وتذكير آلي لا يفوّت جرعة',
                delay: 1,
              ),
              SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.shield_rounded,
                title: 'سجل صحي آمن',
                subtitle: 'بياناتك محمية بتشفير من أعلى المعايير',
                delay: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 BUTTONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildButtons() {
    return FadeTransition(
      opacity: _buttonsFade,
      child: SlideTransition(
        position: _buttonsSlide,
        child: Column(
          children: [
            // Primary CTA — Login
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.white.withValues(alpha: 0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Secondary CTA — Register
            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔗 FOOTER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _buttonsFade,
      child: Text(
        '🔒  بياناتك آمنة ومشفّرة تمامًا',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🔹 FEATURE ROW WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.check_circle_rounded,
          color: Colors.white.withValues(alpha: 0.6),
          size: 18,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ✨ PARTICLE PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _ParticlePainter extends CustomPainter {
  final double animValue;
  static final _particles = _generateParticles();

  _ParticlePainter(this.animValue);

  static List<_Particle> _generateParticles() {
    final rng = math.Random(42);
    return List.generate(22, (i) => _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: 2.0 + rng.nextDouble() * 3.5,
      speed: 0.04 + rng.nextDouble() * 0.08,
      opacity: 0.06 + rng.nextDouble() * 0.14,
      phase: rng.nextDouble() * math.pi * 2,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.y + animValue * p.speed) % 1.0;
      final x = p.x + math.sin(animValue * math.pi * 2 + p.phase) * 0.02;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.animValue != animValue;
}

class _Particle {
  final double x, y, radius, speed, opacity, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}
