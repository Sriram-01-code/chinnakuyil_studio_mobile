import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CloudStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadRecording(String filePath, String fileName) async {
    try {
      if (kIsWeb) return null; // Storage upload not supported in this simplified web flow
      
      final file = File(filePath);
      if (!await file.exists()) return null;

      final ref = _storage.ref().child('recordings/$fileName');
      final uploadTask = ref.putFile(file);
      
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Cloud Storage Upload Error: $e');
      return null;
    }
  }

  static Future<void> deleteRecording(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Cloud Storage Delete Error: $e');
    }
  }
}
