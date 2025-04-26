import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import 'package:m50/presentation/ads/ad_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double radius = 130;
    final Offset center = Offset(screenSize.width / 2, screenSize.height / 2 - 60);

    final List<_RadialIconData> icons = [
      _RadialIconData(icon: Icons.center_focus_strong, label: 'Hyperfocal', angle: 0, route: '/hyperfocal'),
      _RadialIconData(icon: Icons.blur_on, label: 'DoF', angle: 45, route: '/dof'),
      _RadialIconData(icon: Icons.exposure, label: 'Exposición', angle: 90, route: '/compensation'),
      _RadialIconData(icon: Icons.tonality, label: 'Blancos', angle: 135, route: '/whitebalance'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'M50',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade600,
                  Colors.grey.shade300,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Círculo guía sutil
          Positioned(
            left: center.dx - radius,
            top: center.dy - radius,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 1),
              ),
            ),
          ),

          // Íconos distribuidos alrededor del círculo
          ...icons.map((data) {
            final double rad = data.angle * pi / 180;
            final Offset pos = Offset(
              center.dx + radius * cos(rad) - 30,
              center.dy + radius * sin(rad) - 30,
            );

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: _buildIconButton(context,
                  icon: data.icon, label: data.label, onTap: () {
                    AdManager.showInterstitial(
                      onFinish: () {
                        // Navegar a la ruta correspondiente
                        AdManager.loadInterstitial();
                        context.push(data.route);
                      },
                    );
                  }
              ),
            );
          }),

          // Imagen de la cámara en el centro
          Positioned(
            left: center.dx - 50,
            top: center.dy - 50,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('assets/images/canon_m50.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        )
      ],
    );
  }
}

class _RadialIconData {
  final IconData icon;
  final String label;
  final double angle; // en grados
  final String route;

  _RadialIconData({
    required this.icon,
    required this.label,
    required this.angle,
    required this.route,
  });
}