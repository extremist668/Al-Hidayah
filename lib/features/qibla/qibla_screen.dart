import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/qibla/qibla_calculator.dart';
import 'package:islamic_app/services/location_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCoordinatesAndQibla();
  }

  Future<void> _initCoordinatesAndQibla() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      double direction = QiblaCalculator.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _qiblaDirection = direction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Could not initialize coordinates: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qibla Finder',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error reading compass sensor.'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    double? direction = snapshot.data?.heading;

                    // If direction is null, the device does not support a compass sensor
                    if (direction == null) {
                      return const Center(
                        child: Text(
                          "Device does not have a compass sensor. Qibla calculations are offline but compass visualization is unavailable.",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // Calculate rotation to Kaaba
                    // Angle pointing to Mecca = (Qibla Bearing - Device Heading)
                    double qiblaAngle = _qiblaDirection ?? 0.0;
                    double angleToMecca = qiblaAngle - direction;

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Align the pointer with the top center marker.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Qibla Bearing: ${qiblaAngle.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryEmerald,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Compass Dial Widget
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Compass Background
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryEmerald.withOpacity(0.2),
                                      width: 4,
                                    ),
                                    color: AppTheme.primaryEmerald.withOpacity(0.04),
                                  ),
                                ),
                                
                                // Rotating Pointer
                                Transform.rotate(
                                  angle: (angleToMecca * math.pi / 180) * -1,
                                  child: Image.network(
                                    'https://images.vexels.com/media/users/3/135118/isolated/preview/67b7e0ee1117be546cb7605d33682970-compass-arrow-concept.png',
                                    width: 180,
                                    height: 180,
                                    color: AppTheme.goldAccent,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.navigation,
                                      size: 140,
                                      color: AppTheme.primaryEmerald,
                                    ),
                                  ),
                                ),

                                // Static Mecca Target marker
                                const Positioned(
                                  top: 10,
                                  child: Icon(
                                    Icons.mosque,
                                    color: AppTheme.goldAccent,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Calibrating notice
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: AppTheme.goldAccent),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'To calibrate compass, wave your device in an 8-figure shape twice.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
