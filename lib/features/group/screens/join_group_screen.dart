import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/user_model.dart';

class JoinGroupScreen extends StatefulWidget {
  final UserModel currentUser;
  final Function(GroupModel) onGroupJoined;
  final String? initialJoinCode;

  const JoinGroupScreen({
    super.key,
    required this.currentUser,
    required this.onGroupJoined,
    this.initialJoinCode,
  });

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codeController = TextEditingController();
  final _firebaseService = FirebaseService();

  bool _isLoading = false;
  GroupModel? _foundGroup;
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    if (widget.initialJoinCode != null && widget.initialJoinCode!.isNotEmpty) {
      _codeController.text = widget.initialJoinCode!;
      // Delay search slightly to let the UI build first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchGroup();
      });
    }
  }

  Future<void> _searchGroup() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan kode kelompok'))); */
      return;
    }

    setState(() => _isLoading = true);
    
    final group = await _firebaseService.getGroupByJoinCode(code);
    
    if (group == null) {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelompok tidak ditemukan'))); */
      }
      setState(() {
        _foundGroup = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _foundGroup = group;
      _isLoading = false;
      _selectedMemberId = null; // Reset selection
    });
  }

  Future<void> _joinGroup() async {
    if (_foundGroup == null || _selectedMemberId == null) return;

    setState(() => _isLoading = true);

    final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_');
    final success = await _firebaseService.joinGroup(_foundGroup!.id, _selectedMemberId!, userId);

    if (success) {
      // Re-fetch the group to get updated members
      final updatedGroup = await _firebaseService.getGroup(_foundGroup!.id);
      if (updatedGroup != null && mounted) {
        widget.onGroupJoined(updatedGroup);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal bergabung ke kelompok'))); */
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinAsNewMember() async {
    if (_foundGroup == null) return;

    setState(() => _isLoading = true);

    final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_');
    final success = await _firebaseService.joinGroupAsNewMember(_foundGroup!.id, userId, widget.currentUser.name);

    if (success) {
      final updatedGroup = await _firebaseService.getGroup(_foundGroup!.id);
      if (updatedGroup != null && mounted) {
        widget.onGroupJoined(updatedGroup);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal bergabung ke kelompok sebagai anggota baru'))); */
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabung Kelompok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan 6 Karakter Kode Kelompok',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Misal: X7K9PQ',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading && _foundGroup == null
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CARI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),

            if (_foundGroup != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kelompok Ditemukan 🎉', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_foundGroup!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    const SizedBox(height: 20),

                    const Text('Pilih Nama Anda:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 8),
                    
                    // Dropdown of members who haven't claimed an account (userId == null)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      ),
                      hint: const Text('Saya adalah...'),
                      value: _selectedMemberId,
                      items: _foundGroup!.members
                          .where((m) => m.userId == null)
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text('${m.name} (${m.waNumber})'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedMemberId = val);
                      },
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: (_isLoading || _selectedMemberId == null) ? null : _joinGroup,
                      child: _isLoading && _foundGroup != null && _selectedMemberId != null
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('✅ Ya, Ini Saya (Gabung)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('ATAU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isLoading ? null : _joinAsNewMember,
                      child: _isLoading && _foundGroup != null && _selectedMemberId == null
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
                          : const Text('🆕 Daftar sebagai Anggota Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
