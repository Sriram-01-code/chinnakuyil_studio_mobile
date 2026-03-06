import 'package:cloud_firestore/cloud_firestore.dart';

class MediaModel {
  final String id;
  final String title;
  final String mediaUrl;
  final String mediaType;
  final String uploadedBy;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final int? duration;

  const MediaModel({
    required this.id,
    required this.title,
    required this.mediaUrl,
    required this.mediaType,
    required this.uploadedBy,
    required this.createdAt,
    this.thumbnailUrl,
    this.duration,
  });

  factory MediaModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MediaModel(
      id: id,
      title: data['title'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'audio',
      uploadedBy: data['uploadedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      thumbnailUrl: data['thumbnailUrl'],
      duration: data['duration'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'uploadedBy': uploadedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (duration != null) 'duration': duration,
    };
  }

  MediaModel copyWith({
    String? id,
    String? title,
    String? mediaUrl,
    String? mediaType,
    String? uploadedBy,
    DateTime? createdAt,
    String? thumbnailUrl,
    int? duration,
  }) {
    return MediaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
    );
  }
}
