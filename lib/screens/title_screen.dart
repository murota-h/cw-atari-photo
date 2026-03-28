import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'camera_screen.dart';
import 'help_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openGallery() async {
    // iOS: photos-redirect://  Android: content URI for images
    final uri = Uri.parse(
      Theme.of(context).platform == TargetPlatform.iOS
          ? 'photos-redirect://'
          : 'content://media/external/images/media',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ギャラリーを開けませんでした')),
        );
      }
    }
  }

  void _start() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CameraScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      CustomPaint(painter: _GridPainter(), size: Size.infinite),
      Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF00D4FF).withAlpha(30),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
        color: const Color(0xFF00D4FF).withAlpha(20),
      ),
      child: const Icon(Icons.content_paste_search,
          color: Color(0xFF00D4FF), size: 36),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '一体型仕上げ組',
          style: TextStyle(
            color: const Color(0xFF00D4FF).withAlpha(200),
            fontSize: 14,
            letterSpacing: 6,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'CW当たり確認',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withAlpha(150),
                ]),
              ),
            ),
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF00D4FF), shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 60, height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFF00D4FF).withAlpha(150),
                  Colors.transparent,
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'TAG RENAMER',
          style: TextStyle(
            color: Colors.white.withAlpha(80),
            fontSize: 11,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _start,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
          gradient: LinearGradient(colors: [
            const Color(0xFF00D4FF).withAlpha(40),
            const Color(0xFF00D4FF).withAlpha(15),
          ]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('START',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                )),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios,
                color: const Color(0xFF00D4FF).withAlpha(200), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: _openGallery,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, color: Colors.white38, size: 18),
            SizedBox(width: 8),
            Text('ギャラリーで写真を確認',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  letterSpacing: 1,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPortrait() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _buildIcon(),
          const SizedBox(height: 28),
          _buildTitleBlock(),
          const Spacer(flex: 2),
          Opacity(opacity: _pulse.value, child: _buildStartButton()),
          const SizedBox(height: 12),
          Opacity(opacity: _pulse.value, child: _buildGalleryButton()),
          const Spacer(),
          Opacity(
            opacity: _pulse.value * 0.6,
            child: Text('Developer: H.Murota',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  letterSpacing: 2,
                )),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLandscape() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          // 左：アイコン＋タイトル
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                const SizedBox(height: 20),
                _buildTitleBlock(),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // 縦線区切り
          Container(
            width: 1,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withAlpha(100),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          // 右：ボタン群
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(opacity: _pulse.value, child: _buildStartButton()),
                const SizedBox(height: 12),
                Opacity(opacity: _pulse.value, child: _buildGalleryButton()),
                const SizedBox(height: 16),
                Opacity(
                  opacity: _pulse.value * 0.6,
                  child: Text('Developer: H.Murota',
                      style: TextStyle(
                        color: Colors.white.withAlpha(80),
                        fontSize: 11,
                        letterSpacing: 2,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: const Color(0xFF060D18),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideUp.value),
                  child: SizedBox.expand(
                    child: isLandscape ? _buildLandscape() : _buildPortrait(),
                  ),
                ),
              ),
            ),
          ),

          // ヘルプアイコン（右上）
          Positioned(
            top: 12,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                    color: Colors.white.withAlpha(15),
                  ),
                  child: const Icon(Icons.help_outline,
                      color: Colors.white38, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 背景グリッド描画
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withAlpha(15)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}