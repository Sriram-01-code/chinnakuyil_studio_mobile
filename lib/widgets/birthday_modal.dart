import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'glass_container.dart';

class BirthdayModal extends StatelessWidget {
  const BirthdayModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎂', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Happy Birthday, Chinnakuyil! ✨',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "I wanted to give you something truly special this year. No more scattered voice notes, lost karaoke links, or forgetting the lyrics halfway through.\n\nI built this space entirely for you. It's your personal studio to sing, record, and keep all your masterpieces in one place. Your voice deserves its own stage.\n\nPick a song, hit record, and let the music flow.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              "- Sriram ❤️",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFB76E79), fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB76E79),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).setBirthdayPopupSeen(true);
                  Navigator.pop(context);
                },
                child: Text("Let's Sing 🎤", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}