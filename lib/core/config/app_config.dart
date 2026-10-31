/// Build-time config. Override with:
///   flutter run --dart-define=API_URL=https://your-app.onrender.com/api
class AppConfig {
  AppConfig._();

  /// 10.0.2.2 = host machine from the Android emulator.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );
}
