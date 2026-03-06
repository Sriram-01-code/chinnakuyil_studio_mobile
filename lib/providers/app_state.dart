import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  String _uid = '';
  String _displayName = '';
  String _role = ''; 
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isAutoScrolling = true;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _hasSeenBirthdayPopup = false;
  bool _hasSeenWalkthrough = false;

  String get uid => _uid;
  String get displayName => _displayName;
  String get role => _role;
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get isAutoScrolling => _isAutoScrolling;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get hasSeenBirthdayPopup => _hasSeenBirthdayPopup;
  bool get hasSeenWalkthrough => _hasSeenWalkthrough;

  void setRecording(bool recording) {
    _isRecording = recording;
    if (!recording) _isPaused = false;
    notifyListeners();
  }

  void setPaused(bool paused) {
    _isPaused = paused;
    notifyListeners();
  }

  void setAutoScrolling(bool scroll) {
    _isAutoScrolling = scroll;
    notifyListeners();
  }

  void setBirthdayPopupSeen(bool seen) async {
    _hasSeenBirthdayPopup = seen;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenBirthdayPopup', seen);
    notifyListeners();
  }

  void setWalkthroughSeen(bool seen) async {
    _hasSeenWalkthrough = seen;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWalkthrough', seen);
    notifyListeners();
  }

  Future<bool> authenticate(String firstName, String dob) async {
    final name = firstName.trim().toLowerCase();
    final cleanDob = dob.trim();

    if (name == 'sriram' && (cleanDob == '01/04/2003' || cleanDob == '1/4/2003')) {
      _uid = 'admin_sriram';
      _displayName = 'Sriram';
      _role = 'admin';
    } else if ((name == 'sathiya' || name == 'sathiyasri' || name == 'chinnakuyil' || name == 'sathi') && (cleanDob == '04/03/2003' || cleanDob == '4/3/2003')) {
      _uid = 'artist_sathiya';
      _displayName = 'Sathiya';
      _role = 'artist';
    } else {
      return false;
    }

    _isAuthenticated = true;
    final user = UserModel(uid: _uid, firstName: firstName, dateOfBirth: dob, role: _role, displayName: _displayName, createdAt: DateTime.now());
    await FirebaseService.saveUser(user);
    await FirebaseService.saveSession(_uid, _displayName, _role);
    notifyListeners();
    return true;
  }

  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        final session = await FirebaseService.getSession();
        if (session['uid'] != null) {
          _uid = session['uid']!;
          _displayName = session['firstName'] ?? 'User';
          _role = session['role'] ?? 'artist';
          _isAuthenticated = true;
          _hasSeenBirthdayPopup = prefs.getBool('hasSeenBirthdayPopup') ?? false;
          _hasSeenWalkthrough = prefs.getBool('hasSeenWalkthrough') ?? false;
        }
      }
    } catch (e) {
      debugPrint('Session load error: $e');
      _isAuthenticated = false;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _uid = '';
    _displayName = '';
    _role = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  String get stageGreeting {
    if (_uid == 'artist_sathiya') return "Which melody shall we bring to life today, Chinnakuyil? 🎤";
    return "Curating the finest tracks for the studio.";
  }

  String get recordingSuccessMessage {
    if (_uid == 'artist_sathiya') return "That was absolutely magical, Sathiya! Your voice is a gift. The recording is safely in your vault. ✨";
    return "Recording saved successfully. Another masterpiece added.";
  }

  String get recordingButtonText {
    if (_isRecording) return "Capture Magic";
    return "Step to Mic";
  }
}
