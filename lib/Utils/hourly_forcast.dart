import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final IconData icon;
  final double temperature;

  const HourlyForecastCard({
    super.key,
    required this.time,
    required this.icon,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Container(
            width: 120,
            child: Column(
              children: [
                Text(time, style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Icon(icon, size: 32, color: Colors.orange),
                SizedBox(height: 8),
                Text('${temperature.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
