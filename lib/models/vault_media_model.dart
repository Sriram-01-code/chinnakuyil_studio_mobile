import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VaultMediaModel {
  final String mediaId;
  final String title;
  final String mediaUrl;
  final String mediaType;
  final String uploaderName;
  final DateTime createdAt;
  final String? localRecordingId;
  final bool isLocal;
  final bool isWeb;

  VaultMediaModel({
    required this.mediaId, 
    required this.title, 
    required this.mediaUrl,
    required this.mediaType, 
    required this.uploaderName, 
    required this.createdAt,
    this.localRecordingId,
    this.isLocal = false,
    this.isWeb = false,
  });

  factory VaultMediaModel.fromFirestore(Map<String, dynamic> data, String id) {
    return VaultMediaModel(
      mediaId: id, 
      title: data['title'] ?? '', 
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'audio', 
      uploaderName: data['uploaderName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      localRecordingId: data['localRecordingId'],
      isLocal: data['isLocal'] ?? false,
      isWeb: data['isWeb'] ?? false,
    );
  }
}

class CommentModel {
  final String commentId;
  final String text;
  final String authorName;
  final double timestampSeconds; // NEW: For Sticky Notes
  final DateTime createdAt;

  CommentModel({
    required this.commentId, required this.text, required this.authorName,
    required this.timestampSeconds, required this.createdAt,
  });

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CommentModel(
      commentId: id, text: data['text'] ?? '', authorName: data['authorName'] ?? '',
      timestampSeconds: (data['timestampSeconds'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}