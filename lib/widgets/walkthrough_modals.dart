import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';
import '../providers/app_state.dart';
import '../widgets/glass_container.dart';

class WalkthroughModal extends StatefulWidget {
  const WalkthroughModal({super.key});
  @override
  State<WalkthroughModal> createState() => _WalkthroughModalState();
}

class _WalkthroughModalState extends State<WalkthroughModal> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<WalkthroughItem> _walkthroughItems = [
    WalkthroughItem(
      title: 'Welcome to your Stage 🎵', 
      description: 'Chinnakuyil Studio is your private sanctuary for music. Here, your voice is the only instrument that matters. Every track is a masterpiece in waiting.', 
      emoji: '🎤',
      tooltip: 'Tap the mic to start your session'
    ),
    WalkthroughItem(
      title: 'The Stage (Library) 🎼', 
      description: 'Explore a curated collection of classics. Use the Ilayaraja filter to find the Maestro\'s best, or sort by challenge level to push your boundaries.', 
      emoji: '🎹',
      tooltip: 'Long press tracks if you are an Admin to edit'
    ),
    WalkthroughItem(
      title: 'The Hub (Recording) 🎙️', 
      description: 'The Hub features our advanced lyrics scroller. It keeps your current line centered and shows what\'s next. The "Nightingale Aura" reacts to your voice live!', 
      emoji: '✨',
      tooltip: 'Adjust scroll speed using the Lens icon'
    ),
    WalkthroughItem(
      title: 'The Vault (Archives) 💎', 
      description: 'All your magic is stored here. Listen back to your growth, organize your takes, and share your favorites with your loved ones.', 
      emoji: '📀',
      tooltip: 'Group takes by song title automatically'
    ),
    WalkthroughItem(
      title: 'Premium Vocal FX 🎚️', 
      description: 'Enhance your voice with simulated Studio, Hall, or Cathedral reverb. Use "AI Noise Clean" to make your vocals crystal clear before sharing.', 
      emoji: '🌈',
      tooltip: 'Apply effects live during playback'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (!kIsWeb) { try { await Vibration.vibrate(duration: 50); } catch (_) {} }
    if (_currentPage < _walkthroughItems.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else { _completeWalkthrough(); }
  }

  void _completeWalkthrough() {
    Provider.of<AppState>(context, listen: false).setWalkthroughSeen(true);
    if (!kIsWeb) { try { Vibration.vibrate(pattern: [0, 100, 50, 100]); } catch (_) {} }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        backgroundColor: Colors.black.withOpacity(0.85),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Studio Guide ✨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(onPressed: _completeWalkthrough, icon: const Icon(Icons.close, color: Colors.white24)),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _walkthroughItems.length,
                itemBuilder: (context, index) {
                  final item = _walkthroughItems[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 70)).animate().scale(curve: Curves.elasticOut),
                      const SizedBox(height: 24),
                      Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFB76E79)), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(item.description, style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.6), textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 14),
                            const SizedBox(width: 8),
                            Text(item.tooltip, style: const TextStyle(fontSize: 10, color: Colors.white38, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _walkthroughItems.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  height: 4, width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(color: _currentPage == index ? const Color(0xFFB76E79) : Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB76E79), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(_currentPage == _walkthroughItems.length - 1 ? 'Start Singing 🎤' : 'Next Step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkthroughItem {
  final String title, description, emoji, tooltip;
  WalkthroughItem({required this.title, required this.description, required this.emoji, required this.tooltip});
}

class BirthdayPopupModal extends StatelessWidget {
  final VoidCallback onComplete;
  const BirthdayPopupModal({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 60)).animate().scale(duration: 1000.ms),
            const SizedBox(height: 20),
            const Text('A Belated Celebration... 🎂', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'serif'), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Text(
              "Happy Birthday, Chinnakuyil! ✨\n\nI know I'm a little late, but a voice as magical as yours deserves to be celebrated every single day. I built this studio specifically for you—a dedicated, private sanctuary where your melodies can be captured, archived, and cherished forever.\n\nThis isn't just an app; it's your personal stage. Whether you're singing a timeless Ilayaraja classic or exploring new melodies, this studio will breathe with you. May this belated gift bring as much joy to your heart as your music brings to everyone who hears it.",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.7), 
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).setBirthdayPopupSeen(true);
                  Navigator.pop(context);
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB76E79),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 8,
                  shadowColor: const Color(0xFFB76E79).withOpacity(0.5),
                ),
                child: const Text("Enter My Studio ✨", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(curve: Curves.easeOutBack).fadeIn();
  }
}
