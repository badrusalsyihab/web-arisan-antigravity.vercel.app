import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_arisan_antigravity/core/models/group_model.dart';
import 'package:app_arisan_antigravity/core/models/user_model.dart';
import 'package:app_arisan_antigravity/core/services/firebase_service.dart';
import 'package:app_arisan_antigravity/core/services/imgbb_service.dart';
import 'package:app_arisan_antigravity/core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GalleryDetailScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel currentUser;

  const GalleryDetailScreen({
    Key? key,
    required this.group,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchGallery();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchGallery();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGallery() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final result = await FirebaseService().getGalleryPaginated(
      widget.group.id,
      lastDocument: _lastDoc,
      limit: 12,
    );

    final List<Map<String, dynamic>> newItems = result['items'];
    final DocumentSnapshot? newLastDoc = result['lastDoc'];

    setState(() {
      _items.addAll(newItems);
      _lastDoc = newLastDoc;
      _isLoading = false;
      if (newItems.length < 12) {
        _hasMore = false;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final ext = image.name.split('.').last.toLowerCase();
        final validExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
        if (!validExts.contains(ext)) return;

        final bytes = await image.readAsBytes();

        final sizeInBytes = bytes.lengthInBytes;
        final sizeInMB = sizeInBytes / (1024 * 1024);
        if (sizeInMB > 15) return;

        setState(() {
          _isUploading = true;
        });

        final imgbbService = ImgbbService();
        final result = await imgbbService.uploadImage(
          photoTitle: image.name,
          emoji: '🖼️',
          bytes: bytes.toList(),
          uploadedBy: widget.currentUser.email,
        );

        if (result != null) {
          await FirebaseService().addGalleryPhoto(widget.group.id, result);
          // Refresh gallery
          _items.clear();
          _lastDoc = null;
          _hasMore = true;
          _fetchGallery();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.galUploadFailed),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.galUploadFailed),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageDetailModal(Map<String, dynamic> item) {
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child:
                      item.containsKey('url') &&
                          item['url'].toString().isNotEmpty
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
                            child: Text(
                              item['emoji'] ?? '📸',
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['date'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (item['uploadedBy'] != null &&
                          item['uploadedBy'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context)!.galUploadedBy}${item['uploadedBy']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.galBtnClose,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.galTitle,
          style: const TextStyle(
            color: AppTheme.textMain,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        actions: [
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(
              Icons.add_a_photo_outlined,
              size: 18,
              color: AppTheme.primary,
            ),
            label: Text(
              AppLocalizations.of(context)!.galBtnUpload,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(),
          Expanded(
            child: _items.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.galEmpty,
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 16,
                            color: AppTheme.limeAccent,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.galBtnFirstUpload,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _items.clear();
                      _lastDoc = null;
                      _hasMore = true;
                      await _fetchGallery();
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.25,
                          ),
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final item = _items[index];
                        return GestureDetector(
                          onTap: () => _showImageDetailModal(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.cardBorder),
                              image:
                                  item.containsKey('url') &&
                                      item['url'].toString().isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(item['url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                if (item.containsKey('url') &&
                                    item['url'].toString().isNotEmpty)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black87,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!item.containsKey('url') ||
                                          item['url'].toString().isEmpty) ...[
                                        Center(
                                          child: Text(
                                            item['emoji'] ?? '📸',
                                            style: const TextStyle(
                                              fontSize: 32,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                      Text(
                                        item['title'] ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              item.containsKey('url') &&
                                                  item['url']
                                                      .toString()
                                                      .isNotEmpty
                                              ? Colors.white
                                              : AppTheme.textMain,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['date'] ?? '',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color:
                                              item.containsKey('url') &&
                                                  item['url']
                                                      .toString()
                                                      .isNotEmpty
                                              ? Colors.white70
                                              : AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
