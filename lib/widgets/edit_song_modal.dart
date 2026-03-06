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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.song.title);
    _lyrics = TextEditingController(text: widget.song.lyrics);
  }

  Future<void> _updateSong() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song title cannot be empty.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      await FirebaseFirestore.instance.collection('songs').doc(widget.song.songId).update({
        'title': _title.text.trim(),
        'lyrics': _lyrics.text.trim(),
      });
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.song.title} updated successfully!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFB76E79),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update song: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              Text("REFINE TRACK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _title, 
                style: const TextStyle(color: Colors.white), 
                decoration: const InputDecoration(
                  labelText: "Song Title", 
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFB76E79))),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lyrics, 
                maxLines: 5, 
                style: const TextStyle(color: Colors.white), 
                decoration: const InputDecoration(
                  labelText: "Lyrics", 
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFB76E79))),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB76E79), 
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: _isSaving ? null : _updateSong,
                child: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("UPDATE STAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}