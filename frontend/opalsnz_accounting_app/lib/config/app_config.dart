class AppConfig {
  // Local dev API by default; override via --dart-define=API_BASE_URL=... for other environments.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5064',
  );
}
