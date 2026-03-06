import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'glass_container.dart';

class AddSongModal extends StatefulWidget {
  const AddSongModal({super.key});

  @override
  State<AddSongModal> createState() => _AddSongModalState();
}

class _AddSongModalState extends State<AddSongModal> {
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _urlController = TextEditingController();
  
  String _sourceType = 'youtube';
  String _mood = 'Melody';
  bool _isSuggested = false;

  final List<String> _moods = ['Melody', 'Romantic', 'Sad', 'Classical', 'Peppy', 'Folk'];

  Future<void> _saveSong() async {
    // Enhanced validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a song title.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an audio/video URL.'), backgroundColor: Colors.red),
      );
      return;
    }

    // Basic URL validation
    final url = _urlController.text.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid URL starting with http:// or https://'), backgroundColor: Colors.orange),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      await FirebaseFirestore.instance.collection('songs').add({
        'title': _titleController.text.trim(),
        'lyrics': _lyricsController.text.trim(),
        'sourceType': _sourceType,
        'audioSource': url,
        'addedBy': appState.displayName,
        'isSuggested': _isSuggested,
        'mood': _mood,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_titleController.text.trim()} added to stage!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFB76E79),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add song: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Curate New Track', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              TextField(controller: _titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 10),
              
              TextField(controller: _lyricsController, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Lyrics', labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                value: _mood,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Mood/Genre', labelStyle: TextStyle(color: Colors.white70)),
                items: _moods.map((mood) => DropdownMenuItem(value: mood, child: Text(mood))).toList(),
                onChanged: (val) => setState(() => _mood = val!),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _sourceType,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Source Type', labelStyle: TextStyle(color: Colors.white70)),
                items: const [
                  DropdownMenuItem(value: 'youtube', child: Text('YouTube Link')),
                  DropdownMenuItem(value: 'mp3', child: Text('MP3 URL')),
                ],
                onChanged: (val) => setState(() => _sourceType = val!),
              ),
              const SizedBox(height: 10),
              
              TextField(controller: _urlController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Audio/Video URL', labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 15),

              // SRIRAM'S PICK TOGGLE - ADMIN ONLY
              if (appState.uid == 'admin_sriram')
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white54),
                  child: CheckboxListTile(
                    title: Text("Sriram's Pick ✨", style: GoogleFonts.poppins(color: Colors.white)),
                    subtitle: Text("Highlight this song for her", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
                    value: _isSuggested,
                    activeColor: const Color(0xFFB76E79),
                    checkColor: Colors.white,
                    onChanged: (val) => setState(() => _isSuggested = val ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB76E79),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveSong,
                child: Text('Save to Stage', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
