import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _achievementService.initAchievements();
    final list = await _achievementService.getAchievements();
    setState(() {
      _achievements = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                final isUnlocked = achievement.isUnlocked;
                
                return Card(
                  color: isUnlocked ? Theme.of(context).cardColor : Theme.of(context).disabledColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(achievement.iconName),
                          size: 48,
                          color: isUnlocked ? Colors.orange : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'footprint': return Icons.directions_walk;
      case 'calendar': return Icons.calendar_today;
      case 'crown': return Icons.emoji_events;
      case 'shield': return Icons.shield;
      default: return Icons.star;
    }
  }
}
