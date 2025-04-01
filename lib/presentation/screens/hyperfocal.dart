import 'package:flutter/material.dart';

class HyperfocalScreen extends StatefulWidget {
  const HyperfocalScreen({super.key});

  @override
  State<HyperfocalScreen> createState() => _HyperfocalScreenState();
}

class _HyperfocalScreenState extends State<HyperfocalScreen> {

  double? selectedAperture;
  final TextEditingController focalController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const List<double> apertures = [
      1.4, 1.8, 2.0, 2.8, 3.5, 4.0, 5.6, 6.3, 7.1, 8.0, 9.0,
      11.0, 13.0, 14.0, 16.0, 18.0, 20.0, 22.0,
    ];

    // FUNCIONES
    // Calcular la distancia hiperfocal
    double calculateHyperfocal(double focalLength, double aperture) {
      const double c = 0.019; // círculo de confusión para Canon APS-C en mm
      double h = (focalLength * focalLength) / (aperture * c) + focalLength; // en mm
      return h / 1000; // convertir a metros
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Hiperfocal', style: TextStyle(color: Colors.white60)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, // ← Asegura que ocupe todo
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
        child: SingleChildScrollView( // ← permite expandir si se necesita
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  margin: EdgeInsets.only(top: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.center_focus_strong, color: Colors.black54),
                            SizedBox(width: 8),
                            Text(
                              '¿Qué es la distancia hiperfocal?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'La distancia hiperfocal es el punto más cercano al que puedes enfocar '
                          'de forma que todo lo que esté desde la mitad de esa distancia hasta el infinito '
                          'quede aceptablemente nítido.\n\n'
                          'Es la clave para obtener la mayor profundidad de campo posible.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Para calcularla necesitas:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('• La distancia focal del objetivo (en milímetros)'),
                        const Text('• La apertura de diafragma (valor f/)'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distancia focal (mm)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: focalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {}); // para actualizar la hiperfocal
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apertura (f/)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<double>(
                      value: selectedAperture,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: apertures.map((ap) {
                        return DropdownMenuItem(
                          value: ap,
                          child: Text('f/${ap.toStringAsFixed(1)}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAperture = value;
                        });
                      },
                    ),
                  ],
                ),

                if (selectedAperture != null && focalController.text.isNotEmpty)
                  Builder(
                    builder: (_) {
                      final focal = double.tryParse(focalController.text);
                      if (focal == null) return const SizedBox.shrink();

                      final hiperfocal = calculateHyperfocal(focal, selectedAperture!);
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Distancia hiperfocal: ${hiperfocal.toStringAsFixed(2)} m',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 50),

                  Text(
                    '* Válido para cámaras Canon M50 MarkII y Canon APS-C en general',
                    style: TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}