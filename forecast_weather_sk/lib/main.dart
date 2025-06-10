import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For Timer and debounce

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize window manager and set size
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(500, 800), // width: 500, height: 800
    minimumSize: Size(500, 800),
    maximumSize: Size(500, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather UI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();
  
  String city = "New York";
  String temperature = "";
  String condition = "";
  bool isLoading = false;
  int aqi = 0; // Air Quality Index
  int humidity = 0; // Humidity percentage
  List<dynamic> suggestions = []; // To store city suggestions
  Timer? _debounce; // For debouncing API calls
  
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      fetchSuggestions(query);
    });
  }

  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions = []);
      return;
    }
    final apiKey = '7c445a460fcf435fb9313332251006';
    final url = Uri.parse('https://api.weatherapi.com/v1/search.json?key=$apiKey&q=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        suggestions = jsonDecode(response.body);
      });
    }
  }
  
  
  
  
  
  
  
  
  Future<void> fetchWeather(String cityName) async {
    const apiKey = '7c445a460fcf435fb9313332251006'; // Replace with your real key
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName&aqi=yes');

    setState(() => isLoading = true);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          city = data['location']['name'];
          temperature = data['current']['temp_f'].toString();
          condition = data['current']['condition']['text'];
          double pm25 = (data['current']['air_quality']['pm2_5'] as num).toDouble();
          aqi = pm25ToAqi(pm25);
          humidity = data['current']['humidity'] as int;
        });
      } else {
        setState(() {
          city = "Not Found";
          temperature = "";
          condition = "";
          aqi = -1;
          humidity = -1;
        });
      }
    } catch (e) {
      setState(() {
        city = "Error";
        temperature = "";
        condition = "";
        aqi = -1;
        humidity = -1;
      });
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  int pm25ToAqi(double pm25) {
    // US EPA breakpoints for PM2.5
    final breakpoints = [
      [0.0, 12.0, 0, 50],
      [12.1, 35.4, 51, 100],
      [35.5, 55.4, 101, 150],
      [55.5, 150.4, 151, 200],
      [150.5, 250.4, 201, 300],
      [250.5, 350.4, 301, 400],
      [350.5, 500.4, 401, 500],
    ];

    for (var bp in breakpoints) {
      if (pm25 >= bp[0] && pm25 <= bp[1]) {
        return (((bp[3] - bp[2]) / (bp[1] - bp[0])) * (pm25 - bp[0]) + bp[2]).round();
      }
    }
    return 500; // Max AQI
  }
  String getAqiCategory(int aqi) {
    if (aqi <= 50) return "Good";
    if (aqi <= 100) return "Moderate";
    if (aqi <= 150) return "Unhealthy for Sensitive Groups";
    if (aqi <= 200) return "Unhealthy";
    if (aqi <= 300) return "Very Unhealthy";
    return "Hazardous";
  }

  IconData getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sunny')) return Icons.wb_sunny_rounded;
    if (lower.contains('cloud')) return Icons.cloud_rounded;
    if (lower.contains('rain')) return Icons.water_drop_rounded;
    if (lower.contains('snow')) return Icons.ac_unit_rounded;
    return Icons.wb_cloudy_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onChanged: onSearchChanged,
                  onSubmitted: fetchWeather,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Search for a city",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                if(suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: suggestions.map((suggestion) {
                        return ListTile(
                          title: Text(suggestion['name']),
                          onTap: () {
                            _controller.text = suggestion['name'];
                            fetchWeather(suggestion['name']);
                            setState(() => suggestions = []);
                          },
                        );
                      }).toList(),
                    ),
                  ),



















                const SizedBox(height: 40),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: window.physicalSize.width * 0.95,
                        height: window.physicalSize.height * 0.8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          elevation: 8,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  getWeatherIcon(condition),
                                  size: 100,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  city,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  condition,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // temperature text color changes based on temperature (> 80°F is red, otherwise blue)
                                Text(
                                  temperature.isEmpty
                                      ? 'N/A'
                                      : double.parse(temperature) > 80
                                          ? '$temperature°F'
                                          : '$temperature°F',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1.5,
                                    // make sure to consider when temperature is empty

                                    color: temperature.isEmpty
                                        ? Colors.black54
                                        : double.parse(temperature) > 80
                                            ? Colors.redAccent
                                            : Colors.blueAccent,
                                    
                                  ),
                                ),
                                
                                
                                
                                
                                // textbox saying air quality index
                                const SizedBox(height: 16),
                                const Text(
                                  'Air Quality Index',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),

                                // AQI bar with 6 equal segments for each category
                                const SizedBox(height: 8),
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(9), // Adjust radius as needed
                                      child: Row(
                                        children: [
                                          // 6 equal segments for AQI categories, with rounded corners on ends
                                          Expanded(
                                            child: Container(
                                              height: 18,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.horizontal(left: Radius.circular(9)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 18,
                                              color: Colors.yellow,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 18,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 18,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 18,
                                              color: Colors.purple,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 18,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF7E0023),
                                                borderRadius: BorderRadius.horizontal(right: Radius.circular(9)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // AQI marker
                                    Positioned(
                                      left: (aqi.clamp(0, 500) / 500.0) * MediaQuery.of(context).size.width * 0.95, // adjust width if needed
                                      child: Icon(Icons.arrow_drop_down, color: Colors.black, size: 28),
                                    ),
                                  ],
                                ),

                                // AQI value text
                                const SizedBox(height: 8),  
                                Text(
                                  aqi == -1 ? 'N/A' : '$aqi',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 16),
                                // textbox saying humidity
                                const Text(
                                  'Humidity',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                
                                // humidity bar with blue color
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: humidity / 100, // Example value
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                                
                                // if humidity is -1, show N/A, otherwise show humidity value




                                const SizedBox(height: 8),
                                Text(
                                  humidity == -1 ? 'N/A' : '$humidity%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                
                                


                                
                                






                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
