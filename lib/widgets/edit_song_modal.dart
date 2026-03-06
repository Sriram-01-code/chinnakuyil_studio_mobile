import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/song_model.dart';
import 'glass_container.dart';

class EditSongModal extends StatefulWidget {
  final SongModel song;
  const EditSongModal({super.key, required this.song});
  @override
  State<EditSongModal> createState() => _EditSongModalState();
}

class _EditSongModalState extends State<EditSongModal> {
  late TextEditingController _title;
  late TextEditingController _lyrics;
  late TextEditingController _movie;
  late TextEditingController _composer;
  late TextEditingController _originalArtist;
  late TextEditingController _url;
  
  String _mood = 'Melody';
  String _difficulty = 'Easy';
  bool _isSuggested = false;
  bool _isSaving = false;

  final List<String> _moods = ['Melody', 'Romantic', 'Sad', 'Classical', 'Peppy', 'Folk', 'Dance'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Masterpiece'];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.song.title);
    _lyrics = TextEditingController(text: widget.song.lyrics);
    _movie = TextEditingController(text: widget.song.movie);
    _composer = TextEditingController(text: widget.song.composer);
    _originalArtist = TextEditingController(text: widget.song.originalArtist);
    _url = TextEditingController(text: widget.song.audioSource);
    _mood = widget.song.mood;
    _difficulty = widget.song.difficulty;
    _isSuggested = widget.song.isSuggested;
  }

  Future<void> _updateSong() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('songs').doc(widget.song.songId).update({
        'title': _title.text.trim(),
        'lyrics': _lyrics.text.trim(),
        'movie': _movie.text.trim(),
        'composer': _composer.text.trim(),
        'originalArtist': _originalArtist.text.trim(),
        'audioSource': _url.text.trim(),
        'mood': _mood,
        'difficulty': _difficulty,
        'isSuggested': _isSuggested,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("REFINE MASTERPIECE", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              _buildField(_title, "Song Title"),
              _buildField(_movie, "Movie"),
              _buildField(_composer, "Composer"),
              _buildField(_originalArtist, "Original Artist"),
              _buildField(_url, "Audio/Video URL"),
              
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDropdown("Mood", _mood, _moods, (v) => setState(() => _mood = v!))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDropdown("Level", _difficulty, _difficulties, (v) => setState(() => _difficulty = v!))),
                ],
              ),
              
              CheckboxListTile(
                title: const Text("Sriram's Pick ✨", style: TextStyle(color: Colors.white70, fontSize: 14)),
                value: _isSuggested,
                onChanged: (v) => setState(() => _isSuggested = v!),
                activeColor: const Color(0xFFB76E79),
                contentPadding: EdgeInsets.zero,
              ),
              
              _buildField(_lyrics, "Lyrics", maxLines: 5),
              
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB76E79), minimumSize: const Size(double.infinity, 50)),
                onPressed: _isSaving ? null : _updateSong,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller, maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white38),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFB76E79))),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value, dropdownColor: Colors.black87,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white38)),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }
}
