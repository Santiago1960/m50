import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/pickers/widgets.dart';

class HyperfocalScreen extends StatefulWidget {
  const HyperfocalScreen({super.key});

  @override
  State<HyperfocalScreen> createState() => _HyperfocalScreenState();
}

class _HyperfocalScreenState extends State<HyperfocalScreen> {

  double? selectedAperture = 5.6;
  final TextEditingController focalController = TextEditingController();
  final TextEditingController apertureController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focalController.dispose();
    apertureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const List<double> apertures = [
      22.0, 20.0, 18.0, 16.0, 14.0, 13.0,
      11.0, 10.0, 9.0, 8.0, 7.1, 6.3, 5.6,
      5.0, 4.5, 4.0, 3.5, 3.2, 2.8, 2.5,
      2.2, 2.0, 1.8, 1.4
    ];

    // FUNCIONES

    void showAperturePicker() {
      // Cierra el teclado primero
      FocusScope.of(context).unfocus();

      // Luego muestra el picker sin async
      ExposurePickers.showAperturePicker(
        context: context,
        apertures: apertures,
        selectedAperture: selectedAperture,
        onSelected: (value) {
          if (!mounted) return;

          setState(() {
            selectedAperture = value;
            apertureController.text = 'f/$value';
          });
        },
      );
    }

    // Calcular la distancia hiperfocal
    double calculateHyperfocal(double focalLength, double aperture) {
      const double c = 0.019; // círculo de confusión para Canon APS-C en mm
      double h = (focalLength * focalLength) / (aperture * c) + focalLength; // en mm
      return h / 1000; // convertir a metros
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
        centerTitle: true,
        title: const Text('Hiperfocal', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)), // ← redondeado
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.black),
                            ),
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
        
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).isFirstFocus
                              ? FocusScope.of(context).unfocus()
                              : FocusScope.of(context).requestFocus(FocusNode());
                                showAperturePicker();
                        },
                                          
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            controller: apertureController,
                          ),
                        ),
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
      ),
    );
  }
}