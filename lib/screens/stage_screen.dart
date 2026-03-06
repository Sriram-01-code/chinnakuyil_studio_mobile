import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/add_song_modal.dart';
import '../widgets/edit_song_modal.dart';
import '../widgets/walkthrough_modals.dart';
import '../providers/app_state.dart';
import '../models/song_model.dart';
import 'studio_screen.dart';

class StageScreen extends StatefulWidget {
  final VoidCallback onSwitchToVault;
  const StageScreen({super.key, required this.onSwitchToVault});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeSort; // null = A-Z default
  bool _isMaestroFilter = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<SongModel> _filterAndSort(List<SongModel> songs) {
    Iterable<SongModel> filtered = songs;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) => s.title.toLowerCase().contains(_searchQuery) || s.composer.toLowerCase().contains(_searchQuery));
    }
    if (_isMaestroFilter) {
      filtered = filtered.where((s) => s.composer.toLowerCase().contains('ilaiyaraaja') || s.composer.toLowerCase().contains('ilayaraja'));
    }
    
    List<SongModel> result = filtered.toList();
    
    if (_activeSort == 'Newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_activeSort == 'Challenge') {
      final order = {'Easy': 0, 'Medium': 1, 'Hard': 2, 'Masterpiece': 3};
      result.sort((a, b) => (order[b.difficulty] ?? 0).compareTo(order[a.difficulty] ?? 0));
    } else {
      // DEFAULT: A-Z
      result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 70,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 20),
              onPressed: () => appState.logout(),
            ),
            flexibleSpace: const GlassContainer(
              borderRadius: BorderRadius.zero,
              child: SizedBox.shrink(), // FIXED: Required child provided
            ),
            centerTitle: true,
            title: Text("THE STAGE", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white)),
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
              child: Column(
                children: [
                  Text(appState.stageGreeting, style: GoogleFonts.poppins(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: "Search Maestro's hits...", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Color(0xFFB76E79))),
                        ),
                        const Divider(color: Colors.white10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildChip("Ilayaraja Hits 🎼", _isMaestroFilter, (v) => setState(() => _isMaestroFilter = v)),
                              const SizedBox(width: 8),
                              _buildSortChip("Newest", _activeSort == 'Newest', () => setState(() => _activeSort = _activeSort == 'Newest' ? null : 'Newest')),
                              const SizedBox(width: 8),
                              _buildSortChip("Challenge", _activeSort == 'Challenge', () => setState(() => _activeSort = _activeSort == 'Challenge' ? null : 'Challenge')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              final songs = snapshot.data!.docs.map((d) => SongModel.fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList();
              final processed = _filterAndSort(songs);
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildSongCard(processed[i]),
                  childCount: processed.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // ADD TRACK ENABLED FOR ALL
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const AddSongModal()),
        backgroundColor: const Color(0xFFB76E79),
        label: const Text("ADD TRACK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(),
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: const Color(0xFFB76E79),
      backgroundColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  Widget _buildSongCard(SongModel song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () async {
          final toVault = await Navigator.push(context, MaterialPageRoute(builder: (_) => StudioScreen(song: song)));
          if (toVault == true && mounted) widget.onSwitchToVault();
        },
        // EDIT ENABLED FOR ALL
        onLongPress: () => showDialog(context: context, builder: (_) => EditSongModal(song: song)),
        child: GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.music_note, color: Color(0xFFB76E79)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text("${song.movie} • ${song.composer}", style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.5)),
                  ],
                ),
              ),
              const Icon(Icons.edit_note, color: Colors.white24, size: 18),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
