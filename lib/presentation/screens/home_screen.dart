import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:math';

import 'package:m50/presentation/ads/ad_manager.dart';
import 'package:m50/providers/product_list_provider.dart';
import 'package:m50/providers/purchase_controller_provider.dart';
import 'package:m50/providers/purchase_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final Size screenSize = MediaQuery.of(context).size;
    final double radius = 130;
    final Offset center = Offset(screenSize.width / 2, screenSize.height / 2);

    final products = ref.watch(productListProvider);
    final purchaseState = ref.watch(purchaseStateProvider);

    print('Productos disponibles: ${products.map((e) => e.id).toList()}');
    print('Estado de compra: ${purchaseState.adsRemoved}, ${purchaseState.dofUnlocked}');

    final List<_RadialIconData> icons = [
      _RadialIconData(icon: Icons.center_focus_strong, label: 'Hyperfocal', angle: 0, route: '/hyperfocal'),
      _RadialIconData(icon: Icons.blur_on, label: 'DoF', angle: 45, route: '/dof'),
      _RadialIconData(icon: Icons.exposure, label: 'Exposición', angle: 90, route: '/compensation'),
      _RadialIconData(icon: Icons.tonality, label: 'Blancos', angle: 135, route: '/whitebalance'),
      _RadialIconData(icon: null, label: 'M50', angle: 262, route: ''),
    ];

    return Scaffold(

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

          Positioned(
            top: 40, // Ajusta según tu barra de estado
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.black87, size: 30),
              onPressed: () {
                _showSettingsMenu(context, ref);
              },
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

          // Íconos y textos distribuidos alrededor del círculo
          ...icons.map((data) {
            final double rad = data.angle * pi / 180;
            final Offset pos = Offset(
              center.dx + radius * cos(rad) - 30,
              center.dy + radius * sin(rad) - 30,
            );

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: data.icon == null
                  ? Text(
                      data.label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : _buildIconButton(
                      context,
                      icon: data.icon!,
                      label: data.label,

                      onTap: () async {
                        // Si el icono es "DoF", verifica si la compra está desbloqueada
                        if (data.label == 'DoF' && !purchaseState.dofUnlocked) {
                          if (purchaseState.dofTrialRemaining > 0) {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Función limitada'),
                                content: Text('Esta función es de pago. Puedes probarla gratis 5 veces.\n\nTe quedan ${purchaseState.dofTrialRemaining} usos.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Entendido'),
                                  ),
                                ],
                              ),
                            );

                            if(!purchaseState.adsRemoved || !purchaseState.dofUnlocked) {
                              AdManager.showInterstitial(
                                onFinish: () {
                                  AdManager.loadInterstitial();
                                  context.push(data.route);
                                },
                              );
                            } else {
                              if(context.mounted) {
                                context.push(data.route);
                              }
                            }
                            //ref.read(purchaseStateProvider.notifier).consumeDOFTrial();
                          } else {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Acceso restringido'),
                                content: const Text('Has agotado las 5 pruebas gratuitas.\n\nPuedes desbloquear la función DOF desde el menú de configuración.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                        } else {
                          if(!purchaseState.adsRemoved || !purchaseState.dofUnlocked) {
                              AdManager.showInterstitial(
                                onFinish: () {
                                  AdManager.loadInterstitial();
                                  context.push(data.route);
                                },
                              );
                            } else {
                              if(context.mounted) {
                                context.push(data.route);
                              }
                            }
                        }
                      },
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
  final IconData? icon;
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

void _showSettingsMenu(BuildContext context, WidgetRef ref) {

  final products = ref.watch(productListProvider);
  final purchaseState = ref.watch(purchaseStateProvider);

  final List<Widget> widgets = [];

  // Producto: remove_ads
  if (!purchaseState.adsRemoved) {
    ProductDetails? removeAdsProduct;
    try {
      removeAdsProduct = products.firstWhere((p) => p.id == 'remove_ads');
    } catch (_) {
      removeAdsProduct = null;
    }

    widgets.add(
      GestureDetector(
        onTap: () {
          if (removeAdsProduct != null) {
            ref.read(purchaseControllerProvider).buy(removeAdsProduct);
            Navigator.pop(context);
          }
        },
        child: ListTile(
          leading: const Icon(Icons.block),
          title: Text(
            removeAdsProduct != null
                ? 'Eliminar anuncios (${removeAdsProduct.price})'
                : 'Eliminar anuncios',
          ),
          subtitle: const Text('Compra para eliminar anuncios'),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  // Producto: unlock_dof
  if (!purchaseState.dofUnlocked) {
    ProductDetails? unlockDofProduct;
    try {
      unlockDofProduct = products.firstWhere((p) => p.id == 'unlock_dof');
    } catch (_) {
      unlockDofProduct = null;
    }

    widgets.add(
      GestureDetector(
        onTap: () {
          if (unlockDofProduct != null) {
            ref.read(purchaseControllerProvider).buy(unlockDofProduct);
            Navigator.pop(context);
          }
        },
        child: ListTile(
          leading: const Icon(Icons.blur_on),
          title: Text(
            unlockDofProduct != null
                ? 'Desbloquear DOF (${unlockDofProduct.price})'
                : 'Desbloquear DOF',
          ),
          subtitle: !purchaseState.dofUnlocked
            ? Text('Activa la herramienta de profundidad de campo y elimina la publicidad')
            : Text('Activa la herramienta de profundidad de campo'),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  // Información general
  widgets.add(
    ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Información'),
      onTap: () async {
        Navigator.pop(context);
        // Aquí muestras info sobre la app
        final url = Uri.parse('https://sites.google.com/view/m50-app'); // Tu URL de Google Sites

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication); // Abre en navegador
        } else {
          // Mostrar un error o Snackbar
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo abrir el enlace')),
            );
          }
        }
      },
    ),
  );

  if (Platform.isIOS &&
    !purchaseState.adsRemoved &&
    !purchaseState.dofUnlocked) {
    widgets.add(
      ListTile(
        leading: const Icon(Icons.restore),
        title: const Text('Restaurar compras'),
        onTap: () async {
          await ref.read(purchaseControllerProvider).verifyPastPurchases();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Se han restaurado las compras')),
            );
          }
        },
      ),
    );
  }

  widgets.add(
    ListTile(
      leading: const Icon(Icons.restore),
      title: const Text('REINICIAR COMPRAS (PRUEBAS)'),
      onTap: () async {
        await ref.read(purchaseStateProvider.notifier).resetPurchases();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se han reiniciado las compras')),
          );
          Navigator.pop(context);
        }
      },
    ),
  );

  widgets.add(SizedBox(height: 20));

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      );
    },
  );
}