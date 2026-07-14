import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String description;
  final double temperature;
  final int humidity;
  final String icon;
  final String cityName;

  const WeatherData({
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.icon,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather']?[0] ?? {};
    final main = json['main'] ?? {};
    return WeatherData(
      description: weather['description'] ?? '',
      temperature: (main['temp'] ?? 0).toDouble(),
      humidity: main['humidity'] ?? 0,
      icon: weather['icon'] ?? '01d',
      cityName: json['name'] ?? '',
    );
  }
}

class RestApiDatasource {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  // NOTE: Replace with your actual API key
  static const String _apiKey = 'cd998286ebcbbb2870b61a11b2c8eddb';

  final http.Client _client;

  RestApiDatasource({http.Client? client}) : _client = client ?? http.Client();

  /// Get current weather for a given latitude/longitude
  Future<WeatherData> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=es',
    );

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Error al obtener el clima: ${response.statusCode}');
    }
  }

  /// Get weather icon URL
  static String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  void dispose() {
    _client.close();
  }
}
