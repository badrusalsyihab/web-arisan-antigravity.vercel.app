import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/imgbb_service.dart';
import '../../../core/services/firebase_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImgbbService _imgbbService = ImgbbService();
  final FirebaseService _firebaseService = FirebaseService();



  Future<void> _handleUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;
    
    // Validasi tipe file (sederhana)
    final ext = image.name.split('.').last.toLowerCase();
    final validExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    if (!validExts.contains(ext)) {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format tidak didukung! Harus berupa gambar (JPG/PNG/WEBP).'),
            backgroundColor: AppTheme.warning,
          ),
        ); */
      }
      return;
    }

    final bytes = await image.readAsBytes();
    
    // Validasi ukuran maksimal 15MB
    final sizeInBytes = bytes.lengthInBytes;
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB > 15) {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran gambar terlalu besar! Maksimal 15 MB.'),
            backgroundColor: AppTheme.warning,
          ),
        ); */
      }
      return;
    }

    if (!mounted) return;

    // SnackBar removed
    final user = FirebaseAuth.instance.currentUser;

    final uploadedPhoto = await _imgbbService.uploadImage(
      photoTitle: image.name,
      emoji: '📸',
      bytes: bytes.toList(),
      uploadedBy: user?.email ?? 'Admin',
    );

    if (uploadedPhoto != null) {
      _firebaseService.addGalleryPhoto('g1', uploadedPhoto);

      if (!mounted) return;
      // Success SnackBar removed
    } else {
      if (!mounted) return;
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal mengunggah foto')),
      ); */
    }
  }

  void _showImageDetailModal(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: item.containsKey('url')
                      ? Image.network(
                          item['url']!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 200,
                          color: const Color(0xFFF8FAFC),
                          child: Center(
                            child: Text(item['emoji'] ?? '📸', style: const TextStyle(fontSize: 64)),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Dokumentasi',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(item['date'] ?? 'Hari Ini', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          if (item.containsKey('uploadedBy')) ...[
                            const SizedBox(width: 16),
                            const Icon(Icons.person, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['uploadedBy']!, 
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Tutup'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textMain,
                                side: const BorderSide(color: AppTheme.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (item.containsKey('url')) {
                                  Share.share('Lihat dokumentasi Arisan: ${item['title']} - ${item['url']}');
                                } else {
                                  /* ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Hanya foto asli yang dapat dibagikan.')),
                                  ); */
                                }
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Bagikan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📸 Galeri Arisan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _handleUploadPhoto,
                icon: const Icon(Icons.cloud_upload_outlined, size: 16, color: AppTheme.limeAccent),
                label: const Text('+ Upload Foto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Google Drive & Firebase Sync Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pastelPurple.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.cloud_done_rounded, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ImgBB & Firebase Connected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                      SizedBox(height: 2),
                      Text('Foto disimpan aman di ImgBB dengan metadata realtime Firestore.', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid Photo Display
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firebaseService.streamGallery('g1'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }

              // Gabungkan dengan dummy untuk fallback visual
              final firebasePhotos = snapshot.data ?? [];
              final dummyPhotos = [
                {'emoji': '🌺', 'title': 'Kocokan Periode 1', 'driveUrl': 'https://drive.google.com'},
                {'emoji': '🍱', 'title': 'Makan Bersama RT', 'driveUrl': 'https://drive.google.com'},
                {'emoji': '🎁', 'title': 'Penyerahan Pot Arisan', 'driveUrl': 'https://drive.google.com'},
                {'emoji': '📸', 'title': 'Foto Bersama Anggota', 'driveUrl': 'https://drive.google.com'},
              ];
              final allPhotos = [...firebasePhotos, ...dummyPhotos];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: allPhotos.length,
                itemBuilder: (context, index) {
                  final photo = allPhotos[index];
                  return GestureDetector(
                    onTap: () => _showImageDetailModal(photo.cast<String, String>()),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        image: photo.containsKey('url') 
                            ? DecorationImage(
                                image: NetworkImage(photo['url']!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (photo.containsKey('url'))
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black87],
                                  ),
                                ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!photo.containsKey('url')) ...[
                              Center(child: Text(photo['emoji'] ?? '📸', style: const TextStyle(fontSize: 38))),
                              const Spacer(),
                            ],
                            Text(
                              photo['title'] ?? 'Dokumentasi',
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: photo.containsKey('url') ? Colors.white : AppTheme.textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  photo.containsKey('url') ? Icons.cloud_done : Icons.link_rounded, 
                                  size: 10, 
                                  color: photo.containsKey('url') ? Colors.white70 : AppTheme.accent
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  photo.containsKey('url') ? 'ImgBB' : 'Local', 
                                  style: TextStyle(
                                    fontSize: 9, 
                                    color: photo.containsKey('url') ? Colors.white70 : AppTheme.accent, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
            },
          ),
        ],
      ),
    );
  }
}
