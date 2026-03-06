import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'stage_screen.dart';
import 'vault_screen.dart';
import '../widgets/walkthrough_modals.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startOnboarding());
  }

  void _startOnboarding() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.uid == 'artist_sathiya' && !appState.hasSeenBirthdayPopup) {
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (_) => BirthdayPopupModal(onComplete: () => _checkWalkthrough())
      );
    } else {
      _checkWalkthrough();
    }
  }

  void _checkWalkthrough() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.hasSeenWalkthrough) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const WalkthroughModal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      StageScreen(onSwitchToVault: () => _onTabTapped(1)), 
      const VaultScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.9)])))),
          SafeArea(
            child: Column(
              children: [
                Expanded(child: IndexedStack(index: _currentIndex, children: pages)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFB76E79),
          unselectedItemColor: Colors.white24,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_none_rounded), 
              activeIcon: Icon(Icons.mic_rounded),
              label: 'THE STAGE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined), 
              activeIcon: Icon(Icons.library_music_rounded),
              label: 'THE VAULT',
            ),
          ],
        ),
      ),
    );
  }
}
