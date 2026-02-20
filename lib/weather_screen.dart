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
  double feelsLike = 0;
  double tempMin = 0;
  double tempMax = 0;
  String sunrise = '';
  String sunset = '';
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
        feelsLike = data['main']['feels_like'].toDouble();
        tempMin = data['main']['temp_min'].toDouble();
        tempMax = data['main']['temp_max'].toDouble();
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'].toDouble();
        sunrise = _formatTime(data['sys']['sunrise']);
        sunset = _formatTime(data['sys']['sunset']);
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

  String _formatTime(int unixTime) {
    final dt = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
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
                        // Condition
                        Text(
                          condition.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Feels Like
                        Text(
                          'Feels like ${feelsLike.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Min / Max
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '↓ ${tempMin.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              '↑ ${tempMax.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Humidity, Wind, Sunrise, Sunset Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Humidity
                            Column(
                              children: [
                                const Icon(Icons.water_drop, color: Colors.lightBlueAccent),
                                const SizedBox(height: 6),
                                Text(
                                  '$humidity%',
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const Text('Humidity', style: TextStyle(color: Colors.white54)),
                              ],
                            ),

                            const SizedBox(width: 40),

                            // Wind Speed
                            Column(
                              children: [
                                const Icon(Icons.air, color: Colors.lightBlueAccent),
                                const SizedBox(height: 6),
                                Text(
                                  '${windSpeed.toStringAsFixed(1)} m/s',
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const Text('Wind', style: TextStyle(color: Colors.white54)),
                              ],
                            ),

                            const SizedBox(width: 40),

                            // Sunrise
                            Column(
                              children: [
                                const Icon(Icons.wb_twilight, color: Colors.orangeAccent),
                                const SizedBox(height: 6),
                                Text(
                                  sunrise,
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const Text('Sunrise', style: TextStyle(color: Colors.white54)),
                              ],
                            ),

                            const SizedBox(width: 40),

                            // Sunset
                            Column(
                              children: [
                                const Icon(Icons.nights_stay, color: Colors.orangeAccent),
                                const SizedBox(height: 6),
                                Text(
                                  sunset,
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const Text('Sunset', style: TextStyle(color: Colors.white54)),
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