import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  String cityName = '';
  String condition = '';
  String iconCode = '';
  double temperature = 0;
  int humidity = 0;
  double windSpeed = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadWeather(); // Automatically loads weather when screen opens
  }

  Future<void> loadWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Step 1: Get GPS location
      final position = await _weatherService.getCurrentLocation();

      // Step 2: Fetch weather using that location
      final data = await _weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      // Step 3: Extract data from the JSON response
      setState(() {
        cityName = data['name'];
        temperature = data['main']['temp'].toDouble();
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'].toDouble();
        condition = data['weather'][0]['description'];
        iconCode = data['weather'][0]['icon'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: loadWeather,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // City Name
                        Text(
                          cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Weather Icon from OpenWeatherMap
                        Image.network(
                          'https://openweathermap.org/img/wn/$iconCode@2x.png',
                          width: 100,
                          height: 100,
                        ),

                        // Temperature
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w200,
                          ),
                        ),

                        // Condition
                        Text(
                          condition.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Humidity and Wind Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Humidity
                            Column(
                              children: [
                                const Icon(Icons.water_drop,
                                    color: Colors.lightBlueAccent),
                                const SizedBox(height: 6),
                                Text(
                                  '$humidity%',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                const Text(
                                  'Humidity',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),

                            const SizedBox(width: 60),

                            // Wind Speed
                            Column(
                              children: [
                                const Icon(Icons.air, color: Colors.lightBlueAccent),
                                const SizedBox(height: 6),
                                Text(
                                  '${windSpeed.toStringAsFixed(1)} m/s',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                const Text(
                                  'Wind',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Refresh Button
                        ElevatedButton.icon(
                          onPressed: loadWeather,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}