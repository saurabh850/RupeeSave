import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../services/streak_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _streakService = StreakService();
  Map<DateTime, int>? _datasets;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _streakService.getAllLogs();
    setState(() {
      _datasets = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consistency Map'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _datasets == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Journey',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Green days build your streak. Keep it up!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).cardTheme.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center( // Center the calendar
                        child: HeatMapCalendar(
                          datasets: _datasets,
                          colorMode: ColorMode.color,
                          defaultColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          textColor: isDark ? Colors.white : Colors.black,
                          showColorTip: false,
                          margin: const EdgeInsets.all(4), // Add margin between blocks
                          size: 30, // Fixed block size
                          fontSize: 12,
                          colorsets: const {
                            1: Color(0xFF2ECC71), // Good (Green)
                            2: Color(0xFFFF6B6B), // Bad (Red)
                          },
                          onClick: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(value.toString().split(' ')[0])),
                            );
                          },
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
