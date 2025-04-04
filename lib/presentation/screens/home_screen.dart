import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen en el centro
              SizedBox(
                height: 200,
                child: Image.asset('assets/images/canon_m50.png'),
              ),
              const SizedBox(height: 20),
              // Botón superior
              _buildIconButton(
                context,
                icon: Icons.center_focus_strong,
                label: 'Hyperfocal',
                onTap: () => context.push('/hyperfocal'),
              ),
              const SizedBox(height: 20),
              // Fila con los otros dos botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  _buildIconButton(
                    context,
                    icon: Icons.exposure,
                    label: 'Exposición',
                    onTap: () => context.push('/compensation'),
                  ),

                  _buildIconButton(
                    context,
                    icon: Icons.tonality,
                    label: 'Blancos',
                    onTap: () => context.push('/whitebalance'),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
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
        const SizedBox(height: 8),
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
