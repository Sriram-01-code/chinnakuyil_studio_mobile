import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../widgets/glass_container.dart';

class VocalCoachWidget extends StatefulWidget {
  final bool isRecording;
  const VocalCoachWidget({super.key, required this.isRecording});

  @override
  State<VocalCoachWidget> createState() => _VocalCoachWidgetState();
}

class _VocalCoachWidgetState extends State<VocalCoachWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final Random _random = Random();

  final List<String> _idleTips = [
    "Warm up your voice with scales first ✨",
    "Keep your posture straight for better breath",
    "Sriram's favorite songs are waiting for you! 🎵",
    "A glass of water will help your vocal cords.",
    "Ready to sound like a professional, Chinnakuyil?",
  ];

  final List<String> _recordingTips = [
    "Beautifully sung! Keep going. ❤️",
    "Perfect breath control! 🎤",
    "Sriram is going to love this note! ✨",
    "Your voice is sounding so lush and clear.",
    "That melody was just perfect! 🎼",
  ];

  int _currentTipIndex = 0;
  double _simulatedPitch = 0.5;
  double _simulatedBreath = 0.5;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Change tips and simulate meters
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _currentTipIndex = _random.nextInt(widget.isRecording ? _recordingTips.length : _idleTips.length);
          if (widget.isRecording) {
            _simulatedPitch = 0.7 + _random.nextDouble() * 0.3;
            _simulatedBreath = 0.6 + _random.nextDouble() * 0.4;
          } else {
            _simulatedPitch = 0.3;
            _simulatedBreath = 0.3;
          }
        });
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      Icons.auto_awesome,
                      color: widget.isRecording ? const Color(0xFFB76E79) : Colors.white24,
                      size: 20,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                widget.isRecording ? 'LIVE FEEDBACK' : 'VOCAL TIPS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: widget.isRecording ? const Color(0xFFB76E79) : Colors.white54,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              widget.isRecording ? _recordingTips[_currentTipIndex] : _idleTips[_currentTipIndex],
              key: ValueKey("${widget.isRecording}$_currentTipIndex"),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.isRecording) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildIndicator('PITCH', _simulatedPitch, Colors.greenAccent),
                const SizedBox(width: 15),
                _buildIndicator('BREATH', _simulatedBreath, Colors.blueAccent),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
