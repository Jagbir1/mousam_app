import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mousam_app/models/mousam_model.dart';
import 'package:mousam_app/service/mousam_service.dart';

class MousamScreen extends StatefulWidget {
  const MousamScreen({super.key});

  @override
  State<MousamScreen> createState() => _MousamScreenState();
}

class _MousamScreenState extends State<MousamScreen> {
  //api key
  final _weatherService = WeatherService();
  var _city = 'Safidon'; //default city
  Weather? _weather;

  //fetch weather
  _fetchWeather() async {
    try {
      // First try with the hardcoded city
      try {
        final weather = await _weatherService.fetchWeather(_city);
        setState(() {
          _weather = weather;
        });
        return;
      } catch (e) {
        print('Error fetching weather for $_city: $e');
      }

      // If that fails, try with device location
      try {
        final cityName = await _weatherService.getCurrentCity();
        if (cityName.isNotEmpty) {
          final weather = await _weatherService.fetchWeather(cityName);
          setState(() {
            _weather = weather;
          });
          return;
        }
      } catch (e) {
        print('Error getting device location: $e');
      }

      // If all else fails, show an error
      setState(() {
        _weather = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch weather data')),
      );
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _weather = null;
      });
    }
  }

  //weather animations
  String _getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/storm.png';
    switch (mainCondition) {
      case 'Clear':
        return 'assets/sun.png';
      case 'Rain':
        return 'assets/heavy-rain.png';
      case 'Clouds':
        return 'assets/cloudy.png';
      default:
        return 'assets/drizzle.png';
    }
  }

  //init State
  @override
  void initState() {
    super.initState();
    //fetch weather here
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mousam App'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Search bar
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Enter city name',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.location_on),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _city = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchWeather,
                child: const Text('Get Weather'),
              ),
              SizedBox(height: 100),
              //loading indicator
              if (_weather == null) const CircularProgressIndicator(),
              //city name
              Text(
                _weather?.cityName ?? "loading city...",
                style: TextStyle(fontSize: 30),
              ),
              //weather animation
              Image.asset(
                _getWeatherAnimation(_weather?.mainCondition),
                height: 100,
                width: 100,
              ),
              //temprature
              Text(
                '${_weather?.temperature.round()}°C',
                style: TextStyle(fontSize: 20),
              ),
              //weather condition
              Text(
                _weather?.mainCondition ?? "loading condition...",
                style: TextStyle(fontSize: 20),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
