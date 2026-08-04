import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_session.dart';
import '../../../core/services/firebase_service.dart';
import '../../group/screens/create_group_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel currentUser;
  final Function(GroupModel) onGroupSelected;
  final Function(GroupModel) onGroupCreated;
  final Function(UserModel)? onUserUpdated;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.onGroupSelected,
    required this.onGroupCreated,
    this.onUserUpdated,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser != widget.currentUser) {
      _user = widget.currentUser;
    }
  }

  void _showEditPhoneDialog() {
    final phoneController = TextEditingController(text: _user.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📱 Edit No. WhatsApp',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Masukkan nomor WhatsApp aktif Anda agar anggota lain dapat dengan mudah menghubungi Anda untuk konfirmasi iuran.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),

                  const Text('Nomor WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: AppTheme.accent, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nomor WhatsApp wajib diisi';
                      }
                      if (v.trim().length < 9) {
                        return 'Nomor WhatsApp tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final updatedPhone = phoneController.text.trim();
                          final updatedUser = UserModel(
                            name: _user.name,
                            email: _user.email,
                            photoUrl: _user.photoUrl,
                            phone: updatedPhone,
                          );

                          setState(() {
                            _user = updatedUser;
                          });

                          await UserSession.saveUser(updatedUser);
                          await FirebaseService().saveUserProfile(updatedUser);
                          widget.onUserUpdated?.call(updatedUser);

                          if (context.mounted) {
                            Navigator.pop(context);
                            /* ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ No. WhatsApp berhasil diperbarui!'),
                                backgroundColor: AppTheme.accent,
                              ),
                            ); */
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                      label: const Text('Simpan Nomor WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter = _user.name.isNotEmpty ? _user.name[0].toUpperCase() : 'B';
    final hasPhone = _user.phone != null && _user.phone!.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('👤 Profil Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.logout, color: AppTheme.danger),
                tooltip: 'Keluar / Logout',
                onPressed: widget.onLogout,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Logged In User Card
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_user.photoUrl != null && _user.photoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.network(
                      _user.photoUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                        radius: 35,
                        backgroundColor: AppTheme.primary,
                        child: Text(firstLetter, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppTheme.primary,
                    child: Text(firstLetter, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                const SizedBox(height: 12),

                Text(
                  _user.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                const SizedBox(height: 2),
                Text(
                  _user.email,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),

                // Interactive Phone Number Badge / Add Button
                InkWell(
                  onTap: _showEditPhoneDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasPhone
                          ? AppTheme.accent.withValues(alpha: 0.12)
                          : AppTheme.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasPhone ? AppTheme.accent : AppTheme.warning,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasPhone ? Icons.phone_android_rounded : Icons.add_call,
                          size: 14,
                          color: hasPhone ? AppTheme.accent : AppTheme.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasPhone ? _user.phone! : 'Tambahkan No. WhatsApp',
                          style: TextStyle(
                            fontSize: 11,
                            color: hasPhone ? AppTheme.accent : AppTheme.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: hasPhone ? AppTheme.accent : AppTheme.warning,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Logout Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: widget.onLogout,
                  child: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Versi App: ${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // BUTTON BUAT KELOMPOK ARISAN BARU
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingin Membuat Arisan Baru?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Anda dapat membuat kelompok arisan sendiri dan menjadi Ketua/Admin.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGroupScreen(
                          currentUser: _user,
                          onGroupCreated: widget.onGroupCreated,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Buat Kelompok Arisan Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
