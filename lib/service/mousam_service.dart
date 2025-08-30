import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mousam_app/models/mousam_model.dart';

class WeatherService {
  // final String city = 'Delhi';
  final String apiKey =
      "1b593a6af7ca1cd062a499539c1b8d7d"; // OpenWeather API key
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Weather> fetchWeather(String city) async {
    final url = Uri.parse("$baseUrl?q=$city&appid=$apiKey&units=metric");

    print('Fetching weather from: $url');
    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return Weather.fromJson(json);
      } catch (e) {
        print('Error parsing weather data: $e');
        throw Exception("Failed to parse weather data");
      }
    } else {
      throw Exception(
        "Failed to load weather data: ${response.statusCode} - ${response.body}",
      );
    }
  }

  Future<String> getCurrentCity() async {
    //permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    //fetch current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    //convert location into list of placemark objects
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    //extract city name from first placemarks
    String? city = placemarks[0].locality;
    return city ?? "";
  }
}
