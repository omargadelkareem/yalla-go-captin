import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/captain_home_page.dart';

class CaptainDocumentsPage extends StatefulWidget {
  const CaptainDocumentsPage({super.key, required this.phoneKey});
  final String phoneKey;

  @override
  State<CaptainDocumentsPage> createState() => _CaptainDocumentsPageState();
}

class _CaptainDocumentsPageState extends State<CaptainDocumentsPage> {
  final picker = ImagePicker();
  final Map<String, XFile> files = {};
  bool loading = false;

  Future<void> _pick(String key) async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1400,
    );
    if (file != null && mounted) setState(() => files[key] = file);
  }

  Future<void> _submit() async {
    const required = ['profile', 'idFront', 'idBack', 'license', 'vehicle'];
    if (required.any((key) => !files.containsKey(key))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ارفع كل الصور المطلوبة أولاً')),
      );
      return;
    }
    setState(() => loading = true);
    try {
      final urls = <String, String>{};
      for (final key in required) {
        final Uint8List bytes = await files[key]!.readAsBytes();
        final ref = FirebaseStorage.instance
            .ref('captains/${widget.phoneKey}/documents/$key.jpg');
        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        urls[key] = await ref.getDownloadURL();
      }
      await FirebaseDatabase.instance
          .ref('captains/${widget.phoneKey}')
          .update({
        'profilePhotoUrl': urls['profile'],
        'documents': {
          'nationalIdFrontUrl': urls['idFront'],
          'nationalIdBackUrl': urls['idBack'],
          'driverLicenseUrl': urls['license'],
          'vehiclePhotoUrl': urls['vehicle'],
        },
        'documentsComplete': true,
        'status': 'pending',
        'updatedAt': ServerValue.timestamp,
      });
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CaptainHomePage()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر رفع المستندات. تأكد من تفعيل Firebase Storage: $e',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('توثيق حساب الكابتن'),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'ارفع صور واضحة للمراجعة',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'لن يتم تفعيل استقبال الرحلات قبل مراجعة بيانات الحساب.',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        _UploadTile(label: 'صورتك الشخصية', file: files['profile'], onTap: () => _pick('profile')),
        _UploadTile(label: 'البطاقة - الوجه الأمامي', file: files['idFront'], onTap: () => _pick('idFront')),
        _UploadTile(label: 'البطاقة - الوجه الخلفي', file: files['idBack'], onTap: () => _pick('idBack')),
        _UploadTile(label: 'رخصة القيادة', file: files['license'], onTap: () => _pick('license')),
        _UploadTile(label: 'صورة المركبة', file: files['vehicle'], onTap: () => _pick('vehicle')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: loading ? null : _submit,
          child: Text(loading ? 'جاري رفع المستندات...' : 'إرسال للمراجعة'),
        ),
      ],
    ),
  );
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.label, required this.file, required this.onTap});
  final String label;
  final XFile? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: file == null ? AppColors.surfaceSoft : const Color(0xFFE5FAF2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  file == null ? Icons.add_photo_alternate_outlined : Icons.check_rounded,
                  color: file == null ? AppColors.turquoiseDark : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                file == null ? 'اختيار' : 'تم',
                style: TextStyle(
                  color: file == null ? AppColors.textMuted : AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
