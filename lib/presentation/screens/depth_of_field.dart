import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/pickers/widgets.dart';

class DepthOfFieldScreen extends StatefulWidget {
  const DepthOfFieldScreen({super.key});

  @override
  State<DepthOfFieldScreen> createState() => _DepthOfFieldScreenState();
}

class _DepthOfFieldScreenState extends State<DepthOfFieldScreen> {
  double? selectedAperture = 5.6;
  final TextEditingController focalController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController apertureController = TextEditingController();

  @override
  void dispose() {
    focalController.dispose();
    distanceController.dispose();
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

    void showAperturePicker() {
      FocusScope.of(context).unfocus();
      ExposurePickers.showAperturePicker(
        context: context,
        apertures: apertures,
        selectedAperture: selectedAperture,
        onSelected: (value) {
          if (!mounted) return;
          setState(() {
            selectedAperture = value;
            apertureController.text = 'f/\$value';
          });
        },
      );
    }

    Map<String, double?> calculateDepthOfField({
      required double focalLength,
      required double aperture,
      required double subjectDistance,
      required double coc,
    }) {
      final f = focalLength;
      final N = aperture;
      final s = subjectDistance * 1000; // a mm
      final c = coc;

      final H = (f * f) / (N * c);

      final near = (H * s) / (H + (s - f));
      final far = s >= H ? double.infinity : (H * s) / (H - (s - f));

      final dof = far.isInfinite ? null : (far - near);

      return {
        'near': near / 1000,
        'far': far.isInfinite ? double.infinity : far / 1000,
        'dof': dof != null ? dof / 1000 : null,
      };
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
        title: const Text('Profundidad de Campo', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                'Profundidad de Campo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'La profundidad de campo es la porción de la imagen que aparece enfocada.\n'
                            '\nComprenderla te permite controlar qué elementos salen nítidos y cuáles no.',
                            style: TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Distancia focal (mm)'),
                  TextField(
                    controller: focalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 15),

                  const Text('Distancia al sujeto (m)'),
                  TextField(
                    controller: distanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 15),

                  const Text('Apertura (f/)'),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      showAperturePicker();
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: apertureController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (selectedAperture != null &&
                      focalController.text.isNotEmpty &&
                      distanceController.text.isNotEmpty)
                    Builder(
                      builder: (_) {
                        final focal = double.tryParse(focalController.text);
                        final distance = double.tryParse(distanceController.text);
                        if (focal == null || distance == null) return const SizedBox.shrink();

                        final apsc = calculateDepthOfField(
                          focalLength: focal,
                          aperture: selectedAperture!,
                          subjectDistance: distance,
                          coc: 0.019,
                        );

                        final full = calculateDepthOfField(
                          focalLength: focal,
                          aperture: selectedAperture!,
                          subjectDistance: distance,
                          coc: 0.030,
                        );

                        Widget rowLabelValue(String label, String value) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(label),
                                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rango de enfoque (APS-C y Full Frame)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Table(
                              border: TableBorder.all(),
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color: Colors.black54),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Center(
                                        child: Text(
                                          'APS-C',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Center(
                                        child: Text(
                                          'Full Frame',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          rowLabelValue('Desde:', '${apsc['near']?.toStringAsFixed(2)} m'),
                                          rowLabelValue('Hasta:', '${apsc['far'] == double.infinity ? '∞' : '${apsc['far']?.toStringAsFixed(2)} m'}'),
                                          rowLabelValue('Total:', '${apsc['dof'] == null ? '∞' : '${apsc['dof']!.toStringAsFixed(2)} m'}'),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          rowLabelValue('Desde:', '${full['near']?.toStringAsFixed(2)} m'),
                                          rowLabelValue('Hasta:', '${full['far'] == double.infinity ? '∞' : '${full['far']?.toStringAsFixed(2)} m'}'),
                                          rowLabelValue('Total:', '${full['dof'] == null ? '∞' : '${full['dof']!.toStringAsFixed(2)} m'}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
