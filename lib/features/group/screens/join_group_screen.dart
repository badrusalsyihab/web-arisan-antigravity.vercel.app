import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/user_model.dart';
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
  final _firebaseService = FirebaseService();

  bool _isLoading = false;
  GroupModel? _foundGroup;
  String? _selectedMemberId;
  String? _errorMessage;

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
      setState(() => _errorMessage = AppLocalizations.of(context)!.joinGroupErrEmpty);
      return;
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
      _selectedMemberId = null; // Reset selection
    });
  }

  Future<void> _joinGroup() async {
    if (_foundGroup == null || _selectedMemberId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.joinGroupErrFailed;
      });
    }
  }

  Future<void> _joinAsNewMember() async {
    if (_foundGroup == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_');
    final success = await _firebaseService.joinGroupAsNewMember(_foundGroup!.id, userId, widget.currentUser.name);

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
                    
                    // Dropdown of members who haven't claimed an account (userId == null)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      ),
                      hint: Text(AppLocalizations.of(context)!.joinGroupDropdownHint),
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
                          : Text('✅ ${AppLocalizations.of(context)!.joinGroupBtnYes}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(AppLocalizations.of(context)!.joinGroupOr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
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
                          : Text('🆕 ${AppLocalizations.of(context)!.joinGroupBtnNew}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
