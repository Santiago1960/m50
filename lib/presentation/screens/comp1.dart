import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CompensationScreen extends StatefulWidget {
  const CompensationScreen({super.key});

  @override
  State<CompensationScreen> createState() => _CompensationScreenState();
}

class _CompensationScreenState extends State<CompensationScreen> {

  double? selectedAperture = 16;
  String? selectedSpeedLabel = '1/400';
  double? selectedSpeedValue = 1/400;
  int? selectedISO = 400;
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
      1.4, 1.8, 2.0, 2.2, 2.5, 2.8, 3.2, 3.5, 
      4.0, 4.5, 5.0, 5.6, 6.3, 7.1, 8.0, 9.0, 10,
      11.0, 13.0, 14.0, 16.0, 18.0, 20.0, 22.0
    ];

    const List<Map<String, double>> speeds = [
      {'1/4000': 1/4000}, {'1/3200': 1/3200}, {'1/2500': 1/2500}, {'1/2000': 1/2000}, {'1/1600': 1/1600}, {'1/1250': 1/1250},
      {'1/1000': 1/1000}, {'1/800': 1/800}, {'1/640': 1/640}, {'1/500': 1/500}, {'1/400': 1/400}, {'1/320': 1/320},
      {'1/250': 1/250}, {'1/200': 1/200}, {'1/160': 1/160}, {'1/125': 1/125}, {'1/100': 1/100}, {'1/80': 1/80},
      {'1/60': 1/60}, {'1/50': 1/50}, {'1/40': 1/40}, {'1/30': 1/30}, {'1/25': 1/25}, {'1/20': 1/20},{'1/15': 1/15}, 
      {'1/13': 1/13}, {'1/10': 1/10}, {'1/8': 1/8}, {'1/6': 1/6}, {'1/5': 1/5}, {'1/4': 1/4}, {'0"3': 0.3}, {'0"4': 0.4}, 
      {'0"5': 0.5},{'0"6': 0.6}, {'0"8': 0.8}, {'1"': 1.0}, 
      {'1"3': 1.3}, {'1"6': 1.6}, {'2"': 2}, {'2"5': 2.5}, {'3"2': 3.2}, {'4"': 4}, {'5"': 5.0}, {'6"': 6.0}, 
      {'8"': 8.0}, {'10"': 10.0}, {'13"': 13.0}, {'15"': 15.0}, {'20"': 20.0}, {'25"': 25.0}, {'30"': 30.0}
    ];

    const List<int> isos = [
      100, 125, 160, 200, 250, 320, 400,
      500, 640, 800, 1000, 1250, 1600,
      2000, 2500, 3200, 4000, 5000,
      6400, 8000, 10000, 12800, 16000,
      20000, 25600
    ];

    // FUNCIONES
    // Calcular la distancia hiperfocal
    double calculateHyperfocal(double focalLength, double aperture) {
      const double c = 0.019; // círculo de confusión para Canon APS-C en mm
      double h = (focalLength * focalLength) / (aperture * c) + focalLength; // en mm
      return h / 1000; // convertir a metros
    }

    // FUNCION PARA MOSTRAR LA RUEDA DE APERTURAS
    void showAperturePicker() {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 200,
            child: CupertinoPicker(
              useMagnifier: false,
              magnification: 1.0,
              backgroundColor: Colors.white,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: selectedAperture != null
                    ? apertures.indexOf(selectedAperture!)
                    : 0,
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedAperture = apertures[index];
                });
              },
              children: apertures
                  .map((ap) => Center(
                    child: Text(
                      'f/${ap.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                      )
                  ))
                  .toList(),
            ),
          );
        },
      );
    }

    // FUNCION PARA MOSTRAR LA RUEDA DE VELOCIDADES
    void showSpeedPicker() {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 200,
            child: CupertinoPicker(
              useMagnifier: false,
              magnification: 1.0,
              backgroundColor: Colors.white,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: selectedSpeedLabel != null
                    ? speeds.indexWhere((map) => map.keys.first == selectedSpeedLabel)
                    : 0,
              ),
              onSelectedItemChanged: (index) {
                final selectedMap = speeds[index];
                setState(() {
                  selectedSpeedLabel = selectedMap.keys.first;
                  selectedSpeedValue = selectedMap.values.first;
                });
              },
              children: speeds.map((speedMap) {
                final label = speedMap.keys.first;
                return Center(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }

    // FUNCION PARA MOSTRAR LA RUEDA DE ISOS
    void showIsoPicker() {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 200,
            child: CupertinoPicker(
              useMagnifier: false,
              magnification: 1.0,
              backgroundColor: Colors.white,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: selectedISO != null
                    ? isos.indexOf(selectedISO!)
                    : 0,
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedISO = isos[index];
                });
              },
              children: isos
                  .map((iso) => Center(
                    child: Text(
                      iso.toStringAsFixed(1),
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                      )
                  ))
                  .toList(),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Compensación de la exposición', style: TextStyle(color: Colors.white60)),
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
                            Icon(Icons.exposure, color: Colors.black54),
                            SizedBox(width: 8),
                            Text(
                              'Exposición Base',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ingresa los valores de apertura, velocidad e ISO que te proporciona el exposímetro. Asegúrate que la exposición es correcta.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),

                        const SizedBox(height: 12),
                        
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
                          onTap: showAperturePicker,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                //labelText: 'Apertura (f/)',
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
                              controller: TextEditingController(
                                text: selectedAperture != null ? 'f/${selectedAperture!.toStringAsFixed(1)}' : '',
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        const Text(
                          'Velocidad',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),
                        
                        GestureDetector(
                          onTap: showSpeedPicker,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                //labelText: 'Velocidad',
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
                              controller: TextEditingController(
                                text: selectedAperture != null ? selectedSpeedLabel : '',
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        const Text(
                          'ISO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 2),

                        GestureDetector(
                          onTap: showIsoPicker,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                //labelText: 'ISO',
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
                              controller: TextEditingController(
                                text: selectedISO != null ? selectedISO!.toStringAsFixed(1) : '',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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