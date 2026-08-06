import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/user_model.dart';
import 'create_group_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoGroupScreen extends StatelessWidget {
  final UserModel currentUser;
  final Function(GroupModel) onGroupCreated;

  const NoGroupScreen({
    super.key,
    required this.currentUser,
    required this.onGroupCreated,
  });

  void _showJoinGroupDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🔗 ${AppLocalizations.of(context)!.noGroupJoinTitle}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.noGroupJoinSubtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 10),
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.noGroupJoinHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final code = codeCtrl.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(context);
              /* ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Berhasil bergabung ke kelompok $code!'),
                  backgroundColor: AppTheme.accent,
                ),
              ); */
            },
            child: Text(AppLocalizations.of(context)!.btnJoin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Text('👥', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)!.noGroupGreeting(currentUser.name),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.noGroupDesc,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Button 1: Create Group
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGroupScreen(
                          currentUser: currentUser,
                          onGroupCreated: onGroupCreated,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('➕ ${AppLocalizations.of(context)!.noGroupCreateBtn}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              // Button 2: Join Group
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _showJoinGroupDialog(context),
                  icon: const Icon(Icons.link, size: 18),
                  label: Text('🔗 ${AppLocalizations.of(context)!.noGroupJoinBtn}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
