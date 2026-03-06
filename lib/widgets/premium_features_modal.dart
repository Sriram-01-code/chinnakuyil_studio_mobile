import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';

class PremiumFeaturesModal extends StatelessWidget {
  const PremiumFeaturesModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.diamond, color: Color(0xFFB76E79), size: 32),
                const SizedBox(width: 12),
                Text('PREMIUM FEATURES', style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB76E79),
                )),
              ],
            ),
            const SizedBox(height: 20),
            _buildFeatureItem('🎵', 'AI-Powered Vocal Analysis', 'Get real-time feedback on your pitch and tone'),
            _buildFeatureItem('🎼', 'Smart Song Suggestions', 'Personalized recommendations based on your voice'),
            _buildFeatureItem('🎤', 'Multi-Track Recording', 'Layer harmonies and create professional mixes'),
            _buildFeatureItem('📊', 'Performance Analytics', 'Track your progress with detailed insights'),
            _buildFeatureItem('🎨', 'Custom Themes', 'Personalize your studio experience'),
            _buildFeatureItem('☁️', 'Unlimited Cloud Storage', 'Never worry about running out of space'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Maybe Later', style: GoogleFonts.poppins()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement premium upgrade
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB76E79),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Upgrade Now', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
