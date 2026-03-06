import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_state.dart';
import '../models/vault_media_model.dart';
import '../services/mobile_storage_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/walkthrough_modals.dart';
import 'playback_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});
  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _searchQuery = "";
  String _sortBy = "recent";

  List<VaultMediaModel> _filterAndSort(List<VaultMediaModel> media) {
    Iterable<VaultMediaModel> filtered = media;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => item.title.toLowerCase().contains(_searchQuery));
    }
    List<VaultMediaModel> result = filtered.toList();
    if (_sortBy == 'name') {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 70,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: const GlassContainer(
              borderRadius: BorderRadius.zero,
              child: SizedBox.shrink(),
            ),
            centerTitle: true,
            title: Text("THE VAULT", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
                onPressed: () => showDialog(context: context, builder: (_) => const WalkthroughModal()),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: "Search your archives...", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Color(0xFFB76E79))),
                    ),
                    const Divider(color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSortChip("Newest", _sortBy == 'recent', () => setState(() => _sortBy = 'recent')),
                        const SizedBox(width: 10),
                        _buildSortChip("Name", _sortBy == 'name', () => setState(() => _sortBy = 'name')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vault_media').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Color(0xFFB76E79))));
              var mediaItems = snapshot.data!.docs.map((d) => VaultMediaModel.fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList();
              final processed = _filterAndSort(mediaItems);
              
              if (processed.isEmpty) {
                return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text("Your recordings will appear here ✨", style: TextStyle(color: Colors.white24)))));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildVaultCard(processed[index], index),
                  childCount: processed.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, bool isSelected, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11)),
      onPressed: onTap,
      backgroundColor: isSelected ? const Color(0xFFB76E79) : Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildVaultCard(VaultMediaModel media, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onLongPress: () => _showManagementMenu(context, media),
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaybackScreen(vaultMedia: media))),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFB76E79), Color(0xFFD4AF37)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: const Color(0xFFB76E79).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: const Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35)),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2000.ms, color: Colors.white30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(media.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("By ${media.uploaderName}", style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.5)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white30, size: 22), onPressed: () => _shareMedia(media)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  void _shareMedia(VaultMediaModel media) async {
    if (media.localRecordingId != null && !kIsWeb) {
      await MobileStorageService.shareRecording(media.localRecordingId!);
    } else {
      await Share.share('Listen to my recording from Chinnakuyil Studio: ${media.title}');
    }
  }

  void _showManagementMenu(BuildContext context, VaultMediaModel media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Manage Recording', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_note, color: Colors.blueAccent),
              title: const Text("Edit Title", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(media);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text("Delete permanently", style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance.collection('vault_media').doc(media.mediaId).delete();
                if (media.localRecordingId != null && !kIsWeb) {
                  await MobileStorageService.deleteRecording(media.localRecordingId!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(VaultMediaModel media) {
    final controller = TextEditingController(text: media.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Rename Masterpiece", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "New title", hintStyle: TextStyle(color: Colors.white24))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('vault_media').doc(media.mediaId).update({'title': controller.text.trim()});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
