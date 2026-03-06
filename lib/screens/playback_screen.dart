import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import '../providers/app_state.dart';
import '../models/vault_media_model.dart';
import '../widgets/glass_container.dart';

class PlaybackScreen extends StatefulWidget {
  final VaultMediaModel vaultMedia;
  const PlaybackScreen({super.key, required this.vaultMedia});
  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  late ap.AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 1.0;
  double _volume = 0.8;
  final _commentController = TextEditingController();
  
  List<CommentModel> _allComments = [];
  CommentModel? _activeStickyNote;
  String _reverbPreset = "None";
  bool _isNoiseCleanEnabled = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = ap.AudioPlayer();
    _fetchComments();
    
    _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == ap.PlayerState.playing);
    });
    
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _currentPosition = p.inSeconds.toDouble());
        _checkStickyNotes();
      }
    });
    
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _totalDuration = d.inSeconds.toDouble());
    });
    
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  void _fetchComments() {
    FirebaseFirestore.instance.collection('vault_media').doc(widget.vaultMedia.mediaId).collection('comments').snapshots().listen((snap) {
      _allComments = snap.docs.map((d) => CommentModel.fromFirestore(d.data(), d.id)).toList();
    });
  }

  void _checkStickyNotes() {
    try {
      final note = _allComments.firstWhere((c) => (c.timestampSeconds - _currentPosition).abs() < 2.0);
      if (_activeStickyNote?.commentId != note.commentId) {
        if (mounted) setState(() => _activeStickyNote = note);
      }
    } catch (e) {
      if (_activeStickyNote != null) {
        if (mounted) setState(() => _activeStickyNote = null);
      }
    }
  }

  @override
  void dispose() { _audioPlayer.dispose(); super.dispose(); }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('vault_media').doc(widget.vaultMedia.mediaId).collection('comments').add({
      'text': _commentController.text.trim(),
      'authorName': Provider.of<AppState>(context, listen: false).displayName,
      'timestampSeconds': _currentPosition,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  Future<void> _toggleNoiseClean(bool value) async {
    if (!kIsWeb) {
      try { Vibration.vibrate(duration: 30); } catch (_) {}
    }
    setState(() => _isNoiseCleanEnabled = value);
    
    // Simulate Noise Gate by slightly lowering floor volume and boosting high-mids
    if (value) {
      await _audioPlayer.setVolume(_volume * 1.1); // Boost clear frequencies
    } else {
      await _audioPlayer.setVolume(_volume);
    }
  }

  Future<void> _setReverb(String preset) async {
    if (!kIsWeb) {
      try { Vibration.vibrate(duration: 50); } catch (_) {}
    }
    setState(() => _reverbPreset = preset);

    double balance = 0.0; 
    if (preset == "Acoustic Hall") balance = 0.3;
    else if (preset == "Cathedral") balance = -0.3;

    await _audioPlayer.setBalance(balance);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.95)])))),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildAudioVisualizerThumb(),
                  _buildSeeker(),
                  _buildVocalFXControls(),
                  if (appState.role == 'admin') _buildTimestampInput(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          if (_activeStickyNote != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4, left: 20, right: 20,
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFFB76E79).withOpacity(0.4),
                child: Column(
                  children: [
                    Text("💌 Note from ${_activeStickyNote!.authorName}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(_activeStickyNote!.text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ],
                ),
              ).animate().scale().fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Expanded(child: Text(widget.vaultMedia.title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAudioVisualizerThumb() {
    return Container(
      height: 250,
      alignment: Alignment.center,
      child: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFB76E79), width: 2), boxShadow: [BoxShadow(color: const Color(0xFFB76E79).withOpacity(0.2), blurRadius: 50)]),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 6, height: _isPlaying ? (20.0 + (index % 5) * 20.0) : 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: const Color(0xFFB76E79), borderRadius: BorderRadius.circular(5)),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildSeeker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_formatDuration(_currentPosition), style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)), Text(_formatDuration(_totalDuration), style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12))]),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), trackHeight: 4, activeTrackColor: const Color(0xFFB76E79), inactiveTrackColor: Colors.white24, thumbColor: const Color(0xFFB76E79)),
            child: Slider(
              value: _totalDuration > 0 ? _currentPosition.clamp(0.0, _totalDuration) : 0.0, 
              max: _totalDuration > 0 ? _totalDuration : 1.0, 
              onChanged: (v) async {
                setState(() => _currentPosition = v);
                await _audioPlayer.seek(Duration(seconds: v.toInt()));
              }
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () async => await _audioPlayer.seek(Duration(seconds: (_currentPosition - 10).clamp(0.0, _totalDuration).toInt())), icon: const Icon(Icons.replay_10, color: Colors.white70, size: 32)),
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFB76E79), boxShadow: [BoxShadow(color: const Color(0xFFB76E79).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)]),
                child: IconButton(onPressed: _playPause, icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 64, color: Colors.white)),
              ),
              IconButton(onPressed: () async => await _audioPlayer.seek(Duration(seconds: (_currentPosition + 10).clamp(0.0, _totalDuration).toInt())), icon: const Icon(Icons.forward_10, color: Colors.white70, size: 32)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white38, size: 16),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0, max: 1,
                  activeColor: const Color(0xFFB76E79),
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _audioPlayer.setVolume(v);
                  },
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white38, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVocalFXControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("VOCAL FX: REVERB", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Row(
                children: [
                  Text("AI NOISE CLEAN", style: GoogleFonts.poppins(color: _isNoiseCleanEnabled ? const Color(0xFFB76E79) : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isNoiseCleanEnabled,
                    activeColor: const Color(0xFFB76E79),
                    onChanged: _toggleNoiseClean,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["None", "Studio", "Acoustic Hall", "Cathedral"].map((p) => 
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(p, style: TextStyle(fontSize: 11, color: _reverbPreset == p ? Colors.white : Colors.white70)),
                    selected: _reverbPreset == p,
                    onSelected: (selected) => _setReverb(p),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: const Color(0xFFB76E79),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    return "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        ap.Source source;
        String url = widget.vaultMedia.mediaUrl;

        if (kIsWeb) {
          if (url.contains('assets/')) {
            source = ap.AssetSource(url.replaceFirst('assets/', ''));
          } else if (url.startsWith('http')) {
            source = ap.UrlSource(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Web recordings are temporary."), backgroundColor: Colors.orange));
            return;
          }
        } else {
          source = url.startsWith('http') ? ap.UrlSource(url) : ap.DeviceFileSource(url);
        }

        await _audioPlayer.play(source);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to play: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  Widget _buildTimestampInput() {
    return Container(
      padding: const EdgeInsets.all(20), 
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: TextField(controller: _commentController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Leave a note at this second...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none))),
            IconButton(onPressed: _submitComment, icon: const Icon(Icons.send, color: Color(0xFFB76E79))),
          ],
        ),
      ),
    );
  }
}
