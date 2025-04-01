import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:light/light.dart';

import '../../../models/models.dart';

class FotometerScreen extends StatefulWidget {
  const FotometerScreen({super.key});

  @override
  State<FotometerScreen> createState() => _FotometerScreenState();
}

class _FotometerScreenState extends State<FotometerScreen> {

  StreamSubscription<int>? _lightSubscription;
  double? _lux;
  double? _ev;
  double? _evSet;
  bool _mostrarError = false;
  double _compensacionEV = 0.0;

  @override
  void initState() {
    super.initState();
    _startLightSensor();
  }

  // FUNCIONES

  // LECTURA DEL SENSOR
  void _startLightSensor() {
    try {
      _lightSubscription = Light().lightSensorStream.listen((luxValue) {
        final double lux = roundLux(luxValue.toDouble());
        final double ev = calculateEV400(lux);
        setState(() {
          _lux = lux;
          _ev = ev;
          _mostrarError = false;
        });
      });
    } catch (e) {
      debugPrint('Error leyendo sensor de luz: $e');
    }
  }

  // CALCULO DE EV
  double calculateEV400(double lux) {
    double ev100 = (lux > 0) ? log(lux * 0.125) / log(2) : 0;
    return ev100 + 2;
  }

  // GUARDAR LECTURA
  void _saveReading() {
    setState(() {
      _evSet = _ev;
    });
  }

  // REDONDEAR EL VALOR DE LUX A MULTIPLOS DE CIEN
  double roundLux(double lux) {
    return (lux / 100).round() * 100;
  }

  // DESCRIPCION DE LA ESCENA
  String describeScene(double ev) {
    if (ev >= 15)  return 'Día soleado';
    if (ev >= 13)  return 'Exterior brillante';
    if (ev >= 11)  return 'Exterior sombra';
    if (ev >= 9)   return 'Exterior, día nublado';
    if (ev >= 7)   return 'Interior junto a ventana';
    if (ev >= 5)   return 'Interior estándar';
    if (ev >= 3)   return 'Atardecer o escena nocturna iluminada';
    if (ev >= 1)   return 'Escena nocturna';
    return 'Noche o muy poca luz';
  }

  // REDONDEAR ISO EN PASOS DE 1/3 EV
  double roundISOToThirdStops(double iso) {
    const isoThirdStops = [
      100.0, 125.0, 160.0,
      200.0, 250.0, 320.0,
      400.0, 500.0, 640.0,
      800.0, 1000.0, 1250.0,
      1600.0, 2000.0, 2500.0,
      3200.0, 4000.0, 5000.0,
      6400.0, 8000.0, 10000.0,
      12800.0, 16000.0, 20000.0,
      25600.0,
    ];

    return isoThirdStops.reduce((a, b) =>
        (iso - a).abs() < (iso - b).abs() ? a : b);
  }

  // CALCULO DE EXPOSICION EN FUNCION DE APERTURA Y VELOCIDAD RECOMENDADOS
  double calculateEVFromSettings(double aperture, double shutterSpeed) {
    return log(pow(aperture, 2) / shutterSpeed) / log(2);
  }

  // CALCULO DE ISO EN FUNCION DE APERTURA Y VELOCIDAD RECOMENDADOS
  double calculateRequiredISO(double evMeasured, double evSettings) {
    return 100 * pow(2, evSettings - evMeasured).toDouble();
  }

  // FORMATO DE VELOCIDAD (Entero para segundos y fracciones para valores menores a 1)
  String formatShutterSpeed(double shutterSpeed) {
    if (shutterSpeed >= 1) {
      return shutterSpeed.toInt().toString();
    } else {
      final int denominator = (1 / shutterSpeed).round();
      return '1/$denominator';
    }
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final luxText = _lux != null ? _lux!.toStringAsFixed(2) : '--';
    final evText = _ev != null ? _ev!.toStringAsFixed(2) : '--';

    ExposurePreset? preset;
      double? evConfig;
      double? requiredISO;
      double? isoRounded;

      if (_evSet != null) {
        final double evAjustado = _evSet! + _compensacionEV;
        preset = getPresetForEV(evAjustado);
        evConfig = calculateEVFromSettings(preset.aperture, preset.shutterSpeed);
        requiredISO = calculateRequiredISO(evAjustado, evConfig);
        isoRounded = roundISOToThirdStops(requiredISO);
      }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Fotómetro', style: TextStyle(color: Colors.white60),)
      ),
      body: Container(
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _evSet == null && _ev != null
              ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text('Medición: $luxText lux'),
        
                Text('EV (ISO 400): $evText'),
        
                Text(describeScene(_ev!)),
        
                const SizedBox(height: 20),
        
                ElevatedButton(
                  onPressed: _ev != null ? _saveReading : null,
                  style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
        
                  child: const Text('Guardar lectura', style: TextStyle(color: Colors.black),),
                ),
              ],
            )
            : 
            Center(
              child: (preset != null && isoRounded != null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Apertura: f/${preset.aperture.toStringAsFixed(1)}'),
                      Text('Velocidad: ${formatShutterSpeed(preset.shutterSpeed)}'),
                      Text('ISO recomendado: ${isoRounded.round()}'),

                      SizedBox(height: 20),

                      Text('Ajuste de exposición: ${_compensacionEV.toStringAsFixed(1)} EV'),

                      Slider(
                        value: _compensacionEV,
                        min: -2.0,
                        max: 2.0,
                        divisions: 12,
                        label: '${_compensacionEV.toStringAsFixed(1)} EV',
                        onChanged: (value) {
                          setState(() {
                            _compensacionEV = value;
                          });
                        },
                      ),

                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _evSet = null;
                            _lux = null;
                            _ev = null;
                          });

                          Future.delayed(const Duration(milliseconds: 400), () {
                            if (_evSet == null && mounted) {
                              setState(() {
                                _mostrarError = true;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
              
                        child: const Text('Volver a medir', style: TextStyle(color: Colors.black),),
                      ),
                    ],
                  )
                : _mostrarError
                  ? const Text('No se pudo calcular la exposición recomendada.')
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}