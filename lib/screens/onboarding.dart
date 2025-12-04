import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_service.dart';
import '../utils/theme.dart';
import 'dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  final _nameController = TextEditingController(); // New
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userService = UserService();
  int _step = 0;

  String _currency = 'INR'; // Default

  @override
  void dispose() {
    _limitController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (_limitController.text.isNotEmpty && _nameController.text.isNotEmpty) {
        setState(() => _step = 1);
      }
    } else {
      if (_formKey.currentState!.validate()) {
        _completeOnboarding();
      }
    }
  }

  Future<void> _completeOnboarding() async {
    final limit = int.parse(_limitController.text);
    final password = _passwordController.text;

    await _userService.createUser(
      name: _nameController.text,
      baseDailyLimit: limit,
      password: password,
      currency: _currency,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        // Header
                        Text(
                          _step == 0 ? "Let's set a goal." : "Secure your habit.",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _step == 0
                              ? "What is your daily spending limit for unnecessary items?"
                              : "Create a password to lock this limit. Changing it later will require this password.",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 48), // Increased spacing
                        
                        // Form
                        Form(
                          key: _formKey,
                          child: _step == 0 ? _buildLimitInput() : _buildPasswordInput(),
                        ),
                        
                        const Spacer(),
                        Center(
                          child: Text(
                            'v1.1',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Navigation
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            child: Text(_step == 0 ? "Next" : "Get Started"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLimitInput() {
    return Column(
      children: [
        // Currency Selector
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Rupee (₹)'),
                selected: _currency == 'INR',
                onSelected: (selected) {
                  if (selected) setState(() => _currency = 'INR');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Euro (€)'),
                selected: _currency == 'EUR',
                onSelected: (selected) {
                  if (selected) setState(() => _currency = 'EUR');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: 'Your Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _limitController,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            prefixText: _currency == 'EUR' ? '€ ' : '₹ ',
            hintText: _currency == 'EUR' ? 'Daily Limit (e.g. 5)' : 'Daily Limit (e.g. 150)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password (PIN)',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.length < 4) {
              return 'Min 4 characters';
            }
            return null;
          },
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
