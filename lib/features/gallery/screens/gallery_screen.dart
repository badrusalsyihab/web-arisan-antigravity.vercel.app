import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/google_drive_service.dart';
import '../../../core/services/firebase_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, String>> localPhotos = [
    {'emoji': '🌺', 'title': 'Kocokan Periode 1', 'driveUrl': 'https://drive.google.com'},
    {'emoji': '🍱', 'title': 'Makan Bersama RT', 'driveUrl': 'https://drive.google.com'},
    {'emoji': '🎁', 'title': 'Penyerahan Pot Arisan', 'driveUrl': 'https://drive.google.com'},
    {'emoji': '📸', 'title': 'Foto Bersama Anggota', 'driveUrl': 'https://drive.google.com'},
  ];

  Future<void> _handleUploadToDrive() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏳ Menghubungkan ke Google Drive API...')),
    );

    final uploadedPhoto = await _driveService.uploadPhotoToDrive(
      photoTitle: 'Dokumentasi Arisan Baru',
      emoji: '📸',
    );

    if (uploadedPhoto != null) {
      setState(() {
        localPhotos.insert(0, uploadedPhoto);
      });
      _firebaseService.addGalleryPhoto('g1', uploadedPhoto);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.accent,
          content: Text('✅ Foto berhasil diunggah ke Google Drive & Firestore! Link: ${uploadedPhoto['driveUrl']}'),
        ),
      );
    }
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
              const Text('📸 Galeri & Google Drive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _handleUploadToDrive,
                icon: const Icon(Icons.cloud_upload_outlined, size: 16, color: AppTheme.limeAccent),
                label: const Text('+ Upload ke Drive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                  child: const Icon(Icons.add_to_drive, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Google Drive & Firebase Connected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                      SizedBox(height: 2),
                      Text('Foto dokumentasi disimpan aman di Google Drive dengan metadata realtime Firestore.', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid Photo Display
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: localPhotos.length,
            itemBuilder: (context, index) {
              final photo = localPhotos[index];
              return Container(
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
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(photo['emoji'] ?? '📸', style: const TextStyle(fontSize: 38)),
                    const SizedBox(height: 8),
                    Text(
                      photo['title'] ?? 'Dokumentasi Arisan',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.link_rounded, size: 12, color: AppTheme.accent),
                        const SizedBox(width: 2),
                        const Text('Google Drive', style: TextStyle(fontSize: 9, color: AppTheme.accent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
