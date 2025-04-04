import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/pickers/widgets.dart';

class CompensationScreen extends StatefulWidget {
  const CompensationScreen({super.key});

  @override
  State<CompensationScreen> createState() => _CompensationScreenState();
}

class _CompensationScreenState extends State<CompensationScreen> {

  final TextEditingController apertureController = TextEditingController();
  final TextEditingController speedController = TextEditingController();
  final TextEditingController isoController = TextEditingController();

  double? selectedAperture = 16;
  String? selectedSpeedLabel = '1/400';
  double? selectedSpeedValue = 1/400;
  int? selectedISO = 400;

  bool apertureLocked = false;
  bool speedLocked = false;
  bool isoLocked = false;

  double ev = 0;

  // Cálculo de la exposición
  double evFrom(double aperture, double speed, int iso) {
    return (log(aperture * aperture / speed) / ln2) - (log(iso / 100) / ln2);
  }

  // Cálculo de velocidad a partir de la exposición
  double calculateShutterSpeed(double aperture, double ev, int iso) {
    return (aperture * aperture) / (pow(2, ev) * (iso / 100));
  }

  @override
  void initState() {
    super.initState();
    apertureController.text = selectedAperture != null ? 'f/${selectedAperture!.toStringAsFixed(1)}' : '';
    speedController.text = selectedSpeedLabel ?? '';
    isoController.text = selectedISO?.toString() ?? '';
  }

  @override
  void dispose() {
    apertureController.dispose();
    speedController.dispose();
    isoController.dispose();
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

    const List<Map<String, double>> speeds = [
      {'1/4000': 1/4000}, {'1/3200': 1/3200}, {'1/2500': 1/2500}, {'1/2000': 1/2000}, {'1/1600': 1/1600}, 
      {'1/1250': 1/1250},{'1/1000': 1/1000}, {'1/800': 1/800}, {'1/640': 1/640}, {'1/500': 1/500}, {'1/400': 1/400}, 
      {'1/320': 1/320},{'1/250': 1/250}, {'1/200': 1/200}, {'1/160': 1/160}, {'1/125': 1/125}, {'1/100': 1/100}, 
      {'1/80': 1/80},{'1/60': 1/60}, {'1/50': 1/50}, {'1/40': 1/40}, {'1/30': 1/30}, {'1/25': 1/25}, {'1/20': 1/20},
      {'1/15': 1/15}, {'1/13': 1/13}, {'1/10': 1/10}, {'1/8': 1/8}, {'1/6': 1/6}, {'1/5': 1/5}, {'1/4': 1/4}, 
      {'0"3': 0.3}, {'0"4': 0.4}, {'0"5': 0.5},{'0"6': 0.6}, {'0"8': 0.8}, {'1"': 1.0}, {'1"3': 1.3}, {'1"6': 1.6}, 
      {'2"': 2}, {'2"5': 2.5}, {'3"2': 3.2}, {'4"': 4}, {'5"': 5.0}, {'6"': 6.0}, {'8"': 8.0}, {'10"': 10.0}, 
      {'13"': 13.0}, {'15"': 15.0}, {'20"': 20.0}, {'25"': 25.0}, {'30"': 30.0}
    ];

    const List<int> isos = [
      25600, 20000, 16000, 12800, 10000,8000, 6400, 5000, 4000, 3200,2500, 2000, 1600, 1250, 1000,800, 640, 500, 400, 
      320,250, 200, 160, 125, 100,
    ];

    // FUNCIONES
    // AJUSTAR EL VALOR DE APERTURA A LA MÁS CERCANA
    double roundToNearestAperture(double value, List<double> apertures) {
      final rounded = apertures.reduce((a, b) =>
        (value - a).abs() < (value - b).abs() ? a : b);

      return rounded;
    }

    // AJUSTAR EL VALOR DE VELOCIDAD A LA MÁS CERCANA
    double roundToNearestSpeed(double value, List<Map<String, double>> speeds) {
      final rounded = speeds.reduce((a, b) =>
        (value - a.values.first).abs() < (value - b.values.first).abs() ? a : b);

      return rounded.values.first;
    }

    // AJUSTAR EL VALOR DE ISO A LA MÁS CERCANA
    int roundToNearestISO(double value, List<int> isos) {
      final rounded = isos.reduce((a, b) =>
        (value - a).abs() < (value - b).abs() ? a : b);

      return rounded;
    }

    // RECUPERAR LA ETIQUETA DE VELOCIDAD A PARTIR DEL VALOR
    String labelFromValue(double value) {
      const double tolerance = 0.00001;

      for (final entry in speeds) {
        final label = entry.keys.first;
        final val = entry.values.first;

        if ((val - value).abs() < tolerance) {
          return label;
        }
      }

      return 'Desconocido';
    }

    // MOSTRAR ERROR
    void showExposureError(BuildContext context, String message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          barrierDismissible: false,
          context: context,
          useRootNavigator: true,
          builder: (context) => AlertDialog(
            title: const Text('Valor fuera de rango'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      });
    }

    // CALCULAR LA EXPOSICIÓN COMPENSADA
    void recalculateExposure({
      double? newAperture,
      double? newSpeed,
      int? newISO,
    }) {

      // CUANDO CAMBIAMOS LA APERTURA
      if(newAperture != null) {
        
        // Verificamos que otra variable está bloqueada
        if(speedLocked == true) {

          // Calculamos la nueva ISO con velocidad bloqueada
          double newISOValue = (pow(newAperture, 2) / (selectedSpeedValue! * pow(2, ev))) * 100;

          if(newISOValue <= 75 || newISOValue >= 38400) {

            showExposureError(context, 'El valor de ISO calculado está fuera de límite (100 - 25600).');

            setState(() { });

            return;
          }

          selectedISO = roundToNearestISO(newISOValue, isos);
          isoController.text = selectedISO.toString();
          selectedAperture = newAperture;
          apertureController.text = 'f/${newAperture.toStringAsFixed(1)}';

        } else if(isoLocked == true) {

          // Si la ISO está bloqueada, calculamos la nueva velocidad
          double newSpeedValue = calculateShutterSpeed(newAperture, ev, selectedISO!);

          if(newSpeedValue <= 1/4000 || newSpeedValue >= 30) {

            showExposureError(context, 'El valor de la velocidad calculada está fuera de límite (1/4000 - 30s).');

            setState(() { });

            return;
          }

          newSpeedValue = roundToNearestSpeed(newSpeedValue, speeds);
          selectedSpeedValue = newSpeedValue;
          selectedSpeedLabel = labelFromValue(newSpeedValue);
          speedController.text = selectedSpeedLabel!;
          selectedAperture = newAperture;
          apertureController.text = 'f/${newAperture.toStringAsFixed(1)}';
        }
      }

      // CUANDO CAMBIAMOS LA VELOCIDAD
      if(newSpeed != null) {

        // Verificamos que otra variable está bloqueada
        if(apertureLocked == true) {

          // Calculamos la nueva ISO con apertura bloqueada
          double newISO = (pow(selectedAperture!, 2) * 100) / (newSpeed * pow(2, ev));

          if(newISO <= 75 || newISO >= 38400) {

            showExposureError(context, 'El valor de ISO calculado está fuera de límite (100 - 25600).');

            setState(() {});

            return;
          }

          selectedISO = roundToNearestISO(newISO, isos);
          isoController.text = selectedISO.toString();
          selectedSpeedValue = newSpeed;
          selectedSpeedLabel = labelFromValue(newSpeed);
          speedController.text = selectedSpeedLabel!;

        } else if(isoLocked == true) {

          // Si la ISO está bloqueada, calculamos la nueva apertura
          double newAperture = sqrt(newSpeed * pow(2, ev) * (selectedISO! / 100));

          if(newAperture <= 1.1 || newAperture >= 23) {

            showExposureError(context, 'El valor de apertura calculado está fuera de límite (f/1.4 - f/22).');

            setState(() { });

            return;
          }

          selectedAperture = roundToNearestAperture(newAperture, apertures);
          apertureController.text = 'f/${selectedAperture!.toStringAsFixed(1)}';
          selectedSpeedValue = newSpeed;
          selectedSpeedLabel = labelFromValue(newSpeed);
          speedController.text = selectedSpeedLabel!;
        }
      }

      // CUANDO CAMBIAMOS LA ISO
      if(newISO != null) {

        // Verificamos que otra variable está bloqueada
        if(apertureLocked == true) {

          // Calculamos la nueva ISO con apertura bloqueada
          double newSpeed = (selectedAperture! * selectedAperture!) / (pow(2, ev) * (newISO / 100));

          if(newSpeed <= 1/4000 || newSpeed >= 30) {

            showExposureError(context, 'El valor de la velocidad calculada está fuera de límite (1/4000 - 30s).');

            setState(() {});

            return;
          }

          selectedSpeedValue = roundToNearestSpeed(newSpeed, speeds);
          selectedSpeedLabel = labelFromValue(newSpeed);
          speedController.text = selectedSpeedLabel!;
          selectedISO = newISO;
          isoController.text = newISO.toString();

        } else if(speedLocked == true) {

          // Si la velocidad está bloqueada, calculamos la nueva apertura
          double newAperture = sqrt(selectedSpeedValue! * pow(2, ev) * (newISO / 100));

          if(newAperture <= 1.1 || newAperture >= 23) {

            showExposureError(context, 'El valor de apertura calculado está fuera de límite (f/1.4 - f/22).');

            setState(() { });

            return;
          }

          selectedAperture = roundToNearestAperture(newAperture, apertures);
          apertureController.text = 'f/${selectedAperture!.toStringAsFixed(1)}';
          selectedISO = newISO;
          isoController.text = newISO.toString();
        }
      }
    }


    void showAperturePicker() {

      ExposurePickers.showAperturePicker(
        context: context,
        apertures: apertures,
        selectedAperture: selectedAperture,
        onSelected: (value) {

          setState(() {

            if (!apertureLocked && (speedLocked || isoLocked)) {

              recalculateExposure(newAperture: value);
            } else {

              selectedAperture = value;
              apertureController.text = 'f/${value.toStringAsFixed(1)}';
            }
          });
        },
      );
    }

    void showSpeedPicker() {

      ExposurePickers.showSpeedPicker(
        context: context,
        speeds: speeds,
        selectedLabel: selectedSpeedLabel,
        onSelected: (label, value) {

          setState(() {

            if (!speedLocked && (apertureLocked || isoLocked)) {

              recalculateExposure(newSpeed: value);
            } else {

              selectedSpeedValue = value;
              selectedSpeedLabel = label;
              speedController.text = selectedSpeedLabel!;
            }
          });
        },
      );
    }

    void showIsoPicker() {

      ExposurePickers.showISOPicker(
        context: context,
        isos: isos,
        selectedISO: selectedISO,
        onSelected: (value) {

          setState(() {
            
            if (!isoLocked && (apertureLocked || speedLocked)) {

              recalculateExposure(newISO: value);
            } else {

              selectedISO = value;
              isoController.text = value.toString();
            }
          });
        },
      );
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
        title: const Text('Exposición', style: TextStyle(color: Colors.white)),
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
                          children: [
                            Icon(Icons.exposure, color: Colors.black54),

                            SizedBox(width: 8),

                            Text(
                              'Exposición Base',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(width: 35),

                            ev != 0
                                ? Text(
                                    'EV: ${ev.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ingresa los valores de apertura, velocidad e ISO que te proporciona el exposímetro. Asegúrate que la exposición es correcta y fíjala.\n\nPara obtener una exposición compensada, bloquea el candado de una variable y modifica cualquiera de las otras dos.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),

                        const SizedBox(height: 20),
                        
                        const Text(
                          'Apertura (f/)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  apertureLocked
                                      ? null
                                      : showAperturePicker();
                                },
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
                                    controller: apertureController,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 20),

                            ev != 0
                              ? GestureDetector(
                                onTap: () {
                                  apertureLocked = !apertureLocked;
                                  if (apertureLocked) {
                                    speedLocked = false;
                                    isoLocked = false;
                                  }
                                  setState(() {});
                                },
                                child: apertureLocked
                                    ? Icon(Icons.lock_rounded, color: Colors.red[900])
                                    : Icon(Icons.lock_open_rounded, color: Colors.black54),
                              )
                              : Container(),
                          ],
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
                        
                        Row(
                          children: [

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  speedLocked
                                      ? null
                                      : showSpeedPicker();
                                },
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
                                    controller: speedController,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 20),

                            ev != 0
                              ? GestureDetector(
                                onTap: () {
                                  speedLocked = !speedLocked;
                                  if (speedLocked) {
                                    apertureLocked = false;
                                    isoLocked = false;
                                  }
                                  setState(() {});
                                },
                                child: speedLocked
                                    ? Icon(Icons.lock_rounded, color: Colors.red[900])
                                    : Icon(Icons.lock_open_rounded, color: Colors.black54),
                              )
                              : Container(),
                          ],
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

                        Row(
                          children: [

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  isoLocked
                                      ? null
                                      : showIsoPicker();
                                },
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
                                    controller: isoController,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 20),

                            ev != 0
                              ? GestureDetector(
                                onTap: () {
                                  isoLocked = !isoLocked;
                                  if (isoLocked) {
                                    apertureLocked = false;
                                    speedLocked = false;
                                  }
                                  setState(() {});
                                },
                                child: isoLocked
                                    ? Icon(Icons.lock_rounded, color: Colors.red[900])
                                    : Icon(Icons.lock_open_rounded, color: Colors.black54),
                              )
                              : Container(),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Botón para fijar la exposición
                        Center(
                          child: ElevatedButton(
                            onPressed: (apertureLocked || speedLocked || isoLocked)
                              ? null
                              : () {
                                  setState(() {
                                    ev = evFrom(selectedAperture!, selectedSpeedValue!, selectedISO!);
                                  });
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Fijar exposición', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                  SizedBox(height: 20),

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