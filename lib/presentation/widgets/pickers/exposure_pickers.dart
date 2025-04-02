// exposure_pickers.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExposurePickers {
  
  static Future<void> showSpeedPicker({
    required BuildContext context,
    required List<Map<String, double>> speeds,
    required String? selectedLabel,
    required void Function(String label, double value) onSelected,
  }) async {
    final labels = speeds.map((s) => s.keys.first).toList();
    final selectedIndex = labels.indexOf(selectedLabel ?? labels.first);
    int tempIndex = selectedIndex;

    await showCupertinoModalPopup<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Container(
          height: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    tempIndex = index;
                  },
                  children: labels
                      .map((label) => Text(label, style: TextStyle(fontSize: 18)))
                      .toList(),
                ),
              ),
              CupertinoButton(
                child: const Text("Seleccionar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final label = labels[tempIndex];
                  final value = speeds[tempIndex].values.first;
                  onSelected(label, value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showAperturePicker({
    required BuildContext context,
    required List<double> apertures,
    required double? selectedAperture,
    required void Function(double value) onSelected,
  }) async {
    final selectedIndex = selectedAperture != null
        ? apertures.indexOf(selectedAperture)
        : 0;
    int tempIndex = selectedIndex;

    await showCupertinoModalPopup<double>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Container(
          height: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    tempIndex = index;
                  },
                  children: apertures
                      .map((ap) => Text('f/${ap.toStringAsFixed(1)}', style: TextStyle(fontSize: 18)))
                      .toList(),
                ),
              ),
              CupertinoButton(
                child: const Text("Seleccionar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  onSelected(apertures[tempIndex]);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showISOPicker({
    required BuildContext context,
    required List<int> isos,
    required int? selectedISO,
    required void Function(int value) onSelected,
  }) async {
    final selectedIndex = selectedISO != null
        ? isos.indexOf(selectedISO)
        : 0;
    int tempIndex = selectedIndex;

    await showCupertinoModalPopup<int>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Container(
          height: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    tempIndex = index;
                  },
                  children: isos
                      .map((iso) => Text(iso.toString(), style: TextStyle(fontSize: 18)))
                      .toList(),
                ),
              ),
              CupertinoButton(
                child: const Text("Seleccionar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  onSelected(isos[tempIndex]);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}