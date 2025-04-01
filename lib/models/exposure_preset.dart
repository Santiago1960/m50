class ExposurePreset {
  final double aperture;
  final double shutterSpeed;

  ExposurePreset(this.aperture, this.shutterSpeed);
}

ExposurePreset getPresetForEV(double ev) {
  if (ev >= 15) return ExposurePreset(16.0, 1 / 100); // Sol directo
  if (ev >= 13) return ExposurePreset(11.0, 1 / 100); // Exterior brillante
  if (ev >= 11) return ExposurePreset(8.0, 1 / 100);  // Exterior sombra
  if (ev >= 9)  return ExposurePreset(5.6, 1 / 100);  // Día nublado exterior
  if (ev >= 7)  return ExposurePreset(4.0, 1 / 100);  // Interior junto a ventana
  if (ev >= 5.5) return ExposurePreset(2.8, 1 / 100); // Interior estándar
  if (ev >= 4)  return ExposurePreset(2.0, 1 / 100);   // Luz baja
  return ExposurePreset(1.4, 1 / 100);                 // Noche o muy poca luz
}