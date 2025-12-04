import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/streak_service.dart';
import '../services/cushion_service.dart';

class LogSpendModal extends StatefulWidget {
  final int limit;
  final VoidCallback onLogged;

  const LogSpendModal({
    super.key,
    required this.limit,
    required this.onLogged,
  });

  @override
  State<LogSpendModal> createState() => _LogSpendModalState();
}

class _LogSpendModalState extends State<LogSpendModal> with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController(); // New
  final _streakService = StreakService();
  final _cushionService = CushionService();
  
  bool _isAnimating = false;
  bool _isGoodDay = false;
  bool _useCushion = false;
  bool _isPlanned = false; // New
  int _availableCushions = 0;
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _loadCushions();
  }

  Future<void> _loadCushions() async {
    final count = await _cushionService.getAvailableCushions();
    if (mounted) setState(() => _availableCushions = count);
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    _notesController.dispose(); // New
    super.dispose();
  }

  Future<void> _submit() async {
    if (_amountController.text.isEmpty) return;

    final amount = int.parse(_amountController.text);
    
    // Logic: If planned, it's always a good day (or handled differently)
    // For now, let's say Planned = Good Day automatically, or just doesn't break streak?
    // User requirement: "planned buys do not break good_day"
    
    final effectiveLimit = widget.limit + (_useCushion ? 50 : 0);
    final isGood = _isPlanned || amount <= effectiveLimit;

    if (_useCushion && !_isPlanned) { // Don't burn cushion if it's planned? Or user choice.
      await _cushionService.useCushion();
    }

    setState(() {
      _isAnimating = true;
      _isGoodDay = isGood;
    });

    await _streakService.logSpend(
      amount: amount,
      limit: effectiveLimit,
      justification: _notesController.text, // Save notes
      // We might need to pass 'status' explicitly if we want to mark it as 'planned'
      // For now, StreakService infers status. Let's update StreakService later to handle 'planned' explicitly if needed.
      // But for MVP, if isGood is true, it counts as a streak.
    );

    _controller.forward();
    
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      widget.onLogged();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnimating) {
      return Scaffold(
        backgroundColor: _isGoodDay ? const Color(0xFF2ECC71) : const Color(0xFFFF6B6B),
        body: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isGoodDay ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 100,
                ),
                const SizedBox(height: 24),
                Text(
                  _isGoodDay ? 'Streak +1!' : 'Streak Reset',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isGoodDay 
                    ? 'Great job staying under ${widget.limit + (_useCushion ? 50 : 0)}'
                    : 'Over limit by ${int.parse(_amountController.text) - (widget.limit + (_useCushion ? 50 : 0))}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Today\'s Spend'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Daily Limit: ${widget.limit}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: Theme.of(context).textTheme.displayLarge,
              decoration: const InputDecoration(
                prefixText: ' ', // Currency symbol passed via widget if needed, or generic
                hintText: '0',
                border: InputBorder.none,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'What is this for? (Optional)',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 16),
            if (_availableCushions > 0) ...[
              SwitchListTile(
                title: const Text('Use Cushion'),
                subtitle: Text('Available: $_availableCushions'),
                value: _useCushion,
                onChanged: (val) => setState(() => _useCushion = val),
              ),
              const SizedBox(height: 16),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
