import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileStorageService {
  static const String _dbName = 'chinnakuyil_studio.db';
  static const String _recordingsDir = 'recordings';
  
  static Database? _database;
  static String? _recordingsPath;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    
    await _requestPermissions();
    await _initializeDirectories();
    await _initializeDatabase();
  }

  static Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await [
      Permission.microphone,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

  static Future<void> _initializeDirectories() async {
    final appDir = await getApplicationDocumentsDirectory();
    _recordingsPath = path.join(appDir.path, _recordingsDir);
    await Directory(_recordingsPath!).create(recursive: true);
  }

  static Future<void> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE local_recordings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            file_path TEXT NOT NULL,
            file_size INTEGER,
            duration INTEGER,
            created_at INTEGER NOT NULL,
            song_title TEXT,
            uploader_name TEXT
          )
        ''');
      },
    );
  }

  static Future<String> saveRecording({
    required String title,
    required String filePath,
    required int fileSize,
    required int duration,
    String? songTitle,
    String? uploaderName,
  }) async {
    if (_database == null) throw Exception('Database not initialized');
    
    final id = await _database!.insert('local_recordings', {
      'title': title,
      'file_path': filePath,
      'file_size': fileSize,
      'duration': duration,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'song_title': songTitle,
      'uploader_name': uploaderName ?? 'Artist',
    });
    return id.toString();
  }

  static Future<void> deleteRecording(String recordingId) async {
    if (_database == null) return;
    try {
      final res = await _database!.query('local_recordings', where: 'id = ?', whereArgs: [int.parse(recordingId)]);
      if (res.isNotEmpty) {
        final filePath = res.first['file_path'] as String;
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        await _database!.delete('local_recordings', where: 'id = ?', whereArgs: [int.parse(recordingId)]);
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  // NUCLEAR SFX SCANNER
  static Future<void> prebundleAssets() async {
    try {
      // 1. Get the list of all assets from the manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // 2. Filter for files in assets/sfx/
      final sfxPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/sfx/'))
          .where((String key) => !key.contains('.gitkeep'))
          .toList();

      if (sfxPaths.isEmpty) {
        debugPrint("No SFX files found in assets/sfx/");
        return;
      }

      final vaultCollection = FirebaseFirestore.instance.collection('vault_media');

      for (String assetPath in sfxPaths) {
        final fileName = path.basename(assetPath);
        final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a)$'), '').replaceAll('_', ' ');
        
        // 3. Check if already in Firestore
        final existing = await vaultCollection.where('mediaUrl', isEqualTo: assetPath).limit(1).get();
        
        if (existing.docs.isEmpty) {
          await vaultCollection.add({
            'title': "✨ $title",
            'mediaUrl': assetPath,
            'mediaType': 'audio',
            'uploaderName': 'System Archive',
            'createdAt': FieldValue.serverTimestamp(),
            'isLocal': true,
            'isWeb': kIsWeb,
          });
          debugPrint("Synced SFX to Vault: $title");
        }
      }
    } catch (e) {
      debugPrint("SFX Scan error: $e");
    }
  }

  static Future<void> shareRecording(String recordingId) async {
    if (_database == null) return;
    final res = await _database!.query('local_recordings', where: 'id = ?', whereArgs: [int.parse(recordingId)]);
    if (res.isNotEmpty) {
      final filePath = res.first['file_path'] as String;
      await Share.shareXFiles([XFile(filePath)], text: 'Check out this studio recording!');
    }
  }
}
