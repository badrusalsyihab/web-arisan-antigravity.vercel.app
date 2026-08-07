import 'package:flutter/material.dart';

class UpgradePremiumDialog extends StatelessWidget {
  final String title;
  final String message;

  const UpgradePremiumDialog({
    super.key,
    required this.title,
    required this.message,
  });

  static void show(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => UpgradePremiumDialog(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            // TODO: Launch WhatsApp or direct to admin
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan hubungi Admin via WhatsApp: 0812-XXXX-XXXX')),
            );
          },
          child: const Text('Upgrade Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
