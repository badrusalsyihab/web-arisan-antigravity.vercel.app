import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/upgrade_premium_dialog.dart';
import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

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
  final _nameController = TextEditingController();
  final _firebaseService = FirebaseService();

  bool _isLoading = false;
  GroupModel? _foundGroup;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentUser.name;
    if (widget.initialJoinCode != null && widget.initialJoinCode!.isNotEmpty) {
      _codeController.text = widget.initialJoinCode!;
      // Delay search slightly to let the UI build first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchGroup();
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _searchGroup() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.joinGroupErrEmpty);
      return;
    }

    if (!widget.currentUser.isPremium) {
      final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_');
      final groupCount = await _firebaseService.getUserGroupCount(userId);
      if (groupCount >= 3) {
        if (mounted) {
          UpgradePremiumDialog.show(
            context,
            title: 'Batas Grup Tercapai',
            message: 'Akun gratis maksimal hanya dapat membuat/bergabung dengan 3 grup arisan. Silakan upgrade ke Premium untuk grup tak terbatas dan fitur lainnya!',
          );
        }
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final group = await _firebaseService.getGroupByJoinCode(code);
    
    if (group == null) {
      setState(() {
        _foundGroup = null;
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.joinGroupErrNotFound;
      });
      return;
    }

    final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_');
    if (group.memberUserIds.contains(userId)) {
      setState(() {
        _foundGroup = null;
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.joinGroupErrAlreadyJoined;
      });
      return;
    }

    setState(() {
      _foundGroup = group;
      _isLoading = false;

    });
  }

  Future<void> _joinAsNewMemberWithValidation() async {
    if (_foundGroup == null) return;
    
    final inputName = _nameController.text.trim();
    if (inputName.isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong');
      return;
    }

    final nameExists = _foundGroup!.members.any((m) => m.name.toLowerCase() == inputName.toLowerCase());
    if (nameExists) {
      setState(() {
        _errorMessage = 'Nama "$inputName" sudah digunakan di kelompok ini. Silakan gunakan nama lain.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_');
    final success = await _firebaseService.joinGroupAsNewMember(_foundGroup!.id, userId, inputName);

    if (success) {
      final updatedGroup = await _firebaseService.getGroup(_foundGroup!.id);
      if (updatedGroup != null && mounted) {
        widget.onGroupJoined(updatedGroup);
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.joinGroupErrFailedNew;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.joinGroupTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.joinGroupCodeLabel,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
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
                      hintText: AppLocalizations.of(context)!.joinGroupCodeHint,
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
                      : Text(AppLocalizations.of(context)!.btnSearch, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                    Text(AppLocalizations.of(context)!.joinGroupFoundTitle, style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_foundGroup!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.joinGroupSelectName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama Anda di Kelompok Ini',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isLoading ? null : _joinAsNewMemberWithValidation,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Gabung ke Kelompok',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
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
