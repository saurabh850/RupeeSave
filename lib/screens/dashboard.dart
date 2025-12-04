import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../services/user_service.dart';
import '../services/streak_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/user.dart';
import '../models/streak.dart';
import '../models/streak.dart';
import '../models/day_log.dart';
import '../services/cushion_service.dart';
import 'log_spend_modal.dart';
import 'log_spend_modal.dart';
import 'settings.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'achievements_screen.dart';
import '../services/achievement_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _userService = UserService();
  final _streakService = StreakService();
  final _cushionService = CushionService();
  final _achievementService = AchievementService();
  
  User? _user;
  Streak? _dailyStreak;
  DayLog? _todayLog;
  int _cushionCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _userService.getUser();
    final streak = await _streakService.getDailyStreak();
    final log = await _streakService.getTodayLog();
    final cushions = await _cushionService.getAvailableCushions();
    
    // Initialize achievements in background
    _achievementService.initAchievements();

    if (mounted) {
      setState(() {
        _user = user;
        _dailyStreak = streak;
        _todayLog = log;
        _cushionCount = cushions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_user?.name ?? "Saver"}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep building that streak!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons (Scrollable Row for small screens)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildHeaderButton(
                            context,
                            icon: Icons.emoji_events_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderButton(
                            context,
                            icon: Icons.bar_chart_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen())),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderButton(
                            context,
                            icon: Icons.calendar_month_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderButton(
                            context,
                            icon: Icons.dark_mode_outlined,
                            onTap: () {
                              final provider = Provider.of<ThemeProvider>(context, listen: false);
                              provider.toggleTheme(!provider.isDarkMode);
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderButton(
                            context,
                            icon: Icons.settings_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Streak Card
                _buildStreakCard(),
                
                const SizedBox(height: 24),

                // Today's Status
                _buildTodayStatus(),

                const SizedBox(height: 32),
                      width: double.infinity,
                      height: 56,
                      child: Center(
                        child: Text(
                          "Log Today's Spend",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Add bottom padding for scrolling
                const SizedBox(height: 48), // Increased padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              '${_dailyStreak?.current ?? 0}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Day Streak',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_dailyStreak?.current ?? 0) / 21, // Phase A target
              backgroundColor: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              'Target: 21 Days',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chair, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '$_cushionCount Cushions',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatus() {
    if (_todayLog == null) {
      return Card(
        color: Theme.of(context).cardTheme.color, // Use theme card color
        child: ListTile(
          leading: Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
          title: Text(
            'Not logged yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Limit: ${_user?.currencySymbol}${_user?.baseDailyLimit}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final isGood = _todayLog!.status == 'good';
    // Use semi-transparent colors for status to work in both modes
    final goodColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    final badColor = Theme.of(context).colorScheme.error.withOpacity(0.1);
    final goodIcon = Theme.of(context).colorScheme.primary;
    final badIcon = Theme.of(context).colorScheme.error;

    return Card(
      color: isGood ? goodColor : badColor,
      child: ListTile(
        leading: Icon(
          isGood ? Icons.check_circle : Icons.warning,
          color: isGood ? goodIcon : badIcon,
        ),
        title: Text(
          isGood ? 'Under Limit' : 'Over Limit',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isGood ? goodIcon : badIcon,
          ),
        ),
        subtitle: Text(
          'Spent: ${_user?.currencySymbol}${_todayLog!.spent} / ${_user?.currencySymbol}${_todayLog!.limitApplied}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildHeaderButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).iconTheme.color),
        onPressed: onTap,
      ),
    );
  }
}
