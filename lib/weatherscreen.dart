import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'Utils/additonal info.dart'; // Fixed import typo
import 'Utils/hourly_forcast.dart';  // Fixed import typo

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool isLoading = true;
  double currentTemp = 0;
  String currentSkyCondition = '';
  String cityName = 'London';
  double currentHumidity = 0;
  double currentWindSpeed = 0;
  double currentPressure = 0;
  List<dynamic> hourlyData = [];

  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<void> getCurrentWeather() async {
    try {
      String apiKey = 'b3cc1086469d2f17ac0c0efbc79d47fd';
      final response = await http.get(
          Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey")
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentTemp = data['main']['temp'] - 273.15; // Convert from Kelvin to Celsius
          isLoading = false;
          currentSkyCondition = data['weather'][0]['main'];
          currentPressure = data['main']['pressure'] / 100;
          currentWindSpeed = data['wind']['speed'];
          currentHumidity = data['main']['humidity'].toDouble();
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }

      final hourlyResponse = await http.get(
          Uri.parse("https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey")
      );

      if (hourlyResponse.statusCode == 200) {
        final hourlyDataJson = jsonDecode(hourlyResponse.body);
        setState(() {
          hourlyData = hourlyDataJson['list'];
        });
      } else {
        print('Error: ${hourlyResponse.statusCode}');
      }

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    print('getCurrentWeather');
  }

  IconData getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.grain;
      case 'Snow':
        return Icons.ac_unit;
      case 'Mist':
      case 'Fog':
        return Icons.cloud_queue;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName[0].toUpperCase() + cityName.substring(1),
          style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              getCurrentWeather();
              print('Refresh');
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      Text(
                        '${currentTemp.toStringAsFixed(2)} C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        currentSkyCondition == 'Clouds' ||
                            currentSkyCondition == 'Mist' ||
                            currentSkyCondition == 'Rain'
                            ? Icons.cloud
                            : Icons.wb_sunny,
                        size: 64,
                        color: currentSkyCondition == 'Clouds' ||
                            currentSkyCondition == 'Mist' ||
                            currentSkyCondition == 'Rain'
                            ? Colors.blueGrey
                            : Colors.yellow[700],
                      ),
                      SizedBox(height: 16),
                      Text(
                        currentSkyCondition,
                        style: TextStyle(fontSize: 24),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: hourlyData.map((data) {
                  var time = DateTime.parse(data['dt_txt']);
                  var formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  var temp = data['main']['temp'] - 273.15;
                  var condition = data['weather'][0]['main'];
                  var icon = getWeatherIcon(condition);

                  return HourlyForecastCard(
                    time: formattedTime,
                    icon: icon,
                    temperature: temp,
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Additional Info',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AdditionalInfo(
                    title: 'Wind',
                    value: currentWindSpeed.toStringAsFixed(2),
                    icon: Icons.air),
                AdditionalInfo(
                    title: 'Humidity',
                    value: currentHumidity.toStringAsFixed(2),
                    icon: Icons.water),
                AdditionalInfo(
                    title: 'Pressure',
                    value: currentPressure.toStringAsFixed(2),
                    icon: Icons.arrow_downward),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Change Location'),
                        content: TextField(
                          controller: cityController,
                          decoration: InputDecoration(hintText: 'Enter City Name'),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                cityName = cityController.text;
                                isLoading = true;
                              });
                              getCurrentWeather();
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Change Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
