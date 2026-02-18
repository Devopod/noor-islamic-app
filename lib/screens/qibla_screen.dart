import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _qiblaDirection = 0.0;
  double _distanceKm = 0.0;
  bool _isCompassMode = true;
  bool _isLoading = true;
  String _locationName = 'Locating...';
  String? _errorMessage;

  static const double _meccaLat = 21.4225;
  static const double _meccaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fetchQiblaDirection();
  }

  Future<void> _fetchQiblaDirection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final url = Uri.parse(
        'https://api.aladhan.com/v1/qibla/${position.latitude}/${position.longitude}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final direction = (data['data']['direction'] as num).toDouble();
        final distance = _calculateDistance(
          position.latitude, position.longitude, _meccaLat, _meccaLng,
        );

        setState(() {
          _qiblaDirection = direction;
          _distanceKm = distance;
          _locationName = '${position.latitude.toStringAsFixed(2)}\u00b0N, ${position.longitude.toStringAsFixed(2)}\u00b0E';
          _isLoading = false;
          _animation = Tween<double>(begin: 0, end: _qiblaDirection).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          );
        });
        _controller.forward(from: 0);
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch Qibla direction';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString().length > 60 ? e.toString().substring(0, 60) : e}';
        _isLoading = false;
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  String _getCardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  String _formatDistance(double km) {
    if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(1)}k km';
    }
    return '${km.toStringAsFixed(0)} km';
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
                Expanded(child: _buildBody()),
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
                    _locationName,
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
          GestureDetector(
            onTap: _fetchQiblaDirection,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(13),
              ),
              child: const Icon(Icons.refresh, color: Colors.white70, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Finding Qibla direction...',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[300], fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchQiblaDirection,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCompass();
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
    if (_isLoading || _errorMessage != null) {
      return const SizedBox(height: 80);
    }

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
                _getCardinalDirection(_qiblaDirection),
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
                TextSpan(
                  text: _formatDistance(_distanceKm),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
                  'GPS Accuracy',
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
