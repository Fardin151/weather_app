import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_service.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

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
  final TextEditingController _searchController = TextEditingController();
  List<String> favoriteCities = [];

  @override
  void initState() {
    super.initState();
    loadWeather();
    loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final position = await _weatherService.getCurrentLocation();
      final data = await _weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

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

  Future<void> searchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await _weatherService.fetchWeatherByCity(city);

      setState(() {
        cityName = data['name'];
        temperature = data['main']['temp'].toDouble();
        feelsLike = data['main']['feels_like'].toDouble();
        tempMin = data['main']['temp_min'].toDouble();
        tempMax = data['main']['temp_max'].toDouble();
        humidity = data['main']['humidity'];
        windSpeed = data['wind']['speed'].toDouble();
        condition = data['weather'][0]['description'];
        iconCode = data['weather'][0]['icon'];
        sunrise = _formatTime(data['sys']['sunrise']);
        sunset = _formatTime(data['sys']['sunset']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    favoriteCities = prefs.getStringList('favorites') ?? [];
  });
}

Future<void> toggleFavorite() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    if (favoriteCities.contains(cityName)) {
      favoriteCities.remove(cityName);
    } else {
      favoriteCities.add(cityName);
    }
  });
  await prefs.setStringList('favorites', favoriteCities);
}

Future<void> loadCityFromFavorite(String city) async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    final data = await _weatherService.fetchWeatherByCity(city);
    setState(() {
      cityName = data['name'];
      temperature = data['main']['temp'].toDouble();
      feelsLike = data['main']['feels_like'].toDouble();
      tempMin = data['main']['temp_min'].toDouble();
      tempMax = data['main']['temp_max'].toDouble();
      humidity = data['main']['humidity'];
      windSpeed = data['wind']['speed'].toDouble();
      condition = data['weather'][0]['description'];
      iconCode = data['weather'][0]['icon'];
      sunrise = _formatTime(data['sys']['sunrise']);
      sunset = _formatTime(data['sys']['sunset']);
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = e.toString();
      isLoading = false;
    });
  }
}

  List<Color> _getGradientColors(String condition) {
  final c = condition.toLowerCase();

  if (c.contains('clear')) {
    return [const Color(0xFFf7971e), const Color(0xFFffd200), const Color(0xFFf7971e)];
  } else if (c.contains('cloud')) {
    return [const Color(0xFF4b6cb7), const Color(0xFF606c88), const Color(0xFF3f4c6b)];
  } else if (c.contains('rain') || c.contains('drizzle')) {
    return [const Color(0xFF1c3b5a), const Color(0xFF2c5364), const Color(0xFF203a43)];
  } else if (c.contains('thunder') || c.contains('storm')) {
    return [const Color(0xFF0f0c29), const Color(0xFF302b63), const Color(0xFF24243e)];
  } else if (c.contains('snow')) {
    return [const Color(0xFFe0eafc), const Color(0xFFcfdef3), const Color(0xFFa8c0ff)];
  } else if (c.contains('mist') || c.contains('fog') || c.contains('haze')) {
    return [const Color(0xFF606c88), const Color(0xFF3f4c6b), const Color(0xFF606c88)];
  } else {
    return [const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f3460)];
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
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? _getGradientColors(condition)
              : [
                  const Color.fromARGB(255, 11, 15, 19),
                  const Color.fromARGB(255, 0, 1, 2),
                  const Color.fromARGB(255, 0, 0, 0),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
        child: SafeArea(
          child: isLoading

              // ── LOADING STATE ──
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )

              // ── ERROR STATE ──
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
                          ),
                        ],
                      ),
                    )

              // ── SUCCESS STATE ──
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const SizedBox(height: 20),

                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Search city...',
                                      hintStyle: const TextStyle(color: Colors.white54),
                                      filled: true,
                                      fillColor: Colors.white12,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Colors.white54),
                                    ),
                                    onSubmitted: (_) => searchCity(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: searchCity,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white24,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Go'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // City Name + Favorite Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cityName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: toggleFavorite,
                                icon: Icon(
                                  favoriteCities.contains(cityName)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.redAccent,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),

                          // Favorites List
                          if (favoriteCities.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'FAVORITES',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: favoriteCities.map((city) {
                                      return GestureDetector(
                                        onTap: () => loadCityFromFavorite(city),
                                        child: Chip(
                                          label: Text(city),
                                          backgroundColor: Colors.white24,
                                          labelStyle: const TextStyle(color: Colors.white),
                                          deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                                          onDeleted: () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            setState(() {
                                              favoriteCities.remove(city);
                                            });
                                            await prefs.setStringList('favorites', favoriteCities);
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 10),

                          IconButton(
                            icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              final isDark =
                                  Theme.of(context).brightness != Brightness.dark;
                              context.read<ThemeProvider>().toggleTheme(isDark);
                            },
                          ),

                          // Weather Icon
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
                                  const Icon(Icons.water_drop,
                                      color: Colors.lightBlueAccent),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$humidity%',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  const Text('Humidity',
                                      style: TextStyle(color: Colors.white54)),
                                ],
                              ),

                              const SizedBox(width: 30),

                              // Wind Speed
                              Column(
                                children: [
                                  const Icon(Icons.air,
                                      color: Colors.lightBlueAccent),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${windSpeed.toStringAsFixed(1)} m/s',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  const Text('Wind',
                                      style: TextStyle(color: Colors.white54)),
                                ],
                              ),

                              const SizedBox(width: 30),

                              // Sunrise
                              Column(
                                children: [
                                  const Icon(Icons.wb_twilight,
                                      color: Colors.orangeAccent),
                                  const SizedBox(height: 6),
                                  Text(
                                    sunrise,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  const Text('Sunrise',
                                      style: TextStyle(color: Colors.white54)),
                                ],
                              ),

                              const SizedBox(width: 30),

                              // Sunset
                              Column(
                                children: [
                                  const Icon(Icons.nights_stay,
                                      color: Colors.orangeAccent),
                                  const SizedBox(height: 6),
                                  Text(
                                    sunset,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  const Text('Sunset',
                                      style: TextStyle(color: Colors.white54)),
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

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}