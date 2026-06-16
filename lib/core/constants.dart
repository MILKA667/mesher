class AppConstants {
  AppConstants._();

  static const appName = 'MeshLink';
  static const appVersion = '0.1.0';

  // MethodChannel names
  static const chBluetoothName = 'meshlink/bluetooth';

  // Scan / connection
  static const maxScanRadiusMeters = 120;
  static const defaultMtu = 512;

  // Crypto
  static const sessionKeyRotationDays = 7;
}
