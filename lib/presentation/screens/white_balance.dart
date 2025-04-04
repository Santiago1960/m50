import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WhiteBalanceScreen extends StatelessWidget {
  const WhiteBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> whiteBalanceData = [
      {'Escenario': 'Luz del día (soleado)', 'Kelvin': '5200–5500 K'},
      {'Escenario': 'Cielo nublado', 'Kelvin': '6000–6500 K'},
      {'Escenario': 'Sombra', 'Kelvin': '7000–7500 K'},
      {'Escenario': 'Interior con luz cálida', 'Kelvin': '2500–3500 K'},
      {'Escenario': 'Tungsteno/incandescente', 'Kelvin': '2700–3200 K'},
      {'Escenario': 'Fluorescente blanco frío', 'Kelvin': '4000–5000 K'},
      {'Escenario': 'Flash de cámara', 'Kelvin': '5500–6000 K'},
      {'Escenario': 'Amanecer / Atardecer', 'Kelvin': '3000–4500 K'},
      {'Escenario': 'Luz de vela', 'Kelvin': '1900–2200 K'},
    ];

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
        title: const Text(
          'Guía de Balance de Blancos',
          style: TextStyle(color: Colors.white),
        ),
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
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 15,),

              const Text(
                'Consulta esta tabla para configurar manualmente la temperatura de color (Kelvin) según las condiciones de luz.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Escenario',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Kelvin',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 24),

                      // Lista de filas (sin scroll)
                      ...whiteBalanceData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    item['Escenario']!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    item['Kelvin']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            // Solo dibujar el Divider si no es la última fila
                            if (index < whiteBalanceData.length - 1)
                              const Divider(height: 24),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                '* Ajusta el valor Kelvin en tu cámara para lograr colores más reales según la escena.',
                style: TextStyle(fontSize: 10),
              ),

              const SizedBox(height: 10),

              const Text(
                '* Si necesitas una configuración más precisa, considera usar una carta de gris neutro al 18%.',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
