import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/glass_container.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_nameController.text.trim().isEmpty || _dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both fields ✨'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.authenticate(_nameController.text, _dobController.text);
    
    if (!mounted) return;
    
    if (!success) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! Check the name and birthday again ✨'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 20 : 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic_external_on_rounded, size: 30, color: Colors.white),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chinnakuyil',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                  Text(
                                    'Studio',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white70,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GlassContainer(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Private Stage Access', 
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your unique stage awaits...', 
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: Colors.white60, 
                                  fontStyle: FontStyle.italic
                                )
                              ),
                              const SizedBox(height: 30),
                              TextField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFB76E79), size: 20),
                                  hintText: 'Sriram / Sathi',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB76E79))),
                                ),
                              ),
                              const SizedBox(height: 25),
                              TextField(
                                controller: _dobController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Birthday (DD/MM/YYYY)',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFFB76E79), size: 20),
                                  hintText: '04/03/2003',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB76E79))),
                                ),
                                onChanged: _formatDOB,
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB76E79),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 8,
                                    shadowColor: const Color(0xFFB76E79).withOpacity(0.5),
                                  ),
                                  child: _isLoading 
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text('Enter Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _formatDOB(String value) {
    String cleanedText = value.replaceAll('/', '');
    if (cleanedText.isEmpty) return;
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedText)) return;
    String formattedText = '';
    if (cleanedText.length >= 1) {
      final dayLength = cleanedText.length >= 2 ? 2 : cleanedText.length;
      formattedText += cleanedText.substring(0, dayLength);
    }
    if (cleanedText.length >= 3) {
      formattedText += '/';
      final monthStart = 2;
      final monthEnd = cleanedText.length >= 4 ? 4 : cleanedText.length;
      if (monthEnd > monthStart) {
        formattedText += cleanedText.substring(monthStart, monthEnd);
      }
    }
    if (cleanedText.length >= 5) {
      formattedText += '/';
      final yearStart = 4;
      final yearEnd = cleanedText.length >= 8 ? 8 : cleanedText.length;
      if (yearEnd > yearStart) {
        formattedText += cleanedText.substring(yearStart, yearEnd);
      }
    }
    if (value != formattedText) {
      _dobController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }
}
