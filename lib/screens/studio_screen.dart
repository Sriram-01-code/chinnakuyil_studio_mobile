import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import '../providers/app_state.dart';
import '../services/mobile_storage_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/heart_burst.dart';

class StudioScreen extends StatefulWidget {
  final SongModel song;
  const StudioScreen({super.key, required this.song});
  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  late YoutubePlayerController _youtubeController;
  late AudioRecorder _audioRecorder;
  late ScrollController _lyricController;
  late ConfettiController _successController;
  
  bool _isCountingDown = false;
  int _countdownNumber = 3;
  bool _isUploading = false;
  bool _isRecording = false;
  int _activeLyricIndex = 0;
  List<String> _lyricsLines = [];
  Timer? _autoScrollTimer;
  bool _autoScrollEnabled = false;
  
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  double _scrollSpeed = 1.0; 
  double _playbackVolume = 80.0;
  bool _isLyricsZoomed = false;
  bool _isVideoPlaying = false;
  double _videoDuration = 1.0;
  double _currentVideoPos = 0.0;
  Timer? _videoTrackingTimer;

  double _amplitudeValue = 0.0;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  @override
  void initState() {
    super.initState();
    _lyricController = ScrollController();
    _audioRecorder = AudioRecorder();
    _successController = ConfettiController(duration: const Duration(seconds: 3));
    _lyricsLines = widget.song.lyrics.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    final videoId = YoutubePlayerController.convertUrlToId(widget.song.audioSource) ?? '';
    
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true, 
        showFullscreenButton: true, 
        mute: false,
      ),
    );

    _youtubeController.videoStateStream.listen((state) {
      if (mounted) setState(() => _isVideoPlaying = state == PlayerState.playing);
    });

    _startVideoTracking();
    _lyricController.addListener(_handleManualScroll);
  }

  void _startVideoTracking() {
    _videoTrackingTimer?.cancel();
    _videoTrackingTimer = Timer.periodic(const Duration(milliseconds: 500), (t) async {
      if (!mounted) { t.cancel(); return; }
      final duration = await _youtubeController.duration;
      final current = await _youtubeController.currentTime;
      if (mounted) {
        setState(() {
          _videoDuration = duration > 0 ? duration : 1.0;
          _currentVideoPos = current;
        });
      }
    });
  }

  void _handleManualScroll() {
    if (!_autoScrollEnabled && _lyricController.hasClients) {
      const itemHeight = 70.0;
      final topIndex = (_lyricController.offset / itemHeight).floor();

      if (topIndex != _activeLyricIndex && topIndex >= 0 && topIndex < _lyricsLines.length) {
        setState(() => _activeLyricIndex = topIndex);
      }
    }
  }

  @override
  void dispose() {
    _youtubeController.close();
    _audioRecorder.dispose();
    _lyricController.dispose();
    _successController.dispose();
    _autoScrollTimer?.cancel();
    _recordingTimer?.cancel();
    _videoTrackingTimer?.cancel();
    _amplitudeSubscription?.cancel();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() {
      _autoScrollEnabled = !_autoScrollEnabled;
      if (_autoScrollEnabled) {
        _startAutoScroll();
      } else {
        _autoScrollTimer?.cancel();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _centerLyricSmoothly(_activeLyricIndex);
    final interval = Duration(milliseconds: (4000 / _scrollSpeed).round());
    _autoScrollTimer = Timer.periodic(interval, (timer) {
      if (!mounted || !_autoScrollEnabled) {
        timer.cancel();
        return;
      }
      if (_activeLyricIndex < _lyricsLines.length - 1) {
        setState(() => _activeLyricIndex++);
        _centerLyricSmoothly(_activeLyricIndex);
      } else {
        timer.cancel();
        setState(() => _autoScrollEnabled = false);
      }
    });
  }

  void _centerLyricSmoothly(int lyricIndex) {
    if (!_lyricController.hasClients) return;
    const itemHeight = 70.0;
    final targetOffset = lyricIndex * itemHeight;
    
    _lyricController.animateTo(
      targetOffset.clamp(0.0, _lyricController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _startAmplitudeMonitoring() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
      if (mounted) setState(() => _amplitudeValue = (amp.current + 60).clamp(0, 60) / 60);
    });
  }

  Future<void> _startRecording() async {
    bool hasPermission = false;
    try { hasPermission = await _audioRecorder.hasPermission(); } catch (_) {}
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone access is required.')));
      return;
    }
    setState(() => _isCountingDown = true);
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdownNumber = i);
      if (!kIsWeb) {
        try { await Vibration.vibrate(duration: 50); } catch (_) {}
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _isCountingDown = false);
    try { 
      _youtubeController.setVolume(_playbackVolume.round());
      _youtubeController.playVideo(); 
    } catch (_) {}
    final recordingPath = kIsWeb ? '' : '${(await getTemporaryDirectory()).path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
    try {
      await _audioRecorder.start(const RecordConfig(), path: recordingPath);
      setState(() { _isRecording = true; _recordingDuration = Duration.zero; });
      _startRecordingTimer();
      _startAmplitudeMonitoring();
      if (!_autoScrollEnabled) _toggleAutoScroll();
    } catch (_) {}
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording) setState(() => _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1));
      else timer.cancel();
    });
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    _youtubeController.pauseVideo();
    _autoScrollTimer?.cancel();
    _recordingTimer?.cancel();
    _amplitudeSubscription?.cancel();
    setState(() { _isRecording = false; _autoScrollEnabled = false; _amplitudeValue = 0.0; });
    if (!kIsWeb) {
      try { Vibration.vibrate(pattern: [0, 100, 50, 100]); } catch (_) {}
    }
    _successController.play();
    _showSuccessDialog(recordingPath: path);
  }

  void _showSuccessDialog({String? recordingPath}) async {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFFB76E79), size: 60),
              const SizedBox(height: 20),
              const Text("Session Complete", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(appState.recordingSuccessMessage, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true); 
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB76E79), padding: const EdgeInsets.all(15)),
                  child: const Text("View in Vault", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Record Another", style: TextStyle(color: Colors.white54))),
            ],
          ),
        ),
      ),
    );
  }

  void _showScrollSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text("Lyrics Scroll Speed", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _scrollSpeed,
                min: 0.5, max: 2.5, divisions: 8,
                activeColor: const Color(0xFFB76E79),
                onChanged: (val) {
                  setDialogState(() => _scrollSpeed = val);
                  setState(() { _scrollSpeed = val; if (_autoScrollEnabled) _startAutoScroll(); });
                },
              ),
              Text("${_scrollSpeed.toStringAsFixed(1)}x", style: const TextStyle(color: Color(0xFFB76E79), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done", style: TextStyle(color: Color(0xFFB76E79))))],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
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
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _buildVideoPlayer(),
                      const SizedBox(height: 20),
                      _buildLyricsSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildRecordingControls(appState)),
          Align(alignment: Alignment.topCenter, child: HeartBurst(controller: _successController)),
          if (_isCountingDown) _buildCountdownOverlay(),
          if (_isUploading) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20), onPressed: () => Navigator.pop(context)),
          const Expanded(child: Column(children: [Text("RECORDING SESSION", style: TextStyle(color: Color(0xFFB76E79), letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 10)), Text("NOW SINGING", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)]))
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black, boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Transform.scale(
            scale: 1.3, 
            child: YoutubePlayer(controller: _youtubeController),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildLyricsSection() {
    const double itemHeight = 70.0;
    const double viewportHeight = 350.0; 
    return Container(
      height: viewportHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LYRICS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Row(
                  children: [
                    IconButton(icon: Icon(_isLyricsZoomed ? Icons.zoom_out : Icons.zoom_in, color: Colors.white54, size: 18), onPressed: () => setState(() => _isLyricsZoomed = !_isLyricsZoomed)),
                    GestureDetector(onTap: _showScrollSpeedDialog, child: Container(padding: const EdgeInsets.all(6), margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.speed, color: Colors.white54, size: 14))),
                    GestureDetector(onTap: _toggleAutoScroll, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _autoScrollEnabled ? const Color(0xFFB76E79) : Colors.white10, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(_autoScrollEnabled ? Icons.pause_circle_outline : Icons.play_circle_outline, color: Colors.white, size: 14), const SizedBox(width: 4), Text(_autoScrollEnabled ? "Auto-Scrolling" : "Manual", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification && notification.dragDetails != null && _autoScrollEnabled) {
                  setState(() { _autoScrollEnabled = false; _autoScrollTimer?.cancel(); });
                }
                return true;
              },
              child: ListView.builder(
                controller: _lyricController,
                padding: const EdgeInsets.only(bottom: viewportHeight - itemHeight),
                itemCount: _lyricsLines.length,
                itemExtent: itemHeight,
                itemBuilder: (context, index) {
                  final isActive = index == _activeLyricIndex;
                  return AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: isActive ? (_isLyricsZoomed ? 34 : 26) : (_isLyricsZoomed ? 24 : 18),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      height: 1.5,
                      shadows: isActive ? [Shadow(color: const Color(0xFFB76E79).withOpacity(0.8), blurRadius: 15)] : null,
                    ),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Center(child: Text(_lyricsLines[index], maxLines: 2, overflow: TextOverflow.ellipsis))),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingControls(AppState appState) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 20),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.white38, size: 16),
                Expanded(child: Slider(value: _playbackVolume, min: 0, max: 100, activeColor: const Color(0xFFB76E79), inactiveColor: Colors.white10, onChanged: (v) { setState(() => _playbackVolume = v); _youtubeController.setVolume(v.round()); })),
                const Icon(Icons.volume_up, color: Colors.white38, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRecording) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(_formatDuration(_recordingDuration), style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')).animate().fadeIn().scale()),
              const SizedBox(width: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isRecording)
                    Container(
                      width: 80 + (_amplitudeValue * 60), height: 80 + (_amplitudeValue * 60),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFB76E79).withOpacity(0.15), boxShadow: [BoxShadow(color: const Color(0xFFB76E79).withOpacity(0.3 * _amplitudeValue), blurRadius: 20 + (_amplitudeValue * 30), spreadRadius: 5 + (_amplitudeValue * 15))]),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds, curve: Curves.easeInOut),
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(height: 75, width: 75, decoration: BoxDecoration(shape: BoxShape.circle, color: _isRecording ? Colors.red : const Color(0xFFB76E79), boxShadow: [BoxShadow(color: (_isRecording ? Colors.red : const Color(0xFFB76E79)).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]), child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 35)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(appState.recordingButtonText, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() => Positioned.fill(child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Center(child: Text("$_countdownNumber", style: const TextStyle(fontSize: 100, color: Color(0xFFB76E79), fontWeight: FontWeight.bold)))));
  Widget _buildProcessingOverlay() => Positioned.fill(child: Container(color: Colors.black87, child: const Center(child: CircularProgressIndicator(color: Color(0xFFB76E79)))));
}
