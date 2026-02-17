import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double _qiblaDirection = 112.0;
  bool _isCompassMode = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: _qiblaDirection).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicPatternPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildCompass()),
                _buildInfoDisplay(),
                _buildToggle(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(13),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white70, size: 24),
            ),
          ),
          Column(
            children: [
              const Text(
                'Qibla Finder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppTheme.primary.withAlpha(200)),
                  const SizedBox(width: 4),
                  Text(
                    'Istanbul, TR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(13),
            ),
            child: const Icon(Icons.settings, color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.surfaceLight.withAlpha(76),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(13),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(13),
                      width: 1,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -25 * pi / 180,
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(25),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                          ),
                        ),
                        const Positioned(
                          top: 16,
                          child: Text('N', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const Positioned(
                          bottom: 16,
                          child: Text('S', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const Positioned(
                          right: 16,
                          child: Text('E', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const Positioned(
                          left: 16,
                          child: Text('W', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Positioned(
                          top: 42,
                          right: 42,
                          child: Transform.rotate(
                            angle: 25 * pi / 180,
                            child: Icon(
                              Icons.mosque,
                              size: 28,
                              color: AppTheme.primary,
                              shadows: [
                                Shadow(
                                  color: AppTheme.primary.withAlpha(150),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F1A12).withAlpha(200),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 1,
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withAlpha(13),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        width: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withAlpha(13),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: _animation.value * pi / 180,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 24,
                          child: Container(
                            width: 8,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.secondary,
                                  AppTheme.secondary.withAlpha(200),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withAlpha(100),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          child: Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF232010),
                              border: Border.all(color: AppTheme.secondary, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withAlpha(75),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_qiblaDirection.toInt()}',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: -3,
                ),
              ),
              Text(
                '°',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Mecca is ',
                  style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 14),
                ),
                const TextSpan(
                  text: '2,145 km',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' away',
                  style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withAlpha(76),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(13)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: AppTheme.textSecondary.withAlpha(200)),
                const SizedBox(width: 4),
                Text(
                  'Excellent Accuracy',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A12).withAlpha(128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCompassMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isCompassMode ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isCompassMode
                      ? [BoxShadow(color: AppTheme.primary.withAlpha(75), blurRadius: 8)]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.explore,
                      size: 16,
                      color: _isCompassMode ? AppTheme.backgroundDark : Colors.white.withAlpha(128),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Compass',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isCompassMode ? AppTheme.backgroundDark : Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCompassMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isCompassMode ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 16,
                      color: !_isCompassMode ? AppTheme.backgroundDark : Colors.white.withAlpha(128),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Map',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: !_isCompassMode ? AppTheme.backgroundDark : Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(
          Offset(x + spacing / 2, y),
          Offset(x + spacing, y + spacing / 2),
          paint,
        );
        canvas.drawLine(
          Offset(x + spacing, y + spacing / 2),
          Offset(x + spacing / 2, y + spacing),
          paint,
        );
        canvas.drawLine(
          Offset(x + spacing / 2, y + spacing),
          Offset(x, y + spacing / 2),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + spacing / 2),
          Offset(x + spacing / 2, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
