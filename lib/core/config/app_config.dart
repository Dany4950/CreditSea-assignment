/// Build-time config.
///

class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://creditsea-api-oaxz.onrender.com/api',
  );
}
