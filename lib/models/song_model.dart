import 'package:cloud_firestore/cloud_firestore.dart';

class SongModel {
  final String songId;
  final String title;
  final String lyrics;
  final String sourceType;
  final String audioSource;
  final String addedBy;
  final bool isSuggested;
  final String mood;
  final DateTime createdAt;

  // Enhanced Fields
  final String movie;
  final String composer;
  final String originalArtist;
  final String difficulty;
  final List<String> searchKeywords;

  SongModel({
    required this.songId,
    required this.title,
    required this.lyrics,
    required this.sourceType,
    required this.audioSource,
    required this.addedBy,
    this.isSuggested = false,
    this.mood = 'Melody',
    required this.createdAt,
    // Enhanced
    this.movie = '',
    this.composer = '',
    this.originalArtist = '',
    this.difficulty = 'Easy',
    this.searchKeywords = const [],
  });

  factory SongModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return SongModel(
      songId: documentId,
      title: data['title'] ?? '',
      lyrics: data['lyrics'] ?? '',
      sourceType: data['sourceType'] ?? 'youtube',
      audioSource: data['audioSource'] ?? '',
      addedBy: data['addedBy'] ?? '',
      isSuggested: data['isSuggested'] ?? false,
      mood: data['mood'] ?? 'Melody',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Enhanced
      movie: data['movie'] ?? '',
      composer: data['composer'] ?? '',
      originalArtist: data['originalArtist'] ?? '',
      difficulty: data['difficulty'] ?? 'Easy',
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'lyrics': lyrics,
      'sourceType': sourceType,
      'audioSource': audioSource,
      'addedBy': addedBy,
      'isSuggested': isSuggested,
      'mood': mood,
      'createdAt': FieldValue.serverTimestamp(),
      // Enhanced
      'movie': movie,
      'composer': composer,
      'originalArtist': originalArtist,
      'difficulty': difficulty,
      'searchKeywords': searchKeywords,
    };
  }
}
