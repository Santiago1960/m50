import 'package:animate_do/animate_do.dart';
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

    // Calcular la distancia hiperfocal para Canon APS-C
    double calculateHyperfocal(double focalLength, double aperture) {
      const double c = 0.019; // círculo de confusión para Canon APS-C en mm
      double h = (focalLength * focalLength) / (aperture * c) + focalLength; // en mm
      return h / 1000; // convertir a metros
    }

    // Calcular la distancia hiperfocal para Canon Full Frame
    double calculateHyperfocalFullFrame(double focalLength, double aperture) {
      const double c = 0.030; // círculo de confusión para Canon APS-C en mm
      double h = (focalLength * focalLength) / (aperture * c) + focalLength; // en mm
      return h / 1000; // convertir a metros
    }

    return ZoomIn(
      duration: Duration(milliseconds: 800),
      child: Scaffold(
        appBar: AppBar(
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/'),
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
                                    fontSize: 16,
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
          
                    const SizedBox(height: 15),
          
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
      
                        const SizedBox(height: 2),
      
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
      
                    const SizedBox(height: 15),
      
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
          
                        const SizedBox(height: 2),
          
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
                          final hiperfocalFullFrame = calculateHyperfocalFullFrame(focal, selectedAperture!);
                          return Column(
                            children: [
      
                              const SizedBox(height: 15),
      
                              const Text('Hyperfocal', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
      
                              const SizedBox(height: 5),
      
                              Table(
                                border: TableBorder.all(),
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(color: Colors.black54),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Center(
                                          child: Text(
                                            'M50 - APS-C',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Center(
                                          child: Text(
                                            '5D - FULL FRAME',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(child: Text('${hiperfocal.toStringAsFixed(2)} m.')),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(child: Text('${hiperfocalFullFrame.toStringAsFixed(2)} m.')),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
          
                    SizedBox(height: 30),
          
                    Text(
                      '* Válido para cámaras Canon con fomatos APS-C y Full Frame.',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}